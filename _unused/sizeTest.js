const MockERC20 = artifacts.require('MockERC20')
const MockRecurringPaymentTerms = artifacts.require('MockRecurringPaymentTerms')
const StandardSubscription = artifacts.require('StandardSubscription')
const SubscriptionFrontEnd = artifacts.require('SubscriptionFrontEnd')
const AuthorizedTokenTransferer = artifacts.require('AuthorizedTokenTransferer')

contract('Sizing', function(accounts) {
  it("get the size of the contract", async () => {
    tokenBank = accounts[0];
    payor = accounts[1];
    payee = accounts[2];

    mockERC20 = await MockERC20.new("Mock ERC20", "MERC20", 1);
    paymentTerms = await MockRecurringPaymentTerms.new(1, 1, 0);
    authorizedTokenTransferer = await AuthorizedTokenTransferer.new();
    subscriptionFrontEnd = await SubscriptionFrontEnd.new(authorizedTokenTransferer.address);
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

    let instance = await subscription.deployed();

      var bytecode = instance.constructor._json.bytecode;
      var deployed = instance.constructor._json.deployedBytecode;
      var sizeOfB  = bytecode.length / 2;
      var sizeOfD  = deployed.length / 2;
      console.log("size of bytecode in bytes = ", sizeOfB);
      console.log("size of deployed in bytes = ", sizeOfD);
      console.log("initialisation and constructor code in bytes = ", sizeOfB - sizeOfD);
  });
});