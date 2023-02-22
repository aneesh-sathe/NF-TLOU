require("dotenv").config();

const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("Game"); // compiles the solidity code
  const gameContract = await gameContractFactory.deploy(
    ["joel", "ellie", "bill"],
    [process.env.JOEL, process.env.ELLIE, process.env.BILL],
    [100, 100, 100],
    [100, 100, 100],
    [200, 200, 200]
  ); // creates local instance of blockchain & deploys contract
  await gameContract.deployed();

  console.log("contract deployed to -> ", gameContract.address);
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
