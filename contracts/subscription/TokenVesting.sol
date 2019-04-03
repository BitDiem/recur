pragma solidity ^0.5.0;

import "../subscription/TokenVestingData.sol";
import "../accounts/Receivable.sol";
import "../payment/PayFromContract.sol";
import "../payment/balances/PaymentDebt.sol";
import "../terms/PaymentObligation.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title TokenVesting
 * @dev Contract orchestrates the determination of an amount of IERC20 tokens due, and the ability to pay that amount due 
 * by transferring the correct amount of tokens from a subscriber to the party that is offering the subscription or services.
 */
contract TokenVesting is
    Ownable,
    TokenVestingData,
    Receivable, 
    PayFromContract,
    PaymentDebt 
{

    uint constant UINT_MAX = ~uint(0);
    
    event PaymentProcessed(uint totalPaid, uint remainder);
    event TokenVestingEnded(address endedBy, uint unvestedAmount);

    constructor (
        address payee,
        IERC20 token,
        PaymentObligation paymentObligation
    )
        Receivable(payee)
        TokenVestingData(paymentObligation, token)
        public 
    {
    }

    /**
     * @dev Request the full amount due from the vesting terms (PaymentObligation).  Attempt to pay as much as possible 
     * based on the current amount of token held by the contract.
     */
    function payFullAmountDue() public {
        uint amountDue = getPaymentObligation().currentAmountDue() + getOutstandingAmount();
        uint remainder = _pay(amountDue);
        _setOutstandingAmount(remainder);
    }

    /**
     * @dev End token vesting, destroying the contract, reclaming gas and transferring any 
     * contained ETH as well as unvested tokens to the contract owner.
     */
    function end() public {
        require(isOwner() || isPayee());

        // release any held ETH to the contract owner
        address payable balanceRecipient = address(uint160(owner()));
        getPaymentObligation().destroy(balanceRecipient);

        // release the remaining unvested tokens back to the contract owner
        uint remainder = _payFromTokenBalance(owner(), getToken(), UINT_MAX);  // TODO: the 3rd parameter should be largest possible uint value
        uint unvestedAmount = UINT_MAX - remainder;

        emit TokenVestingEnded(msg.sender, unvestedAmount);
        selfdestruct(balanceRecipient);
    }

    function _pay(uint paymentAmount) private returns (uint remainder) {
        remainder = paymentAmount;
        remainder = _payFromTokenBalance(remainder);

        uint amountPaid = paymentAmount - remainder;

        emit PaymentProcessed(amountPaid, remainder);
        
        return remainder;
    }

    function _payFromTokenBalance(uint amount) private returns (uint) {
        return _payFromTokenBalance(getPayee(), getToken(), amount);
    }

}