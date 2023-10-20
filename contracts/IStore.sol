// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IStore {
    struct Listing {
        uint256 id;
        uint256 wei_price;
        address payable owner;
    }

    event Claim(
        address indexed to,
        uint256 indexed amount,
        uint256 indexed timestamp
    );

    event CreatedListing(
        address indexed owner,
        uint256 indexed id,
        uint256 indexed wei_price
    );

    event RemovedListing(address indexed owner, uint256 indexed id);

    event PurchasedListing(
        address indexed buyer,
        uint256 indexed id,
        uint256 indexed wei_price
    );

    function setListingFee(uint256 fee) external;

    function setFeeAddress(address feeAccount) external;

    function setNftContract(address registry) external;

    function createListing(uint256 id, uint256 wei_price) external payable;

    function updateListingPrice(uint256 index, uint256 wei_price) external;

    function removeListing(uint256 index) external;

    function purchaseListing(uint256 index) external payable;

    function withdrawRevenue() external;

    function revenueOf(address owner) external view returns (uint256);

    function getAllListing() external view returns (Listing[] memory);

    function getListingByIndex(uint256 index)
        external
        view
        returns (Listing memory);

    function totalListings() external view returns (uint256);
}