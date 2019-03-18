pragma solidity ^0.5.0;

contract PaymentDebt {

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