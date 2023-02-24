require("dotenv").config();

const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("Game"); // compiles the solidity code
  const gameContract = await gameContractFactory.deploy(
    ["Joel", "Ellie", "Bill"],
    [process.env.JOEL, process.env.ELLIE, process.env.BILL],
    [100, 100, 100],
    [100, 100, 100],
    [200, 200, 200],
    "Bloater",
    "https://imgur.com/a/fz4CU6X",
    100000,
    150
  ); // creates local instance of blockchain & deploys contract
  await gameContract.deployed();

  console.log("contract deployed to -> ", gameContract.address);

  let txn;
  txn = await gameContract.mintNFT(0);
  await txn.wait();

  let returnTokenURI = await gameContract.tokenURI(1);
  console.log("TOKEN URI -> ", returnTokenURI);

  txn = await gameContract.attack();
  await txn.wait();
};

const run = async () => {
  try {
    await main();
    process.exit(1);
  } catch (error) {
    console.log(error);
    process.exit(0);
  }
};

run();
