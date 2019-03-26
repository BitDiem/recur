pragma solidity ^0.5.0;

import "../../terms/FixedInterval.sol";

library FixedIntervalTermsFactory {

    function create(
        uint amount, 
        uint timeInterval, // as measured in seconds between intervals
        uint delay // use case: "first 30 days free"
    )
        external
        returns (FixedInterval)
    {
        return new FixedInterval(amount, timeInterval, delay);
    }

}