import {
	ListingCanceled,
	ListingCreated,
	ListingPurchased,
	ListingUpdated,
} from '../generated/NFTMarketplace/NFTMarketplace';
import { store } from "@graphprotocol/graph-ts";
import { ListingEntity } from "../generated/schema";

export function handleListingCreated(event: ListingCreated): void {
	//create a unique id that refers to the listing
	//The NFT contract address + TokenId + Seller Address can be used to uniquely refer
	//to a specific listing
	const id = event.params.nftAddress.toHex() +
						 "-" +
						 event.params.tokenId.toString() +
						 "-" +
						 event.params.seller.toHex();

	//create a new entity and assign it's ID
	let listing = new ListingEntity(id);

	//set the props of the listing as deined in the schema
	//based on the event
	listing.seller = event.params.seller;
	listing.nftAddress = event.params.nftAddress;
	listing.tokenId = event.params.tokenId;
	listing.price = event.params.price;

	//save the listing to the nodes, so we can query it later
	listing.save();
}

export function handleListingCanceled(event: ListingCanceled): void {
	//recreate the id that refers to the listing
	//sine the lisiting is being updated, the datastore must already have an entity with this ID
	//from when the listinmg was first created
	const id = event.params.nftAddress.toHex() +
    				 "-" +
             event.params.tokenId.toString() +
             "-" +
             event.params.seller.toHex();

	let listing = ListingEntity.load(id);

	//if it does
	if(listing){
		//remove it from the store
		store.remove("LisitingEntity", id);
	}

}

export function handleListingPurchased(event: ListingPurchased): void {
	//create the id that refers to the listing
 	const id = event.params.nftAddress.toHex() +
    				 "-" +
             event.params.tokenId.toString() +
             "-" +
             event.params.seller.toHex();

	let listing = ListingEntity.load(id);

	//if it exists
	if(listing){
		//set the buyer
		listing.buyer = event.params.buyer;

		//save the changes
		listing.save();
	}
}


export function hanndleListingUpdated(event: ListingUpdated): void {
	//recreate the id
	const id = event.params.nftAddress.toHex() +
    				 "-" +
             event.params.tokenId.toString() +
             "-" +
             event.params.seller.toHex();

	//attempt to load the pre-existing entity, instead of creating a new one
	let listing = ListingEntity.load(id);

	if(listing) {
		listing.price = event.params.newPrice;
		
		//save changed
		listing.save();
	}

	
}


