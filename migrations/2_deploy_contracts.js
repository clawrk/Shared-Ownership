var SimpleStorage = artifacts.require("./SharedOwnership.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
};
