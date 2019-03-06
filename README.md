# BitDiem Subscriptions
Smart contracts to enable recurring ERC20 token payments on the Ethereum blockchain.  Contracts are written in Solidity.

## Multiple funding sources
When a payment is processed, there are three possible funding sources that can be used to cover the payment amount:
1. A virtual Credit amount
2. The subscription address' own balance of the specified ERC20 payment token
3. The specified payor's address

### Virtual Credit
The virtual credit is represented as a uint value that can be incremented or decremented by the payee (i.e. the service provider).

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