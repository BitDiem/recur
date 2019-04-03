pragma solidity ^0.5.0;

import "../subscription/SubscriptionData.sol";
import "../accounts/Payable.sol";
import "../accounts/Receivable.sol";
import "../payment/PayFromAddress.sol";
import "../payment/balances/PaymentDebt.sol";
import "../terms/PaymentObligation.sol";
import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title Remittance
 * @dev Contract that sends an amount of IERC20 tokens at specific times per the criteria defined in the 
 * provided PaymentObligation.  Tokens are transferred from payor to payee.
 */
contract Remittance is 
    SubscriptionData,
    Payable, 
    Receivable, 
    PayFromAddress,
    PaymentDebt 
{
    
    event PaymentProcessed(uint totalPaid, uint remainder);
    event RemittanceEnded(address endedBy);

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
     * @dev Request the full amount due from the payment terms (PaymentObligation).  Pay the amount due by transferring tokens 
     * from payor to payee via the provided authorized token transferer.
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
        emit RemittanceEnded(msg.sender);
        selfdestruct(balanceRecipient);
    }

    function _pay(uint paymentAmount) private returns (uint remainder) {
        remainder = paymentAmount;
        remainder = _payFromAuthorizedTransferer(remainder);

        uint amountPaid = paymentAmount - remainder;

        emit PaymentProcessed(amountPaid, remainder);
        
        return remainder;
    }

    function _payFromAuthorizedTransferer(uint amount) private returns (uint) {
        return _payFromAddress(getPayor(), getPayee(), getToken(), amount, getAuthorizedTransferer());
    }

}