pragma solidity ^0.5.0;

import "./FixedDate.sol";

/**
 * @title Months
 * @dev Increments next payment due date by N months.  Common use-case: quarterly payments.
 * Payment will *always* occur on the same day, the same hour, and the same second.
 */
contract Months is FixedDate {

    uint private _monthIncrement;

    constructor(
        uint amount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint monthIncrement
    )
        FixedDate(amount, year, month, day, hour, minute, second)
        public
    {
        // use Monthly contract if you want increment = 1
        require(monthIncrement < 12 && monthIncrement > 1);
        _monthIncrement = monthIncrement;
    }

    function _advance() internal {
        _month += _monthIncrement;
        if (_month > 12) {
            _month -= 12;
            _year += 1;
        }     
    }

}