//const MetaCoin = artifacts.require("MetaCoin");

const MockERC20 = artifacts.require('MockERC20')
const MockRecurringPaymentTerms = artifacts.require('MockRecurringPaymentTerms')
const StandardSubscription = artifacts.require('StandardSubscription')
const AuthorizedTokenTransferer = artifacts.require('AuthorizedTokenTransferer')
const assert = require('assert')

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

contract("Testing", accounts => {

    let tokenBank;
    let payor;
    let payee;
    let mockERC20;
    let paymentTerms;
    let authorizedTokenTransferer;
    let subscription;

    let creditBalance;
    let subscriptionTokenBalance;
    let payorTokenBalance;
    let payeeTokenBalance;
    const startingTokenBalance = 100;

    beforeEach(async function() {   
        tokenBank = accounts[0];
        payor = accounts[1];
        payee = accounts[2];
        mockERC20 = await MockERC20.new("Mock ERC20", "MERC20", tokenBank, startingTokenBalance * 100);
        await mockERC20.transfer(payor, startingTokenBalance, {from: tokenBank});
        paymentTerms = await MockRecurringPaymentTerms.new(1, 1, 0);
        authorizedTokenTransferer = await AuthorizedTokenTransferer.new();
        subscription = await StandardSubscription.new(
            payor,
            payee,
            authorizedTokenTransferer.address, 
            mockERC20.address, 
            paymentTerms.address);

        await authorizedTokenTransferer.addToWhitelist(subscription.address);
        await mockERC20.approve(authorizedTokenTransferer.address, 10000000, {from: payor});
      })

  it("should not pay when no time has transpired", async () => {  
    await subscription.payCurrentAmountDue();
    await subscription.payCurrentAmountDue();

    await updateState();

    assert.equal(payorTokenBalance, startingTokenBalance, "Unexpected value");
    assert.equal(payeeTokenBalance, 0, "Unexpected value");
  });

  it("should deduct from credits (2) when available", async () => {    
    // add 2 credits to the subscription
    await subscription.addCredit(2, {from: payee});
    await updateState();
    assert.equal(creditBalance, 2, "2 credits");

    await advance(1);
    assert.equal(creditBalance, 1, "1 credits");

    await advance(2);
    assert.equal(creditBalance, 0, "0 credits");

    await advance(3);
    assert.equal(creditBalance, 0, "0 credits");
  });

  it("should deduct from subscription wallet token balance when available", async () => {    
    // transfer a token balance to the subscription
    await mockERC20.transfer(subscription.address, 2, {from: tokenBank});
    await updateState();
  
    assert.equal(subscriptionTokenBalance, 2, "Unexpected value");
    assert.equal(payorTokenBalance, startingTokenBalance, "Unexpected value");
    assert.equal(payeeTokenBalance, 0, "Unexpected value");

    await advance(1);
    assert.equal(subscriptionTokenBalance, 1, "Unexpected value");
    assert.equal(payorTokenBalance, startingTokenBalance, "Unexpected value");
    assert.equal(payeeTokenBalance, 1, "Unexpected value");

    await advance(2);
    assert.equal(subscriptionTokenBalance, 0, "Unexpected value");
    assert.equal(payorTokenBalance, startingTokenBalance, "Unexpected value");
    assert.equal(payeeTokenBalance, 2, "Unexpected value");

    await advance(3);
    assert.equal(subscriptionTokenBalance, 0, "Unexpected value");
    assert.equal(payorTokenBalance, startingTokenBalance - 1, "Unexpected value");
    assert.equal(payeeTokenBalance, 3, "Unexpected value");
  });

  it("should use all available resources - credits, balance, wallet", async () => {    
    // transfer a token balance to the subscription
    await mockERC20.transfer(subscription.address, 2, {from: tokenBank});

    // add credits
    await subscription.addCredit(2, {from: payee});

    await advance(20);

    assert.equal(creditBalance, 0, "Credit");
    assert.equal(subscriptionTokenBalance, 0, "Subscription balance");

    // starting balance - 20 - 4 (2 credits and 2 from subscription balance)
    assert.equal(payorTokenBalance, startingTokenBalance - 16, "Payor balance");

    // 20 less 2 credits, which are always virtual
    assert.equal(payeeTokenBalance, 18, "Payee balance");
  });

  it("should track debt", async () => {    
    await advance(110);
    assertState(0, 0, 0, 100);

    await mockERC20.transfer(payor, 15, {from: tokenBank});
    // total 115 ever held by payor

    await advance(120);
    assertState(0, 0, 0, 115);

    await mockERC20.transfer(payor, 20, {from: tokenBank});
    // total 135 ever held by payor

    await advance(130);
    assertState(0, 0, 5, 130);
  });

  async function updateState() {
    creditBalance = (await subscription.getCredit()).valueOf();
    subscriptionTokenBalance = (await mockERC20.balanceOf(subscription.address)).valueOf();
    payorTokenBalance = (await mockERC20.balanceOf(payor)).valueOf();
    payeeTokenBalance = (await mockERC20.balanceOf(payee)).valueOf();
  }

  async function advance(intervals) {
    await paymentTerms.setCurrentTimeStamp(intervals);
    await subscription.payCurrentAmountDue();
    await updateState();    
  }

  function assertState(
    expectedCredit, 
    expectedSubscriptionBalance, 
    expectedPayorBalance, 
    expectedPayeeBalance //, 
    //expectedDebt
  ) {
    assert.equal(creditBalance, expectedCredit, "Credit balance");
    assert.equal(subscriptionTokenBalance, expectedSubscriptionBalance, "Subscription balance");
    assert.equal(payorTokenBalance, expectedPayorBalance, "Payor balance");
    assert.equal(payeeTokenBalance, expectedPayeeBalance, "Payee balance");
  }

});