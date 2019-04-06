pragma solidity ^0.5.0;

import "./SubscriptionData.sol";
import "../../accounts/Payable.sol";
import "../../accounts/Receivable.sol";
import "../../payment/PayFromCredit.sol";
import "../../payment/PayFromContract.sol";
import "../../payment/PayFromAddress.sol";
import "../../payment/balances/PaymentDebt.sol";
import "../../token/TokensWithdrawable.sol";
import "../../terms/PaymentObligation.sol";
import "../../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title StandardSubscription
 * @dev Contract orchestrates the determination of an amount of IERC20 tokens due, and the ability to pay that amount due 
 * by transferring the correct amount of tokens from a subscriber to the party that is offering the subscription or services.
 *
 * Three possible funding sources, in execution order, can be used to cover the payment amount:
 *   1) A virtual Credit amount
 *   2) This contract's own balance of the specified ERC20 payment token
 *   3) The specified payor's address
 */
contract StandardSubscription is 
    SubscriptionData,
    Payable, 
    Receivable, 
    PayFromCredit, 
    PayFromContract,
    PayFromAddress,
    PaymentDebt, 
    TokensWithdrawable
{
    
    event PaymentProcessed(uint totalPaid, uint remainder);
    event SubscriptionEnded(address endedBy);

    constructor (
        address payor,
        address payee,
        IAuthorizedTokenTransferer authorizedTransferer,
        IERC20 token,
        PaymentObligation paymentObligation
    )
        Payable(payor)
        Receivable(payee)
        SubscriptionData(paymentObligation, token, authorizedTransferer)
        public 
    {
    }

    /**
     * @dev Request the full amount due from the payment terms (PaymentObligation).  Attempt to pay as much as possible 
     * via the 3 funding sources (credit, internal token balance, payee token balance).
     */
    function payFullAmountDue() public {
        uint amountDue = getPaymentObligation().currentAmountDue() + getOutstandingAmount();
        uint remainder = _pay(amountDue);
        _setOutstandingAmount(remainder);
    }

    /**
     * @dev End the subscription, destroying the contract, reclaming gas and transferring any contained ETH to the payor's address.
     */
    function end() public {
        require(isPayor() || isPayee());
        address payable balanceRecipient = address(uint160(getPayor()));
        getPaymentObligation().destroy(balanceRecipient);
        emit SubscriptionEnded(msg.sender);
        selfdestruct(balanceRecipient);
    }

    function _pay(uint paymentAmount) private returns (uint remainder) {
        remainder = paymentAmount;
        remainder = _payFromCredit(remainder);
        remainder = _payFromTokenBalance(remainder);
        remainder = _payFromAuthorizedTransferer(remainder);

        uint amountPaid = paymentAmount - remainder;

        emit PaymentProcessed(amountPaid, remainder);
        
        return remainder;
    }

    function _payFromTokenBalance(uint amount) private returns (uint) {
        return _payFromTokenBalance(getPayee(), getToken(), amount);
    }

    function _payFromAuthorizedTransferer(uint amount) private returns (uint) {
        return _payFromAddress(getPayor(), getPayee(), getToken(), amount, getAuthorizedTransferer());
    }

}