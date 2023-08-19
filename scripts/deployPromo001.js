const hre = require('hardhat');

async function main() {

  const Promo001 = await hre.ethers.getContractFactory(
    'Promo001',
  );

  const name = "Promo001"
  const symbol = "P1"
  const expiration = 1724110466;

  const promo001 = await Promo001.deploy(
    name,
    symbol,
    expiration
  );

  await promo001.waitForDeployment();

  console.log(`promo001 deployed to ${await promo001.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});