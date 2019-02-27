pragma solidity ^0.5.0;

import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title PayFromAddress
 * @dev TODO: Write
 */
contract PayFromAddress {

    event PaidFromAddress(
        address indexed payor, 
        address indexed payee,
        IERC20 indexed token,
        uint amountPaid, 
        uint amountLeftUnpaid
    );

    /**
     * @dev Pays an arbitrary non-zero amount against the funding source address
     */
    function _payFromAddress(
        address payor,
        address payee,
        IERC20 token,
        uint amount,
        IAuthorizedTokenTransferer authorizedTransferer
    )
        internal
        returns (uint remainder) 
    {
        if (amount == 0)
            return amount;

        // check how much the transferer is authorized to send on behalf of the payor
        uint authorizedAmount = token.allowance(payor, address(authorizedTransferer));
        uint availableBalance = token.balanceOf(payor);
        uint amountToPay = Math.min(amount, Math.min(authorizedAmount, availableBalance));

        if (amountToPay > 0) {
            authorizedTransferer.transfer(payor, payee, token, amountToPay);
            remainder = amount - amountToPay;
            emit PaidFromAddress(payor, payee, token, amountToPay, remainder);
        } else {
            remainder = amount;
        }

        return remainder;
    }

}