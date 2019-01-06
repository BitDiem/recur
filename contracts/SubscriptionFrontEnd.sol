pragma solidity ^0.5.0;

import "./IAuthorizedTokenTransferer.sol";
import "./ComposedSubscription.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract SubscriptionFrontEnd is IAuthorizedTokenTransferer {

    mapping (address => bool) activeSubs;

    function createFixedRateSubscription(
        address payee,
        address token, 
        uint amount,
        uint interval,
        uint delay
    )
        public
        returns (address)
    {
        address payor = msg.sender;
        ComposedSubscription sub = new ComposedSubscription(this, payor, payee, token, amount, interval, delay);
        activeSubs[address(sub)] = true;
        return address(sub);
    }

    function transfer(
        address token, 
        address from, 
        address to, 
        uint amount
    ) 
        public
    {
        require(activeSubs[msg.sender]);
        IERC20 tokenContract = IERC20(token);
        require (tokenContract.allowance(from, address(this)) >= amount, "Token transfer not authorized");
        tokenContract.transferFrom(from, to, amount);
    }

}
