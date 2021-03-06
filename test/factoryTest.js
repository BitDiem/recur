const MockERC20 = artifacts.require('MockERC20')
const StandardSubscription = artifacts.require('StandardSubscription')
const PublisherFrontEnd = artifacts.require('PublisherFrontEnd')
const SubscriptionFrontEnd = artifacts.require('SubscriptionFrontEnd')
const AuthorizedTokenTransferer = artifacts.require('AuthorizedTokenTransferer')
const assert = require('assert')

contract("Publisher FrontEnd Test", accounts => {

  let tokenBank;
  let payor;
  let payee;
  let mockERC20;
  let authorizedTokenTransferer;
  let subscriptionFrontEnd;
  let transaction;
  let log;

  const startingTokenBalance = 100;

  beforeEach(async function() {   
      tokenBank = accounts[0];
      payor = accounts[1];
      payee = accounts[2];

      mockERC20 = await MockERC20.new("Mock ERC20", "MERC20", tokenBank, startingTokenBalance * 2);
      await mockERC20.transfer(payor, startingTokenBalance, {from: tokenBank});

      publisherFrontEnd = await PublisherFrontEnd.new();

      transaction = await publisherFrontEnd.createPublisher();
      log = transaction.logs[0];
      let publisherAddress = log.args.publisher;
      subscriptionFrontEnd = await SubscriptionFrontEnd.at(publisherAddress);

      let authorizedTokenTransfererAddress = (await subscriptionFrontEnd.getTokenTransferer()).valueOf();
      authorizedTokenTransferer = await AuthorizedTokenTransferer.at(authorizedTokenTransfererAddress);
      await mockERC20.approve(authorizedTokenTransferer.address, 10000000, {from: payor});
  })

  it("should create yearly subscription", async () => {  
    transaction = await subscriptionFrontEnd.createYearlySubscription(
        payee,
        mockERC20.address,
        1,
        2019, 3, 21, 0, 0, 0,
        {from: payor}
    );
    log = transaction.logs[0];
    let subscriptionAddress = log.args.subscriptionAddress;
    subscription = await StandardSubscription.at(subscriptionAddress);
  });

  it("should create multi monthly subscription", async () => {  
    transaction = await subscriptionFrontEnd.createMonthsIntervalSubscription(
        payee,
        mockERC20.address,
        1,
        2019, 3, 21, 0, 0, 0,
        3,
        {from: payor}
    );
    log = transaction.logs[0];
    let subscriptionAddress = log.args.subscriptionAddress;
    subscription = await StandardSubscription.at(subscriptionAddress);
  });

  it("should create monthly subscription", async () => {  
    transaction = await subscriptionFrontEnd.createMonthlySubscription(
        payee,
        mockERC20.address,
        1,
        2019, 3, 21, 0, 0, 0,
        {from: payor}
    );
    log = transaction.logs[0];
    let subscriptionAddress = log.args.subscriptionAddress;
    subscription = await StandardSubscription.at(subscriptionAddress);
  });

  it("should create days interval subscription", async () => {  
    transaction = await subscriptionFrontEnd.createDaysIntervalSubscription(
        payee,
        mockERC20.address,
        1,
        2019, 3, 21, 0, 0, 0,
        2,
        {from: payor}
    );
    log = transaction.logs[0];
    let subscriptionAddress = log.args.subscriptionAddress;
    subscription = await StandardSubscription.at(subscriptionAddress);
  });

  it("should create hours interval subscription", async () => {  
    transaction = await subscriptionFrontEnd.createHoursIntervalSubscription(
        payee,
        mockERC20.address,
        1,
        2019, 3, 21, 0, 0, 0,
        5,
        {from: payor}
    );
    log = transaction.logs[0];
    let subscriptionAddress = log.args.subscriptionAddress;
    subscription = await StandardSubscription.at(subscriptionAddress);
  });

  it("should create minutes interval subscription", async () => {  
    transaction = await subscriptionFrontEnd.createMinutesIntervalSubscription(
        payee,
        mockERC20.address,
        1,
        2019, 3, 21, 0, 0, 0,
        15,
        {from: payor}
    );
    log = transaction.logs[0];
    let subscriptionAddress = log.args.subscriptionAddress;
    subscription = await StandardSubscription.at(subscriptionAddress);
  });

  it("should create seconds interval subscription", async () => {  
    transaction = await subscriptionFrontEnd.createSecondsIntervalSubscription(
        payee,
        mockERC20.address,
        1,
        2019, 3, 21, 0, 0, 0,
        120, 
        {from: payor}
    );
    log = transaction.logs[0];
    let subscriptionAddress = log.args.subscriptionAddress;
    subscription = await StandardSubscription.at(subscriptionAddress);
  });

});