// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require('hardhat');

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  const [owner] = await ethers.getSigners();

  const NFT721 = await hre.ethers.getContractFactory('NFT721');
  const nft721 = await NFT721.deploy();
  await nft721.deployed();
  console.log('NFT721 to:', nft721.address);
  // We get the contract to deploy
  const NFT2006 = await hre.ethers.getContractFactory('NFT2006');
  const nft = await NFT2006.deploy();
  await nft.deployed();
  console.log('NFT2006 to:', nft.address);
  console.log('tokenID:', (await nft.tokenId()).toString());

  let indexes = [1, 2, 3];
  let nftAddress = [nft721.address, nft721.address, nft721.address];
  let nftTokenIds = [];
  for (let i = 0; i < indexes.length; i++) {
    await nft721.awardItem(owner.address, '');
    let tokenId = await nft721.tokenId();
    nftTokenIds.push(tokenId);
    console.log('approve:', nft.address, owner.address, tokenId.toString());
    await nft721.approve(nft.address, tokenId);
  }

  console.log('call setChild indexes:', nftTokenIds.toString());
  await nft.setChild(indexes, nftAddress, nftTokenIds);
  console.log(
    'rec contract indexes:',
    (await nft.prefabBoxNftsIndexes()).toString(),
  );
  for (let i = 0; i < indexes.length; i++) {
    console.log(
      'call prefabBoxNft:',
      (await nft.prefabBoxNfts(indexes[i])).toString(),
    );
  }
  console.log('prefabBoxIsBox:', (await nft.prefabBoxIsBox()).toString());

  console.log('call box owner:', owner.address);
  await nft.box(owner.address);
  let tokenID = (await nft.tokenId()).toString();
  console.log('tokenID:', tokenID);
  console.log(
    'tokenIDOfOwner:',
    (await nft.balanceOf(owner.address)).toString(),
  );
  for (let i = 0; i < indexes.length; i++) {
    console.log(
      'call boxNft:',
      (await nft.boxNft(tokenID, indexes[i])).toString(),
    );
  }
  console.log('prefabBoxIsBox:', (await nft.prefabBoxIsBox()).toString());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
