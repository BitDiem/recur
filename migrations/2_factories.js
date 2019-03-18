var SubscriptionFactory = artifacts.require("SubscriptionFactory");
var MonthlyTermsFactory = artifacts.require("MonthlyTermsFactory");
var MultiMonthlyTermsFactory = artifacts.require("MultiMonthlyTermsFactory");
var YearlyTermsFactory = artifacts.require("YearlyTermsFactory");
var FixedIntervalTermsFactory = artifacts.require("FixedIntervalTermsFactory");

module.exports = function(deployer) {

  // Deploy libraries
  deployer.deploy(SubscriptionFactory);
  deployer.deploy(MonthlyTermsFactory);
  deployer.deploy(MultiMonthlyTermsFactory);
  deployer.deploy(YearlyTermsFactory);
  deployer.deploy(FixedIntervalTermsFactory);

};
