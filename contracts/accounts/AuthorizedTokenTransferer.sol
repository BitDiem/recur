pragma solidity ^0.5.4;

import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract AuthorizedTokenTransferer is IAuthorizedTokenTransferer, WhitelistedRole { 

    event TokenTransferred(
        address indexed from, 
        address indexed to, 
        IERC20 indexed token, 
        uint amount
    );

    function transfer(
        address from, 
        address to, 
        IERC20 tokenContract,
        uint amount
    ) 
        public
        onlyWhitelisted
    {
        /*require(from != address(0));
        require(to != address(0));
        require(token != address(0));
        require(amount > 0);*/
        require (tokenContract.allowance(from, address(this)) >= amount, "Token transfer not authorized");
        tokenContract.transferFrom(from, to, amount);
        emit TokenTransferred(from, to, tokenContract, amount);
    }

}