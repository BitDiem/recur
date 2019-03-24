pragma solidity ^0.5.0;

import "../terms/FixedDate.sol";

/**
 * @title Yearly
 * @dev Increments next payment due date by one year.  
 * Payment will *always* occur on the same month, the same day, the same hour, and the same second, every year.
 */
contract Yearly is FixedDate {

    constructor(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond
    )
        FixedDate(amount, nextPaymentYear, nextPaymentMonth, nextPaymentDay, nextPaymentHour, nextPaymentMinute, nextPaymentSecond)
        public
    {}

    function _advance() internal {
        _nextPaymentYear = _nextPaymentYear + 1;     
    }

}