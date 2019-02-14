pragma solidity ^0.5.0;

import "../accounts/Payable.sol";
import "../accounts/IAuthorizedTokenTransferer.sol";
import "../accounts/IAcceptsPayment.sol";
import "../payment/PaymentCredit.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title PaymentProcessor
 * @dev Encapsulates a relationship between a paying party, a payment recipient, which token 
 * is used as payment, and through what authorized transferer.  Allows the paying party to debit 
 * against a virtual credit, against a token balance of this contract's address, and finally against 
 * the paying party's address.
 */
contract PaymentProcessor is Payable, PaymentCredit {

    using SafeMath for uint;

    address private _transferer;
    address private _token;

    IAcceptsPayment private _acceptsPayment;

    event PaymentMade(
        address indexed from, 
        address indexed token, 
        uint amountPaid, 
        uint remainder
    );

    constructor (
        address payor,
        address transferer,
        address token,
        IAcceptsPayment acceptsPayment
    ) 
        Payable(payor)
        internal
    {
        _transferer = transferer;
        _token = token;
        _acceptsPayment = acceptsPayment;
    }

    function pay(uint paymentAmount) internal returns (uint amountPaid, uint remainder) {
        remainder = paymentAmount;
        remainder = _payFromCredit(remainder);
        remainder = _payFromTokenBalance(remainder);
        remainder = _payFromAuthorizedTransferer(remainder);

        amountPaid = paymentAmount - remainder;

        emit PaymentMade(
            getPayor(),
            _token,
            amountPaid, 
            remainder);
        
        return (amountPaid, remainder);
    }




    /***************  WITHDRAW FUNCTIONS - TOKEN BALANCE ***********/

    /**
     * @dev Allows the payor to transfer any erc20 token held in this contract.
     * @param token The address of the ERC20 token to withdraw
     * @param amount The balance amount to withdraw
     */
    function transferTokenTo(address to, address token, uint amount) public onlyPayor {
        require(amount > 0);
        require(token != address(0));
        IERC20 tokenContract = IERC20(token);
        tokenContract.transfer(to, amount);
    }




    /***************  PAYMENT FUNCTIONS (CREDIT, TOKEN BALANCE, AUTHORIZED TRANSFER)  ***********/

    /**
     * @dev Gives the payor a mechanism to pay their debit against the virtual credit issued by the payee.
     */
    function _payFromCredit(
        uint amount
    ) 
        private 
        returns (uint) 
    {
        uint credit = getCredit();

        if (amount == 0 || credit == 0)
            return amount;

        uint remainder;

        // the case where there is no remainder
        if (amount < credit) {
            remainder = 0;
            _setCredit(credit - amount);
        }
        else if (amount > credit) {
            // we don’t need to transfer tokens from the payee back to itself, 
            // so simply adjusting credit balance is sufficient
            remainder = amount - credit;
            _setCredit(0);
        }
        else {
            remainder = 0;
            _setCredit(0);
        }
        return remainder;
    }

    /**
     * @dev Anyone can transfer a token balance to this contract.  This function gives the payor 
     * a mechanism to pay their debit against their token balance.  The supported scenario is:
     * Payee transfers an amount of token as a refund, promotion, coupon, credit, etc.  This contract 
     * holds that token in escrow, only withdrawable by the payor.
     */
    function _payFromTokenBalance(
        uint amount
    ) 
        private 
        returns (uint) 
    {
        if (amount == 0)
            return amount;

        IERC20 tokenContract = IERC20(_token);
        uint balance = tokenContract.balanceOf(address(this));

        if (balance == 0)
            return amount;

        uint remainder;
        //address to = getPayee();

        // the case where there is no remainder
        if (amount <= balance) {
            remainder = 0;
            //tokenContract.transfer(to, amount);
            tokenContract.approve(address(_acceptsPayment), amount);
            _acceptsPayment.receiveToken(address(this), _token, amount);
        }
        else if (amount > balance) {
            remainder = amount - balance;
            //tokenContract.transfer(to, balance);
            tokenContract.approve(address(_acceptsPayment), balance);
            _acceptsPayment.receiveToken(address(this), _token, balance);
        }

        return remainder;
    }

    function _payFromAuthorizedTransferer(
        uint amount
    )
        private
        returns (uint) 
    {
        if (amount == 0)
            return amount;

        IERC20 tokenContract = IERC20(_token);

        // check how much the transferer is authorized to send on behalf of the payor
        uint authorizedAmount = tokenContract.allowance(getPayor(), _transferer);
        uint availableBalance = tokenContract.balanceOf(getPayor());
        uint amountToPay = Math.min(amount, Math.min(authorizedAmount, availableBalance));

        _acceptsPayment.receiveToken(getPayor(), _token, amountToPay);

        uint remainder = amount - amountToPay;
        return remainder;
    }
    /** end *************  PAYMENT FUNCTIONS (CREDIT, TOKEN BALANCE, AUTHORIZED TRANSFER)  ***********/

}