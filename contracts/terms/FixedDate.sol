pragma solidity ^0.5.4;

import "../payment/PaymentObligation.sol";
import "../lib/BokkyPooBahsDateTimeLibrary.sol";

contract FixedDate is PaymentObligation {
    // TODO:  tweak this to be a base class, and extend monthly, multi monthly, weekly, and yearly child contracts from this

    uint internal _nextPaymentYear;
    uint internal _nextPaymentMonth;
    uint internal _nextPaymentDay;
    
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

        _advance();
        _calculateNextPaymentTimestamp();

        emit NewPaymentDue(_amount, _nextPaymentTimestamp);
        
        return _amount;
    }

    /// Wrap the call and make it internal - makes it easy to create a derived mock class
    function _getCurrentTimeInUnixMilliseconds() internal view returns (uint) {
        return now;
    }

    function _advance() internal;

    function _calculateNextPaymentTimestamp() private {
        // adjust for the days of month for payment days greater than 28 (since all months have at least 28 days)
        uint adjustedPaymentDay = _nextPaymentDay;
        if (_nextPaymentDay > 28) {
            uint daysInMonth = BokkyPooBahsDateTimeLibrary._getDaysInMonth(_nextPaymentYear, _nextPaymentMonth);
            if (_nextPaymentDay > daysInMonth) {
                adjustedPaymentDay = daysInMonth;
            }
        }

        // create the timestamp from year, month, and adjusted date
        _nextPaymentTimestamp = BokkyPooBahsDateTimeLibrary.timestampFromDate(
            _nextPaymentYear,
            _nextPaymentMonth,
            adjustedPaymentDay
        );
    }

    /// Code based on https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
    function _isValidMonthAndYear(uint month, uint year) private pure returns (bool) {
        return (year >= 1970 && month > 0 && month <= 12);
    }

}