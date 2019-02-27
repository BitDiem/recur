pragma solidity ^0.5.4;

import "../terms/FixedDate.sol";

contract MultiMonthly is FixedDate {

    uint private _monthIncrement;

    constructor(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint monthIncrement
    )
        FixedDate(amount, nextPaymentYear, nextPaymentMonth, nextPaymentDay)
        public
    {
        // use Monthly contract if you want increment = 1
        require(monthIncrement < 12 && monthIncrement > 1);
        _monthIncrement = monthIncrement;
    }

    function _advance() internal {
        _nextPaymentMonth += _monthIncrement;
        if (_nextPaymentMonth > 12) {
            _nextPaymentMonth -= 12;
            _nextPaymentYear += 1;
        }     
    }

}