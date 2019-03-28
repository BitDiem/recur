pragma solidity ^0.5.0;

import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";

/**
 * @title AuthorizedTokenTransferer
 * @dev TODO: write
 */
contract AuthorizedTokenTransferer is IAuthorizedTokenTransferer, WhitelistedRole { 

    event TokenTransferred(
        address indexed from, 
        address indexed to, 
        IERC20 indexed token, 
        uint amount
    );

    event TokenMaxTransferred(
        address indexed from, 
        address indexed to,
        IERC20 indexed token,
        uint amount, 
        uint remainingAmount
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

    /**
     * @dev Transfers as much as possible up to the input amount.  Call does not fail - will transfer 0 if that's all that's possible
     */
    function transferMax(
        address from,
        address to,
        IERC20 token,
        uint amount
    )
        public
        onlyWhitelisted
        returns (uint amountPaid, uint remainingAmount) 
    {
        // check how much the transferer is authorized to send on behalf of the payor
        uint authorizedAmount = token.allowance(from, address(this));
        uint availableBalance = token.balanceOf(from);
        amountPaid = Math.min(amount, Math.min(authorizedAmount, availableBalance));

        if (amountPaid > 0) {
            remainingAmount = amount - amountPaid;
            token.transferFrom(from, to, amountPaid);
            emit TokenMaxTransferred(from, to, token, amountPaid, remainingAmount);
        } else {
            remainingAmount = amount;
        }

        return (amountPaid, remainingAmount);
    }

}