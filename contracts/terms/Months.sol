pragma solidity ^0.5.0;

import "../terms/FixedDate.sol";

/**
 * @title Months
 * @dev Increments next payment due date by N months.  Common use-case: quarterly payments.
 * Payment will *always* occur on the same day, the same hour, and the same second.
 */
contract Months is FixedDate {

    uint private _monthIncrement;

    constructor(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond,
        uint monthIncrement
    )
        FixedDate(amount, nextPaymentYear, nextPaymentMonth, nextPaymentDay, nextPaymentHour, nextPaymentMinute, nextPaymentSecond)
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