require("dotenv").config();

const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("Game"); // compiles the solidity code
  const gameContract = await gameContractFactory.deploy(
    ["Joel", "Ellie", "Bill"],
    [process.env.JOEL, process.env.ELLIE, process.env.BILL],
    [150, 300, 100],
    [100, 50, 150],
    [200, 100, 500],
    "Bloater",
    "https://imgur.com/a/fz4CU6X",
    10000,
    100
  ); // creates local instance of blockchain & deploys contract
  await gameContract.deployed();

  console.log("contract deployed to -> ", gameContract.address);

  let txn;
  txn = await gameContract.mintNFT(2);
  await txn.wait();

  let returnTokenURI = await gameContract.tokenURI(1);
  console.log("TOKEN URI -> ", returnTokenURI);

  txn = await gameContract.attack();
  await txn.wait();

  txn = await gameContract.attack();
  await txn.wait();

  txn = await gameContract.attack();
  await txn.wait();

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
