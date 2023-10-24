// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "./IStore.sol";

error FeeError();
error IndexError();
error AddressError();
error PaymentError();
error RevenueError();
error UnauthorizedError();

contract Store is
    IStore,
    Pausable,
    AccessControl,
    ERC721Holder,
    ReentrancyGuard
{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public wei_listingFee = 1e18 wei;
    address public feeAddress;
    IERC721 nftContract;

    Listing[] listings;
    mapping(address => uint256) private REVENUE;

    constructor(address nftAddress, address feeAccount) {
        if (nftAddress == address(0)) revert AddressError();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);

        nftContract = IERC721(nftAddress);
        feeAddress = feeAccount;
    }

    function setListingFee(
        uint256 wei_fee
    ) external onlyRole(MANAGER_ROLE) whenNotPaused {
        wei_listingFee = wei_fee;
    }

    function setFeeAddress(
        address feeAccount
    ) external onlyRole(MANAGER_ROLE) whenNotPaused {
        feeAddress = feeAccount;
    }

    function setNftContract(
        address nftAddress
    ) external onlyRole(MANAGER_ROLE) whenNotPaused {
        if (nftAddress == address(0)) revert AddressError();
        nftContract = IERC721(nftAddress);
    }

    function createListing(
        uint256 tokenId,
        uint256 wei_price
    ) external payable nonReentrant whenNotPaused {
        if (msg.value < wei_listingFee) revert FeeError();
        REVENUE[address(0)] = msg.value;

        address owner = nftContract.ownerOf(tokenId);
        listings.push(Listing(tokenId, wei_price, payable(owner)));
        nftContract.safeTransferFrom(owner, address(this), tokenId);
        emit CreatedListing(owner, tokenId, wei_price);
    }

    function updateListingPrice(
        uint256 index,
        uint256 wei_price
    ) external whenNotPaused {
        if (index > listings.length) revert IndexError();
        if (msg.sender != listings[index].owner) revert UnauthorizedError();
        listings[index].wei_price = wei_price;
        emit CreatedListing(
            listings[index].owner,
            listings[index].tokenId,
            wei_price
        );
    }

    function removeListing(uint256 index) external whenNotPaused {
        if (index > listings.length) revert IndexError();
        if (msg.sender != listings[index].owner) revert UnauthorizedError();
        Listing memory listing = listings[index];
        _removeListing(index, listing.tokenId);
        emit RemovedListing(listing.owner, listing.tokenId);
    }

    function purchaseListing(uint256 index) external payable whenNotPaused {
        Listing memory listing = listings[index];
        if (msg.value < listing.wei_price) revert PaymentError();

        _removeListing(index, listing.tokenId);
        REVENUE[listing.owner] += msg.value;
        emit PurchasedListing(msg.sender, listing.tokenId, msg.value);
        emit RemovedListing(listing.owner, listing.tokenId);
    }

    function withdrawRevenue() external whenNotPaused {
        uint256 amount = REVENUE[msg.sender];
        if (amount == 0) revert RevenueError();

        REVENUE[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit Claim(msg.sender, amount, block.timestamp);
    }

    function revenueOf(address owner) external view returns (uint256) {
        return REVENUE[owner];
    }

    function getAllListing() external view returns (Listing[] memory) {
        return listings;
    }

    function getListingByIndex(
        uint256 index
    ) external view returns (Listing memory) {
        if (index > listings.length) revert IndexError();
        return listings[index];
    }

    function totalListings() external view returns (uint256) {
        return listings.length;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _removeListing(uint256 tokenId, uint256 index) private whenNotPaused {
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);
        listings[index] = listings[listings.length - 1];
        listings.pop();
    }
}
