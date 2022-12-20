const { ethers } = require("hardhat");

async function main(){
	//load the nft contract artifacts
	const celoNFTFactory = await ethers.getContractFactory("CeloNFT");

	//deploy the contract
	const celoNftContract = await celoNFTFactory.deploy();
	await celoNftContract.deployed();

	//print the address of the NFT contract
	console.log("Celo NFT deployed to: ", celoNftContract.address);

  //load the marketplace contract artifacts
	const NFTMarketplaceFactory = await ethers.getContractFactory("NFTMarketplace");

	//deploy the contract
	const nftMarketplaceContract = await NFTMarketplaceFactory.deploy();
	await nftMarketplaceContract.deployed();

	console.log("NFT Marketplace deployed to:", nftMarketplaceContract.address);
}

main()
	.then(()=> process.exit(0))
	.catch(err=>{
		console.error(err);
		process.exit(1);
	})
