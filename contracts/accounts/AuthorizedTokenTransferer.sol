pragma solidity ^0.5.0;

import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract AuthorizedTokenTransferer is IAuthorizedTokenTransferer {

    mapping(address => bool) _whitelistedCallers;

    modifier onlyWhitelistedCallers {
        require(_whitelistedCallers[msg.sender]);
        _;
    }
    
    function transfer(
        address token, 
        address from, 
        address to, 
        uint amount
    ) 
        public
        onlyWhitelistedCallers
    {
        IERC20 tokenContract = IERC20(token);
        require (tokenContract.allowance(from, address(this)) >= amount, "Token transfer not authorized");
        tokenContract.transferFrom(from, to, amount);
    }
}