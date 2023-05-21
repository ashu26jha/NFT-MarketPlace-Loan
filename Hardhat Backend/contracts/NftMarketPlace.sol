// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

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

contract NftMarketPlace is IERC721Receiver{
    
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
        if(index<s_LoanListing.length){
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


}
