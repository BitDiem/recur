var SubscriptionFactory = artifacts.require("SubscriptionFactory");
var PublisherFrontEnd = artifacts.require("PublisherFrontEnd");

module.exports = function(deployer) {

  deployer.deploy(SubscriptionFactory).then(function() {
    return deployer.deploy(PublisherFrontEnd, SubscriptionFactory.address);
  });
  
};
