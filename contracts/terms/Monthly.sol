pragma solidity ^0.5.0;

import "../terms/FixedDate.sol";

/**
 * @title Monthly
 * @dev Increments next payment due date by one month.  
 * Payment will *always* occur on the same day, the same hour, and the same second, every month.
 */
contract Monthly is FixedDate {

    constructor(
        uint amount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second
    )
        FixedDate(amount, year, month, day, hour, minute, second)
        public
    {}

    function _advance() internal {
        if (_month == 12) {
            _month = 1;
            _year = _year + 1;
        } else {
            _month = _month + 1;
        }        
    }

}