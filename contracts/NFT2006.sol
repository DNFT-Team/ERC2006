//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT2006 is ERC721, ERC721Holder, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIds;

    struct Nft {
        address nftAddress;
        uint256 nftTokenId;
        bool isValid;
        bool isPaid;
    }

    struct NftBox {
        uint256 id;
        address creater;
        uint256[] nftsIndexes;
        mapping(uint256 => Nft) nfts;
        bool isBox;
    }

    /// @dev owner address => NftBox
    mapping(address => NftBox) private prefabBox;

    /// @dev owner address => <tokenId,NftBox>
    mapping(address => mapping(uint256 => NftBox)) private boxes;

    // bool private isBox = false;
    // Nft[] private nftBox;

    /// @dev index => struct(Nft)
    // mapping(uint256 => Nft) public nfts;
    /// @dev all set nfts.index (Contains invalid value)
    // uint256[] public nftsIndex;

    constructor() ERC721("NFT2006", "NFT2006") {}

    function setChild(
        uint256[] memory _indexes,
        address[] memory _nftAddress,
        uint256[] memory _nftTokenIds
    ) external {
        // require(isBox == false, "already box");
        require(_indexes.length > 0, "error args");
        require(_indexes.length == _nftAddress.length, "error args");
        require(_nftAddress.length == _nftTokenIds.length, "error args");

        for (uint256 i = 0; i < _indexes.length; i++) {
            address addr = _nftAddress[i];
            require(addr != address(0));

            if (!isExist(_indexes[i], prefabBox[msg.sender].nftsIndexes)) {
                prefabBox[msg.sender].nftsIndexes.push(_indexes[i]);
            }
            prefabBox[msg.sender].nfts[_indexes[i]] = Nft(
                addr,
                _nftTokenIds[i],
                true,
                false
            );
        }
        prefabBox[msg.sender].id = 0;
        prefabBox[msg.sender].creater = msg.sender;
        prefabBox[msg.sender].isBox = false;
    }

    function removeChild(uint256[] memory _indexes) external {
        require(_indexes.length > 0, "error arg");
        require(prefabBox[msg.sender].isBox == false, "Already box");

        for (uint256 i = 0; i < _indexes.length; i++) {
            prefabBox[msg.sender].nfts[_indexes[i]].nftAddress = address(0);
            prefabBox[msg.sender].nfts[_indexes[i]].nftTokenId = 0;
            prefabBox[msg.sender].nfts[_indexes[i]].isValid = false;
        }
    }

    function box(address to) external {
        require(prefabBox[msg.sender].isBox == false, "Alreay box");
        require(prefabBox[msg.sender].nftsIndexes.length > 0, "Not set child");

        _tokenIds.increment();

        uint256 currentTokenId = _tokenIds.current();

        for (uint256 i = 0; i < prefabBox[msg.sender].nftsIndexes.length; i++) {
            if (
                prefabBox[msg.sender]
                    .nfts[prefabBox[msg.sender].nftsIndexes[i]]
                    .isValid == true
            ) {
                uint256 ind = prefabBox[msg.sender].nftsIndexes[i];
                Nft memory nft = prefabBox[msg.sender].nfts[ind];

                IERC721(nft.nftAddress).safeTransferFrom(
                    msg.sender,
                    address(this),
                    nft.nftTokenId
                );
                boxes[to][currentTokenId].nftsIndexes.push(ind);
                boxes[to][currentTokenId].nfts[ind] = nft;
                boxes[to][currentTokenId].nfts[ind].isPaid = true;
            }
        }
        prefabBox[msg.sender].isBox = true;

        boxes[to][currentTokenId].id = currentTokenId;
        boxes[to][currentTokenId].creater = msg.sender;
        boxes[to][currentTokenId].isBox = true;

        _mint(to, currentTokenId);
    }

    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function isExist(uint256 index, uint256[] memory arr)
        internal
        pure
        returns (bool)
    {
        bool bo = false;
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == index) {
                bo = true;
                break;
            }
        }
        return bo;
    }

    function prefabBoxNfts(uint256 _index) external view returns (Nft memory) {
        return prefabBox[msg.sender].nfts[_index];
    }

    function prefabBoxNftsIndexes() external view returns (uint256[] memory) {
        return prefabBox[msg.sender].nftsIndexes;
    }

    function prefabBoxIsBox() external view returns (bool) {
        return prefabBox[msg.sender].isBox;
    }

    function boxNft(uint256 _tokenId, uint256 _index)
        external
        view
        returns (Nft memory)
    {
        return boxes[msg.sender][_tokenId].nfts[_index];
    }

    function tokenId() external view returns (uint256) {
        return _tokenIds.current();
    }
}
