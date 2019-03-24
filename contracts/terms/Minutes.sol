pragma solidity ^0.5.0;

import "../terms/Seconds.sol";

/**
 * @title Minutes
 * @dev Specifies an initial payment due date and time, as well as an interval, 
 * measured in minutes, between due dates thereafter.
 */
contract Minutes is Seconds {

    uint constant SECONDS_PER_MINUTE = 60;

    constructor(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond,
        uint minutesIncrement
    )
        Seconds(
            amount, 
            nextPaymentYear,
            nextPaymentMonth,
            nextPaymentDay,
            nextPaymentHour,
            nextPaymentMinute,
            nextPaymentSecond,
            minutesIncrement * SECONDS_PER_MINUTE)
        public
    {
    }

}