const MockERC20 = artifacts.require('MockERC20')
const MockRecurringPaymentTerms = artifacts.require('MockRecurringPaymentTerms')
const StandardSubscription = artifacts.require('StandardSubscription')
const AuthorizedTokenTransferer = artifacts.require('AuthorizedTokenTransferer')
const assert = require('assert')

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

contract("Unit Tests", accounts => {

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
        subscription = await StandardSubscription.new(
            payor,
            payee,
            authorizedTokenTransferer.address, 
            mockERC20.address, 
            paymentTerms.address);

        await subscription.addCreditAdmin(payee);
        await subscription.renounceCreditAdmin();

        await subscription.addTokenWithdrawer(payor);
        await subscription.renounceTokenWithdrawer();

        await paymentTerms.transferPrimary(subscription.address);

        await authorizedTokenTransferer.addWhitelisted(subscription.address);
        await mockERC20.approve(authorizedTokenTransferer.address, 10000000, {from: payor});
      })

  it("Payable: transferPayor and approveTransferPayor", async () => {  
    let transferredTo = accounts[3];
    let currentPayor;

    await subscription.transferPayor(transferredTo, {from: payor});
    currentPayor = (await subscription.getPayor()).valueOf();
    assert.equal(currentPayor, payor, "old payor");

    await subscription.approveTransferPayor({from: transferredTo});
    currentPayor = (await subscription.getPayor()).valueOf();
    assert.equal(currentPayor, transferredTo, "new payor");
  });

  it("Receivable: transferPayee", async () => {  
    let transferredTo = accounts[3];
    let currentPayee;

    await subscription.transferPayee(transferredTo, {from: payee});
    currentPayee = (await subscription.getPayee()).valueOf();
    assert.equal(currentPayee, transferredTo, "new payee");
  });

  it("PaymentCredit: addCredit and removeCredit", async () => {
    creditBalance = (await subscription.getCredit()).valueOf();
    assert.equal(creditBalance, 0, "starting credit");

    await subscription.addCredit(100, {from: payee});
    creditBalance = (await subscription.getCredit()).valueOf();
    assert.equal(creditBalance, 100, "add credit");
    
    await subscription.removeCredit(99, {from: payee});
    creditBalance = (await subscription.getCredit()).valueOf();
    assert.equal(creditBalance, 1, "remove credit");
  });
  
  it("TokenEscrow: withdrawToken", async () => {
    await mockERC20.transfer(subscription.address, 2, {from: tokenBank});
    await subscription.withdrawToken(mockERC20.address, 1, {from: payor});
    payorTokenBalance = (await mockERC20.balanceOf(payor)).valueOf();
    assert.equal(payorTokenBalance, startingTokenBalance + 1, "token balance");

    //let result = await subscription.withdrawToken("0x0000000000000000000000000000000000000000", 1, {from: payor});
    //console.log(result);
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