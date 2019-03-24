pragma solidity ^0.5.0;

import "../terms/Seconds.sol";

/**
 * @title Days
 * @dev Specifies an initial payment due date and time, as well as an interval, 
 * measured in days, between due dates thereafter.
 */
contract Days is Seconds {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;

    constructor(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond,
        uint daysIncrement
    )
        Seconds(
            amount, 
            nextPaymentYear,
            nextPaymentMonth,
            nextPaymentDay,
            nextPaymentHour,
            nextPaymentMinute,
            nextPaymentSecond,
            daysIncrement * SECONDS_PER_DAY)
        public
    {
    }

}