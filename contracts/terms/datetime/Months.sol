pragma solidity ^0.5.0;

import "./FixedDate.sol";

/**
 * @title Months
 * @dev Increments next payment due date by N months.  Common use-case: quarterly payments.
 * Payment will *always* occur on the same day, the same hour, and the same second.
 */
contract Months is FixedDate {

    uint private _monthIncrements;

    constructor(
        uint amount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint monthsIncrement
    )
        FixedDate(amount, year, month, day, hour, minute, second)
        public
    {
        // use Monthly.sol contract if you want increment = 1
        require(monthsIncrement < 12 && monthsIncrement > 1);
        _monthIncrements = monthsIncrement;
    }

    function _advance() internal {
        _month += _monthIncrements;
        if (_month > 12) {
            _month -= 12;
            _year += 1;
        }     
    }

}