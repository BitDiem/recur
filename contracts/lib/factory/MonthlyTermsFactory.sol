pragma solidity ^0.5.0;

import "../../terms/Monthly.sol";

library MonthlyTermsFactory {

    function create(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay
    )
        external
        returns (Monthly)
    {
        return new Monthly(amount, nextPaymentYear, nextPaymentMonth, nextPaymentDay);
    }

}