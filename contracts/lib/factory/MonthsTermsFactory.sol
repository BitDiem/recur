pragma solidity ^0.5.0;

import "../../terms/datetime/Months.sol";

/**
 * @title MonthsTermsFactory
 * @dev External library for creating an instance of Months.sol.
 */
library MonthsTermsFactory {

    function create(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond,
        uint monthIncrement
    )
        external
        returns (Months)
    {
        return new Months(
            amount, 
            nextPaymentYear, 
            nextPaymentMonth, 
            nextPaymentDay, 
            nextPaymentHour, 
            nextPaymentMinute, 
            nextPaymentSecond,
            monthIncrement
        );
    }

}