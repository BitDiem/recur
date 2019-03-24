pragma solidity ^0.5.0;

import "../terms/Seconds.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title Hours
 * @dev Specifies an initial payment due date and time, as well as an interval, 
 * measured in hours, between due dates thereafter.
 */
contract Hours is Seconds {

    using SafeMath for uint;

    uint constant SECONDS_PER_HOUR = 60 * 60;

    constructor(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond,
        uint hoursIncrement
    )
        Seconds(
            amount, 
            nextPaymentYear,
            nextPaymentMonth,
            nextPaymentDay,
            nextPaymentHour,
            nextPaymentMinute,
            nextPaymentSecond,
            hoursIncrement.mul(SECONDS_PER_HOUR)
        )
        public
    {
    }

}