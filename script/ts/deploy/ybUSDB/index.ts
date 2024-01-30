import { ethers } from "hardhat";
import { YbUSDB__factory } from "../../../../typechain";

async function main() {
  const usdb = "0x4200000000000000000000000000000000000022";
  const deployer = (await ethers.getSigners())[0];
  const ybUSDB = new YbUSDB__factory(deployer);

  console.log("[deploy/ybUSDB] Deploying ybUSDB...");
  const ybUSDBInstance = await ybUSDB.deploy(usdb);
  await ybUSDBInstance.deployTransaction.wait(1);
  console.log("[deploy/ybUSDB] Deployed ybUSDB to:", ybUSDBInstance.address);
}

main()
  .then(() => {
    process.exit(0);
  })
  .catch((e) => {
    console.error(e);
  });
