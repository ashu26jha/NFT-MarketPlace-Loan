# NFT MarketPlace Loan

### ERC-721 Contract Structure
- Fixed amount of mintable NFT is present
- Fixed minting fee required to mint an NFT
- `_beforeTokenTransfer` hooks are used to update floor price. Floor price won't change if amount = 0. TRY THIS ⭐️

RobotNFT 0xBCeD1ec38AF871a25c1a61e0CEcBcd5EdE9fCc2e
CatNFT 0x4F7B775Fc2AC08EdC94C1d5F3c491A28a169Ce8f
MarketPlace 0x24fBFe37bB14E728E7326c900044b1f4D0E1D9FC

### NFT MarketPlace Structure
- Could list on marketplace (Only Owner)
- Change the list price (Only Owner)
- Remove from the marketplace (Only Owner)

### NFT 
- Could list the NFT for loan. With the loan amount needed. And the duration.
- Loan terms can be negotiated
- Loan terms 🖊: Duration, Total amount. 
- The seller would transfer the funds to the contract and customer can withdraw the  amount and the timer would start after borrowing.
- Before the transfer of funds NFT marketplace would take ownership of the NFT
- If borrower pays on time, NFT is returned to the customer, lender can withdraw the amount
- If borrower fails to pay back in time, ownership of NFT is transfered to the lender

### Optimisation idea: If first m loans are paid start checkUpKeep from m.
