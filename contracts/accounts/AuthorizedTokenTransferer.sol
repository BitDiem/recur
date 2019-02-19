pragma solidity ^0.5.0;

import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract AuthorizedTokenTransferer is IAuthorizedTokenTransferer, Ownable { 
    // TODO: this might need to be a whitelistedadmin type implementation - otherwise only one frontend could add at a time

    mapping(address => bool) _whitelistedCallers;

    modifier onlyWhitelistedCallers {
        require(_whitelistedCallers[msg.sender]);
        _;
    }

    function transfer(
        address from, 
        address to, 
        address token,
        uint amount
    ) 
        public
        onlyWhitelistedCallers
    {
        IERC20 tokenContract = IERC20(token);
        require (tokenContract.allowance(from, address(this)) >= amount, "Token transfer not authorized");
        tokenContract.transferFrom(from, to, amount);
    }

    function addToWhitelist(address account) public onlyOwner {
        _whitelistedCallers[account] = true;
    }

    function removeFromWhitelist(address account) public onlyOwner {
        _whitelistedCallers[account] = false;
    }

}