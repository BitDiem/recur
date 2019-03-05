pragma solidity ^0.5.0;

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
        IERC20 token,
        uint amount
    ) 
        public
        onlyWhitelisted
    {
        require (token.allowance(from, address(this)) >= amount, "Token transfer not authorized");
        token.transferFrom(from, to, amount);
        emit TokenTransferred(from, to, token, amount);
    }

}