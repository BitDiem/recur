pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract PaymentDebt {

    using SafeMath for uint;

    uint private _outstandingAmount;

    event OutstandingAmountChanged(uint outstandingAmount);

    function getOutstandingAmount() public view returns (uint) {
        return _outstandingAmount;
    }

    function _setOutstandingAmount(uint outstandingAmount) internal {
        if(_outstandingAmount == outstandingAmount) return;
        _outstandingAmount = outstandingAmount;
        emit OutstandingAmountChanged(_outstandingAmount);
    }

}