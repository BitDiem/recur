const MockERC20 = artifacts.require('MockERC20')
const StandardSubscription = artifacts.require('StandardSubscription')
const PublisherFrontEnd = artifacts.require('PublisherFrontEnd')
const SubscriptionFactory = artifacts.require('SubscriptionFactory')
const SubscriptionFrontEnd = artifacts.require('SubscriptionFrontEnd')
const AuthorizedTokenTransferer = artifacts.require('AuthorizedTokenTransferer')
const assert = require('assert')

contract("Publisher FrontEnd Test", accounts => {

    let tokenBank;
    let payor;
    let payee;
    let mockERC20;
    let authorizedTokenTransferer;
    let subscription;
    let subscriptionFactory
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

        subscriptionFactory = await SubscriptionFactory.new();
        publisherFrontEnd = await PublisherFrontEnd.new(subscriptionFactory.address);

        transaction = await publisherFrontEnd.createPublisher();
        log = transaction.logs[0];
        let publisherAddress = log.args.publisher;
        subscriptionFrontEnd = await SubscriptionFrontEnd.at(publisherAddress);

        let authorizedTokenTransfererAddress = (await subscriptionFrontEnd.getTokenTransferer()).valueOf();
        authorizedTokenTransferer = await AuthorizedTokenTransferer.at(authorizedTokenTransfererAddress);
        await mockERC20.approve(authorizedTokenTransferer.address, 10000000, {from: payor});
        console.log("before each completed SUCCESS");
    })

  it("should create a fixed interval subscription", async () => {  
    transaction = await subscriptionFrontEnd.createFixedIntervalSubscription(
        payee,
        mockERC20.address,
        1,
        1,
        0,
        {from: payor}
    );
    console.log("WE GOT THIS FAR");
    log = transaction.logs[0];
    let subscriptionAddress = log.args.subscriptionAddress;
    subscription = await StandardSubscription.at(subscriptionAddress);
  });

  /*
  it("should create a monthly subscription", async () => {    
    transaction = await subscriptionFrontEnd.createMonthlySubscription(
        payee,
        mockERC20.address,
        1,
        2019,
        1,
        1,
        {from: payor}
    );
    log = transaction.logs[0];
    let subscriptionAddress = log.args.subscriptionAddress;
    subscription = await StandardSubscription.at(subscriptionAddress);
  });

  it("should create a quarterly subscription", async () => {    
    transaction = await subscriptionFrontEnd.createMultiMonthlySubscription(
        payee,
        mockERC20.address,
        1,
        2019,
        1,
        1,
        3,
        {from: payor}
    );
    log = transaction.logs[0];
    let subscriptionAddress = log.args.subscriptionAddress;
    subscription = await StandardSubscription.at(subscriptionAddress);
  });

  it("should create a yearly subscription", async () => {    
    transaction = await subscriptionFrontEnd.createYearlySubscription(
        payee,
        mockERC20.address,
        1,
        2019,
        1,
        1,
        {from: payor}
    );
    log = transaction.logs[0];
    let subscriptionAddress = log.args.subscriptionAddress;
    subscription = await StandardSubscription.at(subscriptionAddress);
  });*/

});