pragma solidity ^0.5.0;

import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract AuthorizedTokenTransferer is IAuthorizedTokenTransferer, Ownable {

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