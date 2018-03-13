var Migrations = artifacts.require("./Migrations.sol");
var Master = artifacts.require("./MasterContract.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Master);
};
