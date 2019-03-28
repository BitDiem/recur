pragma solidity ^0.5.0;

import "./FixedDate.sol";

/**
 * @title Yearly
 * @dev Specifies an initial payment due date and time.  Increments next payment due date by one year.  
 * Payment will *always* occur on the same month, the same day, the same hour, and the same second, every year.
 */
contract Yearly is FixedDate {

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
        _year = _year + 1;     
    }

}