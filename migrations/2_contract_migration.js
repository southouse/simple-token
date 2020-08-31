var SampleToken = artifacts.require("./SampleToken.sol");

const _name = "SampleToken";
const _symbol = "STK";
const _decimals = 18;
const _total_supply = 1000000;

module.exports = function(deployer) {
    deployer.deploy(SampleToken, _name, _symbol, _decimals, _total_supply);
};