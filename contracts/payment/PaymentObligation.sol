pragma solidity ^0.5.0;

import "./IPaymentObligation.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Secondary.sol";

contract PaymentObligation is IPaymentObligation, Secondary {

    using SafeMath for uint;

    uint private _outstandingAmount;

    event OutstandingAmountChanged(uint outstandingAmount);

    function outstandingAmount() public view returns (uint) {
        return _outstandingAmount;
    }

    function currentAmountDue() public returns (uint) {
        _setOutstandingAmount(_calculateOutstandingAmount());
        return _outstandingAmount;
    }

    function markAsPaid(uint amount) public onlyPrimary {
        _setOutstandingAmount(_outstandingAmount.sub(amount));
    }

    function _calculateOutstandingAmount() internal returns (uint);

    function _setOutstandingAmount(uint val) internal {
        if(_outstandingAmount == val) return;
        _outstandingAmount = val;
        emit OutstandingAmountChanged(_outstandingAmount);
    }

}