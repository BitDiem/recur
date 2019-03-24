pragma solidity ^0.5.0;

import "../../terms/Seconds.sol";

library SecondsTermsFactory {

    function create(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond,
        uint secondsIncrement
    )
        external
        returns (Seconds)
    {
        return new Seconds(
            amount, 
            nextPaymentYear, 
            nextPaymentMonth, 
            nextPaymentDay, 
            nextPaymentHour, 
            nextPaymentMinute, 
            nextPaymentSecond,
            secondsIncrement
        );
    }

}