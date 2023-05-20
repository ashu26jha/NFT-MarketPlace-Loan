# NFT MarketPlace Loan

### ERC-721 Contract Structure
- Fixed amount of mintable NFT is present
- Fixed minting fee required to mint an NFT
- `_beforeTokenTransfer` hooks are used to update floor price. Floor price won't change if amount = 0
