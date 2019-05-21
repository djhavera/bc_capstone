// migrating the appropriate contracts
var SquareVerifier = artifacts.require("./Verifier.sol");
var SolnSquareVerifier = artifacts.require("./SolnSquareVerifier.sol");
var ERC721Mintable = artifacts.require("CustomERC721Token");


module.exports = function(deployer) {
  deployer.deploy(SquareVerifier);
  deployer.deploy(SolnSquareVerifier);
  deployer.deploy(ERC721Mintable);
};