// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IPromo.sol";

contract Badges is ReentrancyGuard {

  // BADGES
  struct Badge {
    uint256 id;
    uint256 totalAssigned;
    string name;
  }
  mapping(uint256 => Badge) private _badge;

  // BADGE BALANCES
  mapping(address => mapping(uint256 => uint256)) private _ownerBadgeBalance;
  uint256 private _totalBadges;

  // PROMOS
  struct Promo {
    uint256 id;
    uint256 expirationTimestamp;
    uint256[] badges;
    uint256[] quantities;
    uint256 totalRedeemed;
    address contractAddress;
  }
  mapping(uint256 => Promo) _promo;

  constructor(){
    _totalBadges = 0;
  }

  /**
  ////////////////////////////////////////////////////
  // External Functions 
  ///////////////////////////////////////////////////
  */

  // INITIALIZE BADGE
  // TODO: for prod add access control
  function initBadge(
    uint256 id_,
    string memory name_
  ) external virtual {
    require(_badge[id_].id == 0, "BADGE_ALREADY_INITIALIZED");
    _badge[id_] = Badge(id_, 0, name_);
    _totalBadges++;
  }

  // ASSIGN BADGES TO CUSTOMER
  // TODO: for prod add access control
  function assignBadges(
    uint256 id_,
    address to_,
    uint256 amount_
  ) external virtual nonReentrant {
    require(id_ <= _totalBadges, "BADGE_UNAVAILABLE");
    _ownerBadgeBalance[to_][id_] += amount_;
    _badge[id_].totalAssigned += amount_;
  }

  // INITIALIZE PROMO
  // TODO: for prod add access control
  function initPromo(
    uint256 id_,
    uint256 expirationTimestamp_,
    uint256[] memory badges_,
    uint256[] memory quantities_,
    address contractAddress_
  ) external {
    require(_promo[id_].id == 0, "PROMO_ALREADY_INITIALIZED");
    require(expirationTimestamp_ > block.timestamp, "TIMESTAMP_IN_PAST");
    require(badges_.length == quantities_.length, "ARRAYS_LENGTH_MISMATCH");

    _promo[id_] = Promo(id_, expirationTimestamp_, badges_, quantities_, 0, contractAddress_);
  }

  // REDEEM PROMO
  function redeemPromo(uint256 promoId_, address to_) external nonReentrant {
    Promo storage promo = _promo[promoId_];
    
    require(block.timestamp <= promo.expirationTimestamp, "PROMO_EXPIRED");
    
    for (uint256 i = 0; i < promo.badges.length; i++) {
      require(_ownerBadgeBalance[to_][promo.badges[i]] >= promo.quantities[i], "NOT_ENOUGH_BADGES");
      _ownerBadgeBalance[to_][promo.badges[i]] -= promo.quantities[i];
    }

    IPromo(promo.contractAddress).mintPromo(to_);
    promo.totalRedeemed += 1;
  }

  /**
  ////////////////////////////////////////////////////
  // View only functions
  ///////////////////////////////////////////////////
  */

  function totalBadges() external view virtual returns (uint256) {
    return _totalBadges;
  }

  function badgeInfo(
    uint256 badgeId_
    ) external view virtual returns (uint256 totalAssigned, string memory name) {
      require(badgeId_ <= _totalBadges, "BADGE_UNAVAILABLE");
      Badge storage badge = _badge[badgeId_];
      return (badge.totalAssigned, badge.name);
  }

  function balanceOfBadge(
    address owner_,
    uint256 badgeId_
  ) external view virtual returns (uint256) {
    require(badgeId_ <= _totalBadges, "BADGE_UNAVAILABLE");
    return _ownerBadgeBalance[owner_][badgeId_];
  }

  function promoInfo(
    uint256 promoId_
    ) external view virtual returns (uint256 expirationTimestamp, uint256[] memory badges, uint256[] memory quantities, uint256 totalRedeemed, address contractAddress) {
      Promo storage promo = _promo[promoId_];
      return (promo.expirationTimestamp, promo.badges, promo.quantities, promo.totalRedeemed, promo.contractAddress);
  }
}