//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketplace{
	//represents all the data of each listing
	struct Listing {
		uint256 price;
		address seller;
	}
	
	//maps an address to another mapping, making up a users listings
	mapping(address => mapping(uint256 => Listing)) public listings;
	
	//ensures the caller of a function is the owner of the NFT
	modifier isNFTOwner(address nftAddress, uint256 tokenId){
		require(
			IERC721(nftAddress).ownerOf(tokenId) == msg.sender,
			"MRKT: Not the owner"
		);
		_;
	}

	//makes sure that the asset being called on isn't already listed
	modifier isNotListed(address nftAddress, uint256 tokenId){
		require(
			listings[nftAddress][tokenId].price == 0,
			"MRKT: Already listed"
		);
		_;
	}
	
	//makes sure that the NFT is listed
	modifier isListed(address nftAddress, uint256 tokenId){
		require(
			listings[nftAddress][tokenId].price > 0, 
			"MRKT: Not Listed"
		);
		_;
	}

	//event to emit when we've created a listing
	event ListingCreated(
		address nftAddress,
		uint256 tokenId,
		uint256 price,
		address seller
	);


	function createListing(
			address nftAddress,
			uint256 tokenId,
			uint256 price
		) 
		external 
		isNotListed(nftAddress, tokenId)
		isNFTOwner(nftAddress, tokenId)
		{
			//cannnot create a listing for lower or equal to 0
			require(price > 0, "MRKT: Price must be > 0");
			//check caller is owner of NFT and has approved
			// the marketplace contract to transfer onn their behalf
			IERC721 nftContract = IERC721(nftAddress);
			require(nftContract.ownerOf(tokenId) == msg.sender, "MRKT: Not the owner");
			require(
				nftContract.isApprovedForAll(msg.sender, address(this)) ||
				nftContract.getApproved(tokenId) == address(this),
				"MRKT: No approval for NFT"
			);
			

			//add listing to our mapping
			listings[nftAddress][tokenId] = Listing({
				price: price,
				seller: msg.sender
			});
		
			emit ListingCreated(nftAddress, tokenId, price, msg.sender);
		}

	event ListingCanceled(address nftAddress, uint256 tokenId, address seller);

	function cancelListing(address nftAddress, uint256 tokenId) external isListed(nftAddress, tokenId) isNFTOwner(nftAddress, tokenId){
			//delete the Listing struct from the mapping
			//freeing up storage saves on gas!
			delete listings[nftAddress][tokenId];

			//emit the event
			emit ListingCanceled(nftAddress, tokenId, msg.sender);
	}
	

	event ListingUpdated(
		address nftAddress,
		uint256 tokenId,
		uint256 newPrice,
		address seller
	);

	function updateListing(
		address nftAddress,
		uint256 tokenId,
		uint256 newPrice
	)external isListed(nftAddress, tokenId) isNFTOwner(nftAddress, tokenId){
		//new price has to be greater than 0 still
		require(newPrice > 0, "MRKT: Price must be > 0");
		
		//update the price on the listing
		listings[nftAddress][tokenId].price = newPrice;
	
		//emit the event
		emit ListingUpdated(nftAddress, tokenId, newPrice, msg.sender);
	}


	event ListingPurchased(
		address nftAddress,
		uint256 tokenId,
		address seller,
		address buyer
	);
	
	function purchaseListing(
		address nftAddress, 
		uint256 tokenId
	)
	external
	payable
	isListed(nftAddress, tokenId)
	{
		//load the listing in a local copy
		Listing memory listing = listings[nftAddress][tokenId];
		
		//buyer must have sent enough eth
		require(msg.value == listing.price, "MRKT: Incorrect eth supplied");

		//delete listing from storage, saving gas
		delete listings[nftAddress][tokenId];

		//transfer NFT from seller to buyer
		IERC721(nftAddress).safeTransferFrom(
			listing.seller,
			msg.sender,
			tokenId
		);

		(bool sent, ) = payable(listing.seller).call{value: msg.value}("");
		require(sent, "Failed to transfer Eth");

		//emit the event
		emit ListingPurchased(nftAddress, tokenId, listing.seller, msg.sender);
	}

}
