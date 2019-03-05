const MockERC20 = artifacts.require('MockERC20')
const MockRecurringPaymentTerms = artifacts.require('MockRecurringPaymentTerms')
const StandardSubscription = artifacts.require('StandardSubscription')
const SubscriptionFactory = artifacts.require('SubscriptionFactory')
const SubscriptionFrontEnd = artifacts.require('SubscriptionFrontEnd')
const AuthorizedTokenTransferer = artifacts.require('AuthorizedTokenTransferer')
const assert = require('assert')

contract("FrontEnd Test", accounts => {

    let tokenBank;
    let payor;
    let payee;
    let mockERC20;
    let paymentTerms;
    let authorizedTokenTransferer;
    let subscription;
    let subscriptionFactory
    let subscriptionFrontEnd;

    let creditBalance;
    let subscriptionTokenBalance;
    let payorTokenBalance;
    let payeeTokenBalance;
    let currentDebt;
    const startingTokenBalance = 100;

    beforeEach(async function() {   
        tokenBank = accounts[0];
        payor = accounts[1];
        payee = accounts[2];

        mockERC20 = await MockERC20.new("Mock ERC20", "MERC20", tokenBank, startingTokenBalance * 2);
        await mockERC20.transfer(payor, startingTokenBalance, {from: tokenBank});

        paymentTerms = await MockRecurringPaymentTerms.new(1, 1, 0);
        authorizedTokenTransferer = await AuthorizedTokenTransferer.new();
        subscriptionFactory = await SubscriptionFactory.new();
        subscriptionFrontEnd = await SubscriptionFrontEnd.new(subscriptionFactory.address, authorizedTokenTransferer.address);
        await authorizedTokenTransferer.addWhitelistAdmin(subscriptionFrontEnd.address);

        let transaction = await subscriptionFrontEnd.createSubscription(
          payee,
          mockERC20.address,
          paymentTerms.address,
          {from: payor}
        );

        let log = transaction.logs[0];
        let subscriptionAddress = log.args.subscriptionAddress;
        subscription = await StandardSubscription.at(subscriptionAddress);

        await paymentTerms.transferPrimary(subscription.address);
        await mockERC20.approve(authorizedTokenTransferer.address, 10000000, {from: payor});
      })

  it("should not pay when no time has transpired", async () => {  
    await subscription.payFullAmountDue();
    await subscription.payFullAmountDue();
    await updateState();
    assertState(startingTokenBalance, 0, 0, 0, 0);
  });

  it("should pay normally when payor address has a balance", async () => {    
    await advance(7);
    assertState(startingTokenBalance - 7, 7, 0, 0, 0);
  });

  it("should deduct from credits when available", async () => {    
    // add 2 credits to the subscription
    await subscription.addCredit(2, {from: payee});
    await updateState();
    assertState(startingTokenBalance, 0, 2, 0, 0);

    await advance(1);
    assertState(startingTokenBalance, 0, 1, 0, 0);

    await advance(2);
    assertState(startingTokenBalance, 0, 0, 0, 0);
  });

  it("should deduct from subscription wallet token balance when available", async () => {    
    // transfer a token balance to the subscription
    await mockERC20.transfer(subscription.address, 2, {from: tokenBank});
    await updateState();
    assertState(startingTokenBalance, 0, 0, 2, 0);

    await advance(1);
    assertState(startingTokenBalance, 1, 0, 1, 0);

    await advance(2);
    assertState(startingTokenBalance, 2, 0, 0, 0);
  });

  it("should use all available resources - credits, balance, wallet", async () => {    
    // transfer a token balance to the subscription
    await mockERC20.transfer(subscription.address, 2, {from: tokenBank});
    // add credits
    await subscription.addCredit(2, {from: payee});
    await advance(20);

    // payor: starting balance - 20 - 4 (2 credits and 2 from subscription balance)
    // payee: 20 less 2 credits, which are always virtual
    assertState(startingTokenBalance - 16, 18, 0, 0, 0)
    //assertState(99, 99, 99, 99, 99); //trigger fail on purpose to see all events fired
  });

  it("should track debt", async () => {    
    await advance(110);
    assertState(0, 100, 0, 0, 10);

    await mockERC20.transfer(payor, 15, {from: tokenBank});
    await updateState();
    assertState(15, 100, 0, 0, 10);
    // total 115 ever held by payor

    await advance(120);
    assertState(0, 115, 0, 0, 5);

    await mockERC20.transfer(payor, 20, {from: tokenBank});
    await updateState();
    assertState(20, 115, 0, 0, 5);
    // total 135 ever held by payor

    await advance(130);
    assertState(5, 130, 0, 0, 0);
  });




  async function advance(intervals) {
    await paymentTerms.setCurrentTimeStamp(intervals);
    await subscription.payFullAmountDue();
    await updateState();    
  }

  async function updateState() {
    creditBalance = (await subscription.getCredit()).valueOf();
    subscriptionTokenBalance = (await mockERC20.balanceOf(subscription.address)).valueOf();
    payorTokenBalance = (await mockERC20.balanceOf(payor)).valueOf();
    payeeTokenBalance = (await mockERC20.balanceOf(payee)).valueOf();
    currentDebt = (await subscription.getOutstandingAmount()).valueOf();
  }

  function assertState(
    expectedPayorBalance,
    expectedPayeeBalance,
    expectedCredit,
    expectedSubscriptionBalance,
    expectedDebt
  ) {
    assert.equal(payorTokenBalance, expectedPayorBalance, "Payor balance");
    assert.equal(payeeTokenBalance, expectedPayeeBalance, "Payee balance");
    assert.equal(creditBalance, expectedCredit, "Credit balance");
    assert.equal(subscriptionTokenBalance, expectedSubscriptionBalance, "Subscription balance");
    assert.equal(currentDebt, expectedDebt, "Subscription debt");
  }

  function printState() {
    console.log("Payor balance: ", payorTokenBalance.toString(10));
    console.log("Payee balance: ", payeeTokenBalance.toString(10));
    console.log("Credit balance: ", creditBalance.toString(10));
    console.log("Subscription balance: ", subscriptionTokenBalance.toString(10));
    console.log("Subscription debt: ", currentDebt.toString(10));
    console.log("____****_____");
  }

});