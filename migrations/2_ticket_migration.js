const Migrations = artifacts.require("./Ticket.sol");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
