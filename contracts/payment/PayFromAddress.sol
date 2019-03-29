pragma solidity ^0.5.0;

import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title PayFromAddress
 * @dev Transfers an ERC20 token from one address to another by proxying the transfer to a provided IAuthorizedTokenTransferer.
 * Emits an event on successful transfer.
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
        returns (uint) 
    {
        if (amount == 0) {
            return amount;
        } else {
            (uint paid, uint unpaid) = authorizedTransferer.transferMax(payor, payee, token, amount);
            emit PaidFromAddress(payor, payee, token, paid, unpaid);
            return unpaid;
        }
    }

}