const OwnTimeLock = artifacts.require("OwnTimeLock");
const TestTimeLock = artifacts.require("TestTimeLock");
module.exports = function (deployer) {
  // deployer.deploy(OwnTimeLock);
  deployer.deploy(TestTimeLock, "0xEdBd9166C052d5A6505f74269d0f527c9342301d");
  //   deployer.deploy(TimeLock);
};
