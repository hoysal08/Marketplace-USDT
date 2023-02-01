// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const [owner]=await ethers.getSigners();


  const SampleUSDT=await ethers.getContractFactory("Tether");
  const sampleusdt=await SampleUSDT.deploy();
  await sampleusdt.deployed();
  console.log("USDT deployed at " + sampleusdt.address);

  //required to deploy Sample Oracle in local environment

  // const SampleOracles=await ethers.getContractFactory("oracle");
  // const sampleoracle=await SampleOracles.deploy();
  // await sampleoracle.deployed();
  // console.log("Oracles deployed at " + sampleoracle.address);

  Oracleaddress="0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e"

  //deploy Marketplace based on SampleOracle

  // const Marketplacecontract=await ethers.getContractFactory("Marketplace",owner);
  // const marketplace=await upgrades.deployProxy(Marketplacecontract,[sampleusdt.address,sampleoracle.address],{unsafeAllowCustomTypes:true});
  // await marketplace.deployed();
  // console.log("Marketplace deployed at "+ marketplace.address);

  const Marketplacecontract=await ethers.getContractFactory("Marketplace",owner);
  const marketplace=await upgrades.deployProxy(Marketplacecontract,[sampleusdt.address,Oracleaddress],{unsafeAllowCustomTypes:true});
  await marketplace.deployed();
  console.log("Marketplace deployed at "+ marketplace.address);

}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


/* 
npx hardhat run scripts/deploy.js --network goerli
USDT deployed at 0x77925e831510A73E4E40e8C07becafBe8936D23f
Marketplace deployed at 0x64E4d633e709994e9D8ECB843E2056FAdBEdC096
*/