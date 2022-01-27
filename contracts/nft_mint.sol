// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract HasTokenURI {
    //Token URI prefix
    string public tokenURIPrefix;

    // Optional mapping for token URIs
    mapping(uint256 => string) public _tokenURIs;

    constructor(string memory _tokenURIPrefix) public {
        tokenURIPrefix = _tokenURIPrefix;
    }

    /**
     * @dev Returns an URI for a given token ID.
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function _tokenURI(uint256 tokenId)
        internal
        virtual
        returns (string memory)
    {
        return string(abi.encodePacked(tokenURIPrefix, _tokenURIs[tokenId]));
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        _tokenURIs[tokenId] = uri;
    }

    /**
     * @dev Internal function to set the token URI prefix.
     * @param _tokenURIPrefix string URI prefix to assign
     */
    function _setTokenURIPrefix(string memory _tokenURIPrefix) internal {
        tokenURIPrefix = _tokenURIPrefix;
    }

    function _clearTokenURI(uint256 tokenId) internal {
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

contract KITT_CONTRACT is ERC721, Ownable, HasTokenURI {
    // Token name
    string private _name = "KITT TEST";

    //mapping of token uri for token id
    // mapping(uint256 => string) public _tokenURIs;

    // Token symbol
    string private _symbol = "KITT";

    //increment tokenId
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //token uri prefix
    string private _baseURIextended = "https://gateway.pinata.cloud/";

    constructor(string memory name_, string memory symbol_)
        ERC721(_name, _symbol)
        HasTokenURI(_baseURIextended)
    {
        _name = name_;
        _symbol = symbol_;
    }

    function mint(address to, string memory tokenURI) public {
        super._mint(to, _tokenIds.current());
        super._setTokenURI(_tokenIds.current(), tokenURI);
        _tokenIds.increment();
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return string(abi.encodePacked(_baseURIextended, _tokenURIs[tokenId]));
    }
}
