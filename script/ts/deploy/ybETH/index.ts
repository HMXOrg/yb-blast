import { ethers } from "hardhat";
import { ERC20__factory, YbETH__factory } from "../../../../typechain";

async function main() {
  const weth = "0x4300000000000000000000000000000000000004";
  const blast = "0x4300000000000000000000000000000000000002";

  const deployer = (await ethers.getSigners())[0];
  const ybETH = new YbETH__factory(deployer);
  let nonce = await deployer.getTransactionCount();

  console.log("[deploy/ybETH] Deploying ybETH...");
  const wethInstance = ERC20__factory.connect(weth, deployer);
  const expectedYbETHAddress = ethers.utils.getContractAddress({
    from: deployer.address,
    nonce: nonce + 1,
  });
  console.log("[deploy/ybETH] Approve ybETH to spend WETH...");
  await wethInstance.approve(expectedYbETHAddress, ethers.constants.MaxUint256);
  console.log("[deploy/ybETH] WETH approved to ybETH to spend WETH");
  const ybETHInstance = await ybETH.deploy(weth, blast);
  await ybETHInstance.deployTransaction.wait(1);
  console.log("[deploy/ybETH] Deployed ybETH to:", ybETHInstance.address);
}

main()
  .then(() => {
    process.exit(0);
  })
  .catch((e) => {
    console.error(e);
  });
