// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IPromo {

  event PromoRedeemed(address indexed owner, uint256 tokenId);

  function mintPromo(address to) external;

  function redeemPromo(address to) external;
}