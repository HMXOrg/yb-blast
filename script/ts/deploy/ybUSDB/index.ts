import { ethers } from "hardhat";
import { ERC20__factory, YbUSDB__factory } from "../../../../typechain";

async function main() {
  const usdb = "0x4300000000000000000000000000000000000003";
  const blast = "0x4300000000000000000000000000000000000002";
  const blastPoints = "0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800";
  const blastPointsOperator = "0xC4D6713E4223B66708DD0167aAcf756D2D314192";

  const deployer = (await ethers.getSigners())[0];
  const ybUSDB = new YbUSDB__factory(deployer);
  let nonce = await deployer.getTransactionCount();

  console.log("[deploy/ybUSDB] Deploying ybUSDB...");
  const usdbInstance = ERC20__factory.connect(usdb, deployer);
  console.log("[deploy/ybUSDB] Approve ybUSDB to spend USDB...");
  const expectedYbUSDBAddress = ethers.utils.getContractAddress({
    from: deployer.address,
    nonce: nonce + 1,
  });
  await usdbInstance.approve(
    expectedYbUSDBAddress,
    ethers.constants.MaxUint256
  );
  console.log("[deploy/ybUSDB] USDB approved to ybUSDB to spend USDB");
  const ybUSDBInstance = await ybUSDB.deploy(
    usdb,
    blast,
    blastPoints,
    blastPointsOperator
  );
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
