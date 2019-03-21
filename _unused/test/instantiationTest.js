// factories
const FixedIntervalTermsFactory = artifacts.require('FixedIntervalTermsFactory')
const MonthlyTermsFactory = artifacts.require('MonthlyTermsFactory')
const MultiMonthlyTermsFactory = artifacts.require('MultiMonthlyTermsFactory')
const YearlyTermsFactory = artifacts.require('YearlyTermsFactory')
const SubscriptionFactory = artifacts.require('SubscriptionFactory')

const StandardSubscription = artifacts.require('StandardSubscription')
const PublisherFrontEnd = artifacts.require('PublisherFrontEnd')
const SubscriptionFrontEnd = artifacts.require('SubscriptionFrontEnd')
const MockERC20 = artifacts.require('MockERC20')
const AuthorizedTokenTransferer = artifacts.require('AuthorizedTokenTransferer')
const MockRecurringPaymentTerms = artifacts.require('MockRecurringPaymentTerms')

const assert = require('assert')

module.exports = function (deployer) {
  deployer.deploy(YearlyTermsFactory);
};

contract("Instantiation Test", accounts => {

  let tokenBank;
  let payor;
  let payee;
  let mockERC20;
  let paymentTerms
  let authorizedTokenTransferer;
  let subscriptionFrontEnd;
  let factory;
  let transaction;
  let log;
  let result;

  const startingTokenBalance = 100;

  beforeEach(async function() {   
    tokenBank = accounts[0];
    payor = accounts[1];
    payee = accounts[2];

    mockERC20 = await MockERC20.new("Mock ERC20", "MERC20", tokenBank, startingTokenBalance * 2);
    paymentTerms = await MockRecurringPaymentTerms.new(1, 1, 0);
    authorizedTokenTransferer = await AuthorizedTokenTransferer.new();
  })

  it("should create Yearly terms from factory", async () => {
    factory = await YearlyTermsFactory.new();
    console.log(factory);
    console.log(factory.address);
    transaction = await factory.create(1, 2019, 3, 21);
    log = transaction.logs[0];
    console.log(log.args);
  });

  /*it("should create a Subscription from factory", async () => {
    factory = await SubscriptionFactory.new();
    //console.log(factory);
    transaction = await factory.create(
      payor, 
      payee, 
      authorizedTokenTransferer.address, 
      mockERC20.address, 
      paymentTerms.address);

    log = transaction.logs[0];
    console.log(log.args);
  });*/

  /*it("should create a fixed interval subscription", async () => {  
    transaction = await subscriptionFrontEnd.createFixedIntervalSubscription(
        payee,
        mockERC20.address,
        1,
        1,
        0,
        {from: payor}
    );
    log = transaction.logs[0];
    let subscriptionAddress = log.args.subscriptionAddress;
    subscription = await StandardSubscription.at(subscriptionAddress);
  });*/

});