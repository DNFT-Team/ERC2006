//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT2006 is ERC721, Ownable {
    using SafeMath for uint256;

    struct Nft {
        address nftAddress;
        uint256 nftTokenId;
        bool isValid;
    }

    bool isBox = false;
    Nft[] nftBox;
    /// @dev index => struct(Nft)
    mapping(uint256 => Nft) public nfts;
    /// @dev all set nfts.index (Contains invalid value)
    uint256[] public nftsIndex;

    constructor() ERC721("NFT2006", "NFT2006") {}

    function setChild(
        uint256[] memory _indexs,
        address[] memory _nftAddress,
        uint256[] memory _nftTokenIds
    ) external onlyOwner {
        require(isBox == false, "already box");
        require(_indexs.length > 0, "error args");
        require(_indexs.length == _nftAddress.length, "error args");
        require(_nftAddress.length == _nftTokenIds.length, "error args");

        for (uint256 i = 0; i < _indexs.length; i++) {
            address addr = _nftAddress[i];
            require(addr != address(0));
            require(!isContract(addr));

            uint256 tokenId = _nftTokenIds[i];
            if (!isExist(_indexs[i])) {
                nftsIndex.push(_indexs[i]);
            }
            nfts[_indexs[i]] = Nft(addr, tokenId, true);
        }
    }

    function removeChild(uint256[] memory _indexs) external onlyOwner {
        require(isBox == false, "already box");
        require(_indexs.length > 0, "error arg");
        for (uint256 i = 0; i < _indexs.length; i++) {
            nfts[_indexs[i]].nftAddress = address(0);
            nfts[_indexs[i]].nftTokenId = 0;
            nfts[_indexs[i]].isValid = false;
        }
    }

    function box() external onlyOwner {
        require(isBox == false, "already boxed");

        isBox = true;
        /// TODO
        // for(){
        //      IERC721(addr).safeTransferFrom(msg.sender, address(this), tokenId);
        // }
        // _mint()
    }

    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function nftBoxCount() external view returns (uint256) {
        return nftBox.length;
    }

    /// @dev nfts.length(Contains invalid value)
    function nftsCount() external view returns (uint256) {
        return nftsIndex.length;
    }

    function isExist(uint256 index) internal view returns (bool) {
        bool bo = false;
        for (uint256 i = 0; i < nftsIndex.length; i++) {
            if (nftsIndex[i] == index) {
                bo = true;
                break;
            }
        }
        return bo;
    }

    function withdrawNft() external onlyOwner {
        require(nftBox.length > 0, "nft balance zero");
        for (uint256 i = 0; i < nftBox.length; i++) {
            address addr = nftBox[i].nftAddress;
            uint256 tokenId = nftBox[i].nftTokenId;
            IERC721(addr).safeTransferFrom(address(this), owner(), tokenId);
        }
    }
}
