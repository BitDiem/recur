pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/ownership/Secondary.sol";

contract PaymentObligation is Secondary {

    function currentAmountDue() public onlyPrimary returns (uint) {
        return _calculateOutstandingAmount();
    }

    function _calculateOutstandingAmount() internal returns (uint);
    
}