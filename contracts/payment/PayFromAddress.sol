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