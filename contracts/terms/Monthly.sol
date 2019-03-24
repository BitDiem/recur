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
        if (_nextPaymentMonth == 12) {
            _nextPaymentMonth = 1;
            _nextPaymentYear = _nextPaymentYear + 1;
        } else {
            _nextPaymentMonth = _nextPaymentMonth + 1;
        }        
    }

}