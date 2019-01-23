var Token = artifacts.require("./Token.sol");
var ERC20 = artifacts.require("./ERC20.sol");
var ERC223 = artifacts.require("./ERC223.sol");
var ERC223ReceivingContract = artifacts.require("./ERC223ReceivingContract.sol");
var KPay = artifacts.require("./Kpay.sol");

module.exports = function(deployer) {
//   deployer.deploy(Token);
//   deployer.deploy(ERC20);
//   deployer.deploy(ERC223);
//   deployer.deploy(ERC223ReceivingContract);
  
//   deployer.link(Token, KPay);
//   deployer.link(ERC20, KPay);
//   deployer.link(ERC223, KPay);
//   deployer.link(ERC223ReceivingContract, KPay);

  deployer.deploy(KPay);
};
