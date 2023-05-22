// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error ItemNotForSale(address nftAddress, uint256 tokenId);
error NotListed(address nftAddress, uint256 tokenId);
error AlreadyListed(address nftAddress, uint256 tokenId);
error NoProceeds();
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();
error NftMarketPlace__BadIndex();
error NftMarketPlace__BorrowerWantsMore();

contract NftMarketPlace is IERC721Receiver, AutomationCompatibleInterface{
    
    struct Listing{
        uint256 price;
        address owner;
    }

    struct LoanList{
        uint256 requestAmt;
        uint256 tokenId;
        address borrower;
        address lender;
        address nftAddress;
        uint256 duration;
        uint256 startTime;
        uint256 TotalAMT;
        bool paid;
        bool expired;
    }

    // Events
    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemCanceled(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    event ItemBought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event LoanListRequested(
        uint256 indexed index,
        uint256 indexed tokenId,
        address indexed nftAddress,
        address borrower,
        uint256 time,
        uint256 amount
    );

    event lenderDealSubmitted(
        uint256 indexed index,
        uint256 indexed totalamt
    );

    event LoanSanctioned(
        uint256 indexed index
    );

    event LoanPaid(
        uint256 indexed index,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    event NFTconfiscated(
        uint256 indexed index,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    mapping(address => mapping(uint256 => Listing)) private s_listings;
    mapping(address => uint256) private s_proceeds;
    mapping(address => LoanList) private s_loanList;
    mapping(address => address) private s_lenderToBorrower; 
    mapping(address => uint256) private s_loanBalances;

    LoanList [] s_LoanListing;

    modifier notListed(address nftAddress, uint256 tokenId) {
        
        Listing memory listing = s_listings[nftAddress][tokenId];
        
        if (listing.price > 0) {
            revert AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        
        Listing memory listing = s_listings[nftAddress][tokenId];
        
        if (listing.price <= 0) {
            revert NotListed(nftAddress, tokenId);
        }
        _;
    }

    modifier isOwner(address nftAddress, uint256 tokenId, address spender) {
        
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        
        if (spender != owner) {
            revert NotOwner();
        }
        _;
    }

    function listItem(address nftAddress, uint256 tokenId, uint256 price) external notListed(nftAddress, tokenId) isOwner(nftAddress, tokenId, msg.sender){
        
        if (price <= 0) {
            revert PriceMustBeAboveZero();
        }
        IERC721 nft = IERC721(nftAddress);
        
        if (nft.getApproved(tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }
        
        s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
        
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    function cancelListing(address nftAddress, uint256 tokenId) external isOwner(nftAddress, tokenId, msg.sender) isListed(nftAddress, tokenId){
        delete (s_listings[nftAddress][tokenId]);
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }


    function buyItem(address nftAddress, uint256 tokenId) external payable isListed (nftAddress, tokenId){

        Listing memory listedItem = s_listings[nftAddress][tokenId];
        
        if (msg.value < listedItem.price) {
            revert PriceNotMet(nftAddress, tokenId, listedItem.price);
        }
        
        s_proceeds[listedItem.owner] += msg.value;
        delete (s_listings[nftAddress][tokenId]);
        IERC721(nftAddress).safeTransferFrom(listedItem.owner, msg.sender, tokenId);
        
        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);
    }


    function updateListing(address nftAddress, uint256 tokenId, uint256 newPrice) external isListed(nftAddress, tokenId) isOwner(nftAddress, tokenId, msg.sender){
        if (newPrice <= 0) {
            revert PriceMustBeAboveZero();
        }
        s_listings[nftAddress][tokenId].price = newPrice;
        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
    }

    function withdrawProceeds() external {
        
        uint256 proceeds = s_proceeds[msg.sender];
        
        if (proceeds <= 0) {
            revert NoProceeds();
        }
        
        s_proceeds[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        
        require(success, "Transfer failed");
    }

    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory){
        return s_listings[nftAddress][tokenId];
    }

    function getProceeds(address seller) external view returns (uint256) {
        return s_proceeds[seller];
    }

    // LOAN STUFF
    
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
    function getLoanDetails(uint256 index) public view returns (LoanList memory) {
        
        if(index>s_LoanListing.length){
            revert NftMarketPlace__BadIndex();
        }
        
        return s_LoanListing[index];
    }

    function ListLoan(address nftAddress, uint256 tokenId, uint256 amtNeeded, uint256 duration) isOwner(nftAddress, tokenId, msg.sender) public {
        LoanList memory createListing;
        
        createListing.borrower = msg.sender;
        createListing.requestAmt = amtNeeded;
        createListing.duration = duration;
        createListing.nftAddress = nftAddress;
        createListing.tokenId = tokenId;
        createListing.paid = false;

        s_LoanListing.push(createListing);
        
        emit LoanListRequested(s_LoanListing.length - 1,tokenId,nftAddress,msg.sender,duration,amtNeeded);
    }

    function lenderDeal(uint256 m_index, uint256 amt) public payable{
    
        if(msg.value < s_LoanListing[m_index].requestAmt){
            revert NftMarketPlace__BorrowerWantsMore();
        }
        
        s_loanBalances[s_LoanListing[m_index].borrower] = s_LoanListing[m_index].requestAmt;
        s_LoanListing[m_index].TotalAMT = amt;
        
        emit lenderDealSubmitted(m_index,amt);
    
    }

    function finaliseDeal(uint256 m_index) public {
        
        uint256 tempamt = s_LoanListing[m_index].requestAmt;
        s_loanBalances[s_LoanListing[m_index].borrower] = 0; // This will prevent reentrant attack

        IERC721(s_LoanListing[m_index].nftAddress).safeTransferFrom(s_LoanListing[m_index].borrower, address(this), s_LoanListing[m_index].tokenId);

        (bool success, ) = s_LoanListing[m_index].borrower.call{value: tempamt}("");
        require(success, "transaction failed");

        s_LoanListing[m_index].startTime = block.timestamp;
        emit LoanSanctioned(m_index);
    }

// A bug here fix it. Use timestamp and expired

    function payback(uint256 index)public payable{
        if(msg.value == 0){
            revert ("Send ETH");
        }
        
        s_loanBalances[msg.sender] += msg.value;
        
        if(s_LoanListing[index].TotalAMT <= s_loanBalances[msg.sender]){
            
            s_LoanListing[index].paid = true;
            s_proceeds[s_LoanListing[index].lender]=s_loanBalances[msg.sender];

            // Send back the nft to borrower
            IERC721(s_LoanListing[index].nftAddress).safeTransferFrom(address(this),s_LoanListing[index].borrower, s_LoanListing[index].tokenId);

            emit LoanPaid(index, s_LoanListing[index].nftAddress, s_LoanListing[index].tokenId);

            // Optimisation idea: If first m loans are paid start checkup from m.
        }

    }

    function checkUpkeep( bytes calldata  checkData  ) external view override returns (bool upkeepNeeded, bytes memory  performData){
        
        (uint256 index) = abi.decode(checkData,(uint256));
        uint256 counter = 0 ;

        for( uint256 i = 0 ; index < s_LoanListing.length ; i++){
            
            LoanList memory temp = s_LoanListing[i];
            uint256 currentTime = block.timestamp;

            if(currentTime - temp.startTime > temp.duration && (temp.paid == false) ){
                counter ++ ;
            }
        
        }

        uint256[] memory indexes = new uint256[](counter);
        uint256 j = 0 ;

        for( uint256 i = 0 ; i < s_LoanListing.length ; i++){
            
            LoanList memory temp = s_LoanListing[index];
            uint256 currentTime = block.timestamp;
            
            if(currentTime - temp.startTime > temp.duration && (temp.paid == false) ){
                indexes[j]=i;
                j+=1;
            }
        
        }

        upkeepNeeded = (counter!=0);
        performData = abi.encode(indexes);
        return (upkeepNeeded, performData);

        // OR WE CAN WRITE AS 
        // ********************************************
        // * return (counter!=0,abi.encode(indexes)); *
        // ********************************************
        // ONE LINER NO NEED OF IF STATEMENTS
    }

    function performUpkeep(bytes calldata  performData ) external override {
        (uint256[] memory defaulter) = abi.decode(performData,(uint256[]));

        for(uint256 i = 0 ; i < defaulter.length; i++){
            // Defaulter of i has the index of that loan
            IERC721(s_LoanListing[defaulter[i]].nftAddress).safeTransferFrom(address(this),s_LoanListing[defaulter[i]].lender,s_LoanListing[defaulter[i]].tokenId);
            
            s_proceeds[s_LoanListing[defaulter[i]].lender] = s_loanBalances[s_LoanListing[defaulter[i]].borrower];
            s_loanBalances[s_LoanListing[defaulter[i]].borrower] = 0;
            s_LoanListing[defaulter[i]].expired = true;
        }

    }

}
