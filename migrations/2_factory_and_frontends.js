var SubscriptionFactory = artifacts.require("SubscriptionFactory");
var MonthlyTermsFactory = artifacts.require("MonthlyTermsFactory");
var MultiMonthlyTermsFactory = artifacts.require("MultiMonthlyTermsFactory");
var YearlyTermsFactory = artifacts.require("YearlyTermsFactory");
var FixedIntervalTermsFactory = artifacts.require("FixedIntervalTermsFactory");
var SubscriptionFrontEnd = artifacts.require("SubscriptionFrontEnd");
var PublisherFrontEnd = artifacts.require("PublisherFrontEnd");

module.exports = function(deployer) {

  // Deploy library LibA, then link LibA to contract B, then deploy B.
  // Deploy libraries
  deployer.deploy(SubscriptionFactory);
  deployer.deploy(MonthlyTermsFactory);
  deployer.deploy(MultiMonthlyTermsFactory);
  deployer.deploy(YearlyTermsFactory);
  deployer.deploy(FixedIntervalTermsFactory);

  deployer.link(SubscriptionFactory, [SubscriptionFrontEnd, PublisherFrontEnd]);
  deployer.link(MonthlyTermsFactory, [SubscriptionFrontEnd, PublisherFrontEnd]);
  deployer.link(MultiMonthlyTermsFactory, [SubscriptionFrontEnd, PublisherFrontEnd]);
  deployer.link(YearlyTermsFactory, [SubscriptionFrontEnd, PublisherFrontEnd]);
  deployer.link(FixedIntervalTermsFactory, [SubscriptionFrontEnd, PublisherFrontEnd]);

  deployer.deploy(PublisherFrontEnd);

  /*
  deployer.deploy(SubscriptionFactory).then(function() {
    return deployer.deploy(PublisherFrontEnd, SubscriptionFactory.address);
  });
  */
};
