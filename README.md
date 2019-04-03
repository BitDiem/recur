# Recur - Recurring Payments on Ethereum
Recur is a smart contract platform for enabling recurring ERC20 token payments on the Ethereum blockchain.  All contracts are written in Solidity.  Recurring payments can encompass: subscriptions, remittances, payroll, freelancer payments, stipends, token vesting, etc.

## Features
The following features are available.  Not every feature needs to be used.  For example, you can create a remittance contract that doesn't feature the virtual credit functionality, while having a subscription contract that includes it since it makes sense in that context.

- [Create and destroy](#create-and-destroy)
- [Transfer payment liability](#transfer-payment-liability)
- [Transfer payment recipient](#transfer-payment-recipient)
- [Multiple funding sources](#multiple-funding-sources)
- [Flexible refund options](#flexible-refund-options)
  - [Escrowed refund](#escrowed-refund)
  - [Virtual credit](#virtual-credit)
- [Extensible payment due logic](#extensible-payment-due-logic)
- [Debt tracking](#debt-tracking)
- [Efficient/cheap payment processing](#efficient/cheap-payment-processing)
- [Open payment process trigger](#open-payment-process-trigger)
- [Convenient "frontend" factories](#convenient-"frontend"-factories)

### Create and destroy
Create a recurring payment contract which specifies a payor, payee, an ERC20 token address, and a [PaymentObligation](contracts/terms/PaymentObligation.sol) contract which will determine how much is due, and when.  

The payor or the payee can cancel the contract at any time, which in turn selfdestructs both the contract and the linked PaymentObligation contract.  The payor will commonly cancel when they no longer want the provider's service.  The payee will commonly cancel in scenarios in which the user is X days, or Y amount, past due on their payments.

There is no "pause" functionality - we recommend cancelling the recurring payment contract and creating a new one to effect the same result.

### Transfer payment liability
When creating a recurring payment contract, you must specify an address for the "payor".  The payor is the address where the ERC20 tokens will be withdrawn from at the time of payment processing.  The payor has the ability to transfer that payment obligation to another address at any time - pending that target address calling an function that accepts reponsibility for the payment obligation.  See [Payable.sol](contracts/accounts/Payable.sol).

### Transfer payment recipient
You must also specify an address - the "payee" address - that will receive the ERC20 tokens at the time of payment processing.  The payee may modify the address payment will be received at at any time.  See [Receivable.sol](contracts/accounts/Receivable.sol).

### Multiple funding sources
A recurring payment contract can be configured to include multiple possible funding sources to draw from when processing payment:
1. A virtual credit balance
2. The subscription address' own balance of the specified ERC20 payment token
3. The specified payor's address

### Flexible refund options
For certain scenarios, such as subscriptions, the payment recipient may desire to issue a refund - perhaps to alleviate a customer dispute, or as part of a promotional credit or marketing effort, etc.  For such scenarios, the payment recipient has the option of issuing a refund as transferable ERC20 tokens, or as a virtual non-transferable credit.

#### Escrowed refund
The payee can refund the payor at any time by simply sending ERC20 tokens directly to the recurring payment contract.  Only the payor has the rights to withdraw those tokens from the contract.  The contract thus serves as an escrow where only one party has rights to withdraw.  The payor can choose to leave the tokens in the escrow, and those tokens will be applied toward future payments.  See [TokenEscrow.sol](contracts/payment/escrow/TokenEscrow.sol).

#### Virtual credit
The virtual credit is represented as a uint value that can be incremented or decremented by the payee (i.e. the service provider).  The service provider can use this to issue a refund that has no transferable value (i.e. can only be applied to future service payments).  Future payments will deduct against this virtual credit balance.  See [PaymentCredit.sol](contracts/payment/balances/PaymentCredit.sol).

### Extensible payment due logic
The recurring payment contract holds a reference to a PaymentObligation contract which contains all logic to determine the specifics of how much and when payment is due.  Create contracts that inherit from the base [PaymentObligation.sol](contracts/terms/PaymentObligation.sol) to write new logic for determining payment due criteria.  Included in this release are several date-based payment terms:
- [Fixed intervals](contracts/terms/datetime/Seconds.sol) - where payment due recurrence is measured in N seconds intervals
- [Same day different month/year](contracts/terms/datetime/FixedDate.sol) - where payment is processed at the exact same day and time (hour/minute/second) but on subsequent months, quarters, years, etc.

### Debt tracking
When payment is processed, the contract will pay as much of the outstanding amount as possible.  Any unpaid amount will be added to a [debt balance](contracts/payment/balances/PaymentDebt.sol).

### Efficient/cheap payment processing
The code that determines when payment is due has been measured to be efficient in terms of gas cost, resulting in cheap payment processing (under 10 cents at reasonable gas prices).

### Open payment process trigger
The function to trigger payment processing can be called by any address.  This allows DAPP creators to fill the role of a "payemnt processor" in exchange for bearing the cost of calling the payment process function.  The effective use of Events in our code allows such a DAPP creator to build an efficient payment processing service that only calls the function when needed, after the payment due date has elapsed (perhaps with a small buffer of 30 seconds to 1 minute after payment due).

### Convenient "frontend" factories
Leverage deployed "[frontends](contracts/frontend/SubscriptionFrontEnd.sol)" that provide convenience methods for spawning new recurring payment contracts.  The convenience methods take care of wiring together various contracts as well as configuring permissions and roles correctly for you.
