pragma solidity ^0.5.0;

import "../terms/Seconds.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title Minutes
 * @dev Specifies an initial payment due date and time, as well as an interval, 
 * measured in minutes, between due dates thereafter.
 */
contract Minutes is Seconds {

    using SafeMath for uint;

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
            minutesIncrement.mul(SECONDS_PER_MINUTE)
        )
        public
    {
    }

}