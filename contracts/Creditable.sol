pragma solidity ^0.5.0;

import "./IAuthorizedTokenTransferer.sol";
import "./Payable.sol";
import "./Receivable.sol";
import "./SubscriptionPaymentInfo.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/ownership/Secondary.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title Creditable
 * @dev Allows a payee to add credit that the payor can use to:
 * A. pay a debit with or
 * B. withdraw a corresponding token in the amount of credit available against
 */
contract Creditable is SubscriptionPaymentInfo {

    using SafeMath for uint;

    uint credit;

    event Credited(uint amount);
    event Debited(uint amount);
        
    constructor (
        address payor,
        address payee,
        IAuthorizedTokenTransferer authorizedTransferer,
        address token
    ) 
        SubscriptionPaymentInfo(payor, payee, authorizedTransferer, token)
        internal
    {}

    function getCredit() public view returns (uint) {
        return credit;
    }

    function addCredit(uint amount) public onlyPayee {
        require(amount > 0);
        credit = credit.add(amount);
        emit Credited(amount);
    }

    function withdrawCredit(uint amount) public onlyPayor {
        return _withdrawCredit(token(), amount, getPayee(), getPayor(), authorizedTransferer());
    }

    function _withdrawCredit(
        address token, 
        uint amount, 
        address from, 
        address to, 
        IAuthorizedTokenTransferer authorizedTransferer
    )
        private
    {
        require(amount > 0);
        require(amount <= credit);
        credit = credit.sub(amount);
        authorizedTransferer.transfer(from, to, token, amount);
        emit Debited(amount);
    }

    function payFromCredit(
        uint amount
    ) 
        internal 
        returns (uint) 
    {
        if (amount == 0 || credit == 0)
            return amount;

        uint remainder;

        // the case where there is no remainder
        if (amount < credit) {
            remainder = 0;
            credit = credit.sub(amount);
        }
        else if (amount > credit) {
            // we don’t need to transfer tokens from the payee back to itself, 
            // so simply adjusting credit balance is sufficient
            remainder = amount - credit;
            credit = 0;
        }
        else {
            credit = 0;
            remainder = 0;
        }
        return remainder;
    }

}