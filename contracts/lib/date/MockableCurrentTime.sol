pragma solidity ^0.5.0;

/**
 * @title MockableCurrentTime
 * @dev Allows child contracts to easily mock calls to the environment "now" variable, for testing purposes.
 */
contract MockableCurrentTime {

    /// Override this function in child contracts for mocking/testing exact hypothetical dateTimes
    function _getCurrentTimeInUnixSeconds() internal view returns (uint) {
        return now;
    }

}