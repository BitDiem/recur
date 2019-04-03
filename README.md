# Recur - Recurring Payments on Ethereum
Recur is a smart contract platform for enabling recurring ERC20 token payments on the Ethereum blockchain.  All contracts are written in Solidity.  Recurring payments can encompass: subscriptions, remittances, payroll, freelancer payments, stipends, token vesting, etc.

## Features
The following features are available.  Not every feature needs to be used.  For example, you can create a remittance contract that doesn't feature the virtual credit functionality, while having a subscription contract that includes it since it makes sense in that context.

- [Create and destroy](#create-and-destroy)
- [Transfer payment liability](#transfer-payment-liability)
- [Transfer payment recipient](#transfer-payment-recipient)
- [Multiple funding sources](#multiple-funding-sources)
- [Escrow availability](#escrow-availability)
- [Flexible refund options](#flexible-refund-options)
  - [Virtual credit](#virtual-credit)
- [Extensible payment due logic](#extensible-payment-due-logic)
- [Efficient/cheap payment processing](#efficient/cheap-payment-processing)

### Create and destroy
Create a recurring payment contract which specifies a payor, payee, an ERC20 token address, and a PaymentObligation contract which will determine how much is due, and when.  At any time, the payor or the payee can cancel the contract, which in turn selfdestruct both the contract and the linked PaymentObligation contract.

### Transfer payment liability
When creating a recurring payment contract, you must specify an address for the "payor".  The payor is the address where the ERC20 tokens will be withdrawn from at the time of payment processing.  The payor has the ability to transfer that payment obligation to another address at any time - pending that target address calling an function that accepts reponsibility for the payment obligation.  See (recur/contracts/accounts/Payable.sol).

### Transfer payment recipient
You must also specify an address - the "payee" address - that will receive the ERC20 tokens at the time of payment processing.  The payee may modify the address payment will be received at at any time.

### Multiple funding sources
A recurring payment contract can be configured to include up to three possible funding sources to use when processing payment:
1. A virtual Credit amount
2. The subscription address' own balance of the specified ERC20 payment token
3. The specified payor's address

### Flexible refund options
For certain scenarios, such as subscriptions, the payment receipient may desire to issue a refund - perhaps to alleviate a customer dispute, or as part of a promotional credit or marketing effort, etc.  For such scenarios, the payment recipient can send ERC20 tokens directly to the recurring payment contract, where only the payor has rights to withdraw them.  Alternatively, the payment recipient can add to a virtual credit balance.

#### Virtual Credit
The virtual credit is represented as a uint value that can be incremented or decremented by the payee (i.e. the service provider).  The service provider can use this to issue a refund that has no transferable value (i.e. can only be applied to future service payments).

### Subscription payment token balance
There may be times when the service provider desires to issue a refund or real (non-virtual) credit to the subscriber.  In such instances, they should transfer the payment token directly to the subscription address.  The subscriptions token balance will be used for future payments.

The payor address can withdraw any tokens held withing the subscription address, at any time.  In other words, the subscription contract is treated like a token escrow that only the subscriber can withdraw from.

### Payor's address
The last funding source is the specified payor's address.  The subscriber specifies which address token payments will come from.  That address must call the ERC20 approve function in order for the token transfer at the time of payment processing.

## Opt-out
The subscription contract uses an opt-out model.  Tokens will automatically be transferred from the payor's address in accordance with the specified payment terms.  The user may opt-out at any time by cancelling the subscription.  There is no "pause" functionality - we recommend cancelling the subscription and creating a new one to effect the same result.

Note that both the payor and the payee can opt-out of the subscription.  The payor will commonly opt-out when they no longer want the provider's service.  The payee will commonly opt-out in scenarios in which the user is X days, or Y amount, past due on their payments.

## Feature set
- Create a subscription
- Specify payment terms: fixed intervals; same day every week, month, year
- End a subscription
- Transfer payment obligation from one address to another
- Transfer payment recipient address from one address to another
- Pay from virtual credits
- Pay from wallet balance
- Payment trigger function can be called from any address
