pragma solidity ^0.5.0;

import "../../terms/datetime/Seconds.sol";
import "../../lib/date/DateTime.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title SecondsTermsFactory
 * @dev External library for creating different variants of Seconds.sol.  The included variants are:
 * - Days (intervals of N days per payment due date)
 * - Hours (intervals of N hours per payment due date)
 * - Minutes (intervals of N minutes per payment due date)
 * - Seconds (intervals of N seconds per payment due date)
 */
library SecondsTermsFactory {

    using SafeMath for uint;

    uint constant SECONDS_PER_MINUTE = 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_DAY = 24 * 60 * 60;

    function createDays(
        uint amount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint daysIncrement
    )
        external
        returns (Seconds)
    {
        return _create(amount, year, month, day, hour, minute, second, daysIncrement.mul(SECONDS_PER_DAY));
    }

    function createHours(
        uint amount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint hoursIncrement
    )
        external
        returns (Seconds)
    {
        return _create(amount, year, month, day, hour, minute, second, hoursIncrement.mul(SECONDS_PER_HOUR));
    }

    function createMinutes(
        uint amount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint minutesIncrement
    )
        external
        returns (Seconds)
    {
        return _create(amount, year, month, day, hour, minute, second, minutesIncrement.mul(SECONDS_PER_MINUTE));
    }

    function createSeconds(
        uint amount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint secondsIncrement
    )
        external
        returns (Seconds)
    {
        return _create(amount, year, month, day, hour, minute, second, secondsIncrement);
    }

    function createSecondsFromTimestamp(uint amount, uint firstPaymentDueTimestamp, uint secondsIncrement) external returns (Seconds) {
        return new Seconds(amount, firstPaymentDueTimestamp, secondsIncrement);
    }

    function _create(
        uint amount,
        uint year,
        uint month,
        uint day,
        uint hour,
        uint minute,
        uint second,
        uint secondsIncrement
    )
        private
        returns (Seconds)
    {
        require(DateTime.isValidDateTime(year, month, day, hour, minute, second));
        uint firstPaymentDueTimestamp = DateTime.timestampFromDateTime(year, month, day, hour, minute, second);
        return new Seconds(amount, firstPaymentDueTimestamp, secondsIncrement);
    }

}