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
        await mockERC20.transfer(payor.address, startingTokenBalance, {from: tokenBank});
        paymentTerms = await MockRecurringPaymentTerms.new(1, 1, 0);
        authorizedTokenTransferer = await AuthorizedTokenTransferer.new();
        subscription = await StandardSubscription.new(
            payor,
            payee,
            authorizedTokenTransferer.address, 
            mockERC20.address, 
            paymentTerms.address);

        await authorizedTokenTransferer.addToWhitelist(subscription.address);
        await mockERC20.approve(authorizedTokenTransferer.address, startingTokenBalance, {from: payor});
      })

  it("should not pay when no time has transpired", async () => {  
    await subscription.payCurrentAmountDue();
    await subscription.payCurrentAmountDue();

    await updateState();

    //payorTokenBalance = await mockERC20.balanceOf(payor);
    //payeeTokenBalance = await mockERC20.balanceOf(payee);

    assert.equal(payorTokenBalance, startingTokenBalance, "Unexpected value");
    assert.equal(payeeTokenBalance, 0, "Unexpected value");
  });

  it("should deduct from credits (2) when available", async () => {    
    // add 2 credits to the subscription
    await subscription.addCredit(2, {from: payee});
    creditBalance = await subscription.getCredit();
    assert.equal(creditBalance.valueOf(), 2, "2 credits");

    await paymentTerms.setCurrentTimeStamp(1);
    await subscription.payCurrentAmountDue();
    creditBalance = await subscription.getCredit();
    assert.equal(creditBalance.valueOf(), 1, "1 credits");

    await paymentTerms.setCurrentTimeStamp(2);
    await subscription.payCurrentAmountDue();
    creditBalance = await subscription.getCredit();
    assert.equal(creditBalance.valueOf(), 0, "0 credits");

    await paymentTerms.setCurrentTimeStamp(3);
    await subscription.payCurrentAmountDue();
    creditBalance = await subscription.getCredit();
    assert.equal(creditBalance.valueOf(), 0, "0 credits");
  });

  it("should deduct from subscription wallet token balance", async () => {    
    // transfer a token balance to the subscription
    await mockERC20.transfer(subscription.address, 2, {from: tokenBank});
    await updateState();
    //subscriptionTokenBalance = await mockERC20.balanceOf(subscription);
    //payeeTokenBalance = await mockERC20.balanceOf(payee);
    assert.equal(subscriptionTokenBalance, 2, "Unexpected value");
    assert.equal(payorTokenBalance, startingTokenBalance, "Unexpected value");
    assert.equal(payeeTokenBalance, 0, "Unexpected value");

    await paymentTerms.setCurrentTimeStamp(1);
    await subscription.payCurrentAmountDue();
    await updateState();
    //subscriptionTokenBalance = await mockERC20.balanceOf(subscription);
    //payeeTokenBalance = await mockERC20.balanceOf(payee);
    assert.equal(subscriptionTokenBalance, 1, "Unexpected value");
    assert.equal(payorTokenBalance, startingTokenBalance, "Unexpected value");
    assert.equal(payeeTokenBalance, 1, "Unexpected value");

    await paymentTerms.setCurrentTimeStamp(1);
    await subscription.payCurrentAmountDue();
    await updateState();

    assert.equal(subscriptionTokenBalance, 0, "Unexpected value");
    assert.equal(payorTokenBalance, startingTokenBalance, "Unexpected value");
    assert.equal(payeeTokenBalance, 2, "Unexpected value");

    await paymentTerms.setCurrentTimeStamp(1);
    await subscription.payCurrentAmountDue();
    await updateState();

    assert.equal(subscriptionTokenBalance, 0, "Unexpected value");
    assert.equal(payorTokenBalance, startingTokenBalance - 1, "Unexpected value");
    assert.equal(payeeTokenBalance, 3, "Unexpected value");
  });

  /*it("should use all available resources - credits, balance, wallet", async () => {    
    // transfer a token balance to the subscription
    await mockERC20.transfer(subscription.address, 1, {from: tokenBank});

    // add credits
    await subscription.addCredit(2, {from: payee});

    await paymentTerms.setCurrentTimeStamp(20);
    await subscription.payCurrentAmountDue();

    creditBalance = await subscription.getCredit();
    assert.equal(creditBalance.valueOf(), 3, "No credit to start");

  });*/

  async function updateState() {
    creditBalance = (await subscription.getCredit()).valueOf();
    subscriptionTokenBalance = (await mockERC20.balanceOf(subscription.address)).valueOf();
    payorTokenBalance = (await mockERC20.balanceOf(payor.address)).valueOf();
    payeeTokenBalance = (await mockERC20.balanceOf(payee.address)).valueOf();
  }

  async function advance(intervals) {
    await paymentTerms.setCurrentTimeStamp(intervals);
    await subscription.payCurrentAmountDue();
    await updateState();    
  }

});