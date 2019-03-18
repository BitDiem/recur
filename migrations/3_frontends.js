var SubscriptionFactory = artifacts.require("SubscriptionFactory");
var MonthlyTermsFactory = artifacts.require("MonthlyTermsFactory");
var MultiMonthlyTermsFactory = artifacts.require("MultiMonthlyTermsFactory");
var YearlyTermsFactory = artifacts.require("YearlyTermsFactory");
var FixedIntervalTermsFactory = artifacts.require("FixedIntervalTermsFactory");
var SubscriptionFrontEnd = artifacts.require("SubscriptionFrontEnd");
var PublisherFrontEnd = artifacts.require("PublisherFrontEnd");

module.exports = function(deployer) {

  // link deployed libraries to the two frontends
  deployer.link(SubscriptionFactory, [SubscriptionFrontEnd, PublisherFrontEnd]);
  deployer.link(MonthlyTermsFactory, [SubscriptionFrontEnd, PublisherFrontEnd]);
  deployer.link(MultiMonthlyTermsFactory, [SubscriptionFrontEnd, PublisherFrontEnd]);
  deployer.link(YearlyTermsFactory, [SubscriptionFrontEnd, PublisherFrontEnd]);
  deployer.link(FixedIntervalTermsFactory, [SubscriptionFrontEnd, PublisherFrontEnd]);

  deployer.deploy(PublisherFrontEnd);

};
