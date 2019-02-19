pragma solidity ^0.5.0;

import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract AuthorizedTokenTransferer is IAuthorizedTokenTransferer, WhitelistedRole { 

    event TokenTransferred(
        address from, 
        address to, 
        address token, 
        uint amount
    );

    function transfer(
        address from, 
        address to, 
        address token,
        uint amount
    ) 
        public
        onlyWhitelisted
    {
        /*require(from != address(0));
        require(to != address(0));
        require(token != address(0));
        require(amount > 0);*/
        IERC20 tokenContract = IERC20(token);
        require (tokenContract.allowance(from, address(this)) >= amount, "Token transfer not authorized");
        tokenContract.transferFrom(from, to, amount);
        emit TokenTransferred(from, to, token, amount);
    }

}