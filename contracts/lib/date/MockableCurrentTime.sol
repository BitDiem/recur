pragma solidity ^0.5.0;

/**
 * @title MockableCurrentTime
 * @dev Allows child contracts to easily mock calls to environment "now" variable
 */
contract MockableCurrentTime {

    /// Wrap the call and make it internal - makes it easy to create a derived mock class to test exact hypothetical dateTimes
    function _getCurrentTimeInUnixSeconds() internal view returns (uint) {
        return now;
    }

}