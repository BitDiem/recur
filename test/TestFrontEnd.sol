pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "../contracts/frontend/SubscriptionFrontEnd.sol";
import "./mock/MockERC20.sol";

contract TestFrontEnd {

    function testFE() public {

        address payor = address(this);
        address payee = address(this);
        MockERC20 mockERC20 = new MockERC20("Mock ERC20", "MERC20", payor, 1000000);

        SubscriptionFrontEnd fe = new SubscriptionFrontEnd();

        mockERC20.authorize(fe, 100000000);

        address sub = fe.createFixedRateSubscription(
            payee,
            address(mockERC20),
            1,
            1,
            0
        );

        StandardSubscription(sub).payCurrentAmountDue();
    }
}