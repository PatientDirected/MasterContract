var Master = artifacts.require("./MasterContract.sol");

module.exports = function(deployer) {
  deployer.deploy(Master);
};