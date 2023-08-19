// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Promo001 is ERC721Enumerable  {
  using Counters for Counters.Counter;
  Counters.Counter private _nextTokenId;

  uint256 public immutable EXPIRATION_TIMESTAMP;

  event PromoRedeemed(address indexed owner, uint256 tokenId);

  constructor(
    string memory name_,
    string memory symbol_,
    uint256 expiration_
  ) ERC721(name_, symbol_)
  {
    EXPIRATION_TIMESTAMP = expiration_;
    // start at token id = 1
    _nextTokenId.increment();
  }

  /**
  ////////////////////////////////////////////////////
  // External Functions 
  ///////////////////////////////////////////////////
  */

  function mintPromo(address to) external {
    uint256 tokenId = _nextTokenId.current();
    _mint(to, tokenId);
    _nextTokenId.increment();
  }
  
  function redeemPromo(uint256 tokenId) external {
    require(ownerOf(tokenId) == msg.sender, 'CALLER_NOT_OWNER');
    require(block.timestamp <= EXPIRATION_TIMESTAMP, 'PROMO_EXPIRED');
    _burn(tokenId);
    emit PromoRedeemed(msg.sender, tokenId);
  }

  /**
  ////////////////////////////////////////////////////
  // View only functions
  ///////////////////////////////////////////////////
  */

  function getExpiration() external view returns (uint256) {
    return EXPIRATION_TIMESTAMP;
  }
}