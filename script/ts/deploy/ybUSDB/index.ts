import { ethers } from "hardhat";
import { ERC20__factory, YbUSDB__factory } from "../../../../typechain";

async function main() {
  const usdb = "0x4200000000000000000000000000000000000022";
  const blast = "0x4300000000000000000000000000000000000002";

  const deployer = (await ethers.getSigners())[0];
  const ybUSDB = new YbUSDB__factory(deployer);

  console.log("[deploy/ybUSDB] Deploying ybUSDB...");
  const usdbInstance = ERC20__factory.connect(usdb, deployer);
  console.log("[deploy/ybUSDB] Approve ybUSDB to spend USDB...");
  const expectedYbUSDBAddress = ethers.utils.getContractAddress({
    from: deployer.address,
    nonce: await deployer.getTransactionCount(),
  });
  await usdbInstance.approve(
    expectedYbUSDBAddress,
    ethers.constants.MaxUint256
  );
  console.log("[deploy/ybUSDB] USDB approved to ybUSDB to spend USDB");
  const ybUSDBInstance = await ybUSDB.deploy(usdb, blast);
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
