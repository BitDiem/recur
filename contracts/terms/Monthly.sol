pragma solidity ^0.5.4;

import "../terms/FixedDate.sol";

contract Monthly is FixedDate {

    constructor(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay
    )
        FixedDate(amount, nextPaymentYear, nextPaymentMonth, nextPaymentDay)
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