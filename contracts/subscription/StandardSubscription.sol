pragma solidity ^0.5.0;

import "../subscription/SubscriptionData.sol";
import "../accounts/Payable.sol";
import "../accounts/Receivable.sol";
import "../payment/PayFromCredit.sol";
import "../payment/PayFromContract.sol";
import "../payment/PayFromAddress.sol";
import "../payment/balances/PaymentDebt.sol";
import "../payment/escrow/TokenEscrow.sol";
import "../terms/PaymentObligation.sol";
import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title StandardSubscription
 * @dev TODO: write
 */
contract StandardSubscription is 
    SubscriptionData,
    Payable, 
    Receivable, 
    PayFromCredit, 
    PayFromContract,
    PayFromAddress,
    PaymentDebt, 
    TokenEscrow
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

    function payFullAmountDue() public {
        uint amountDue = getPaymentObligation().currentAmountDue() + getOutstandingAmount();
        uint remainder = _pay(amountDue);
        _setOutstandingAmount(remainder);
    }

    function endSubscription() public {
        require(getPayor() == msg.sender || getPayee() == msg.sender);
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