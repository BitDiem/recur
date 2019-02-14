pragma solidity ^0.5.0;

import "../payment/PaymentObligation.sol";
import "../lib/BokkyPooBahsDateTimeLibrary.sol";

contract MonthlyPaymentTerms is PaymentObligation {

    uint private _nextPaymentYear;
    uint private _nextPaymentMonth;
    uint private _nextPaymentDay;
    uint private _nextPaymentTimestamp;
    uint private _amount;

    event NewPaymentDue(uint amount, uint paymentDueDate);

    constructor(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay
    )
        public
    {
        require(amount > 0);
        require(_isValidMonthAndYear(nextPaymentMonth, nextPaymentYear));

        _amount = amount;
        _nextPaymentYear = nextPaymentYear;
        _nextPaymentMonth = nextPaymentMonth;
        _nextPaymentDay = nextPaymentDay;

        _calculateNextPaymentTimestamp();
    }

    function _calculateOutstandingAmount() internal returns (uint) {
        if (_getCurrentTimeInUnixMilliseconds() < _nextPaymentTimestamp)
            return 0;

        _incrementMonth();
        _calculateNextPaymentTimestamp();
        return _amount;
    }

    /// Wrap the call and make it internal - makes it easy to create a derived mock class
    function _getCurrentTimeInUnixMilliseconds() internal view returns (uint) {
        return now;
    }

    function _incrementMonth() private {
        if (_nextPaymentMonth == 12) {
            _nextPaymentMonth = 1;
            _nextPaymentYear = _nextPaymentYear + 1;
        } else {
            _nextPaymentMonth = _nextPaymentMonth + 1;
        }        
    }

    function _calculateNextPaymentTimestamp() private {
        // adjust for the days of month for payment days greater than 28 (since all months have at least 28 days)
        uint adjustedPaymentDay = _nextPaymentDay;
        if (_nextPaymentDay > 28) {
            uint daysInMonth = BokkyPooBahsDateTimeLibrary._getDaysInMonth(_nextPaymentYear, _nextPaymentMonth);
            if (adjustedPaymentDay > daysInMonth) {
                adjustedPaymentDay = daysInMonth;
            }
        }

        // create the timestamp from year, month, and adjusted date
        _nextPaymentTimestamp = BokkyPooBahsDateTimeLibrary.timestampFromDate(
            _nextPaymentYear,
            _nextPaymentMonth,
            adjustedPaymentDay
        );

        emit NewPaymentDue(_amount, _nextPaymentTimestamp);
    }

    /// Code based on https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
    function _isValidMonthAndYear(uint month, uint year) private pure returns (bool) {
        return (year >= 1970 && month > 0 && month <= 12);
    }

}