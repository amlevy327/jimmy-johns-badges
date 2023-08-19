const hre = require('hardhat');

async function main() {

  const Badges = await hre.ethers.getContractFactory(
    'Badges',
  );

  const badges = await Badges.deploy();

  await badges.waitForDeployment();

  console.log(`badges deployed to ${await badges.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});