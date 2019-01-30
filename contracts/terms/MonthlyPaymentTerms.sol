pragma solidity ^0.5.0;

import "../payment/PaymentObligation.sol";
import "../lib/BokkyPooBahsDateTimeLibrary.sol";

contract MonthlyPaymentTerms is PaymentObligation {

    uint private _nextPaymentMonth;
    uint private _nextPaymentDay;
    uint private _nextPaymentYear;
    uint private _nextPaymentTimestamp;

    uint private _amount;

    event RecurringPaymentsElapsed(
        uint totalOutstandingAmount, 
        uint totalOutstandingIntervals, 
        uint lastIntervalTime
    );

    constructor(
        uint amount,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentYear
    )
        public
    {
        require(BokkyPooBahsDateTimeLibrary.isValidDate(
            nextPaymentYear,
            nextPaymentMonth,
            nextPaymentDay
        ));
        require(amount > 0);

        _amount = amount;
        _nextPaymentMonth = nextPaymentMonth;
        _nextPaymentDay = nextPaymentDay;
        _nextPaymentYear = nextPaymentYear;
    }

    function _calculateOutstandingAmount() internal returns (uint) {
        if (_getCurrentTimeInUnixMilliseconds() < _nextPaymentTimestamp)
            return 0;

        if (_nextPaymentMonth == 12) {
            _nextPaymentMonth = 1;
            _nextPaymentYear = _nextPaymentYear + 1;
        } else {
            _nextPaymentMonth = _nextPaymentMonth + 1;
        }
            
        _nextPaymentTimestamp = BokkyPooBahsDateTimeLibrary.timestampFromDate(
            _nextPaymentYear,
            _nextPaymentMonth,
            _nextPaymentDay
        );

        return _amount;
    }

    /// Wrap the call and make it internal - makes it easy to create a derived mock class
    function _getCurrentTimeInUnixMilliseconds() internal view returns (uint) {
        return now;
    }

}