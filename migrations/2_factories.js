var SubscriptionFactory = artifacts.require("SubscriptionFactory");
var MonthlyTermsFactory = artifacts.require("MonthlyTermsFactory");
var MonthsTermsFactory = artifacts.require("MonthsTermsFactory");
var YearlyTermsFactory = artifacts.require("YearlyTermsFactory");
var SecondsTermsFactory = artifacts.require("SecondsTermsFactory");

module.exports = function(deployer) {

  // Deploy libraries
  deployer.deploy(SubscriptionFactory);
  deployer.deploy(MonthlyTermsFactory);
  deployer.deploy(MonthsTermsFactory);
  deployer.deploy(YearlyTermsFactory);
  deployer.deploy(SecondsTermsFactory);

};
