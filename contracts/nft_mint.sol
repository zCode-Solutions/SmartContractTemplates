// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
import "./ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./HasTokenURI.sol";


contract KITT_CONTRACT is ERC721, Ownable, HasTokenURI {
    // Token name
    string private _name = "KITT TEST";

    // Token symbol
    string private _symbol = "KITT";

    //increment tokenId
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //token uri prefix
    string private _baseURIextended = "https://gateway.pinata.cloud/";

    constructor(string memory name_, string memory symbol_) 
        ERC721(_name, _symbol)
        HasTokenURI(_baseURIextended){
        _name = name_;
        _symbol = symbol_;
    }

    modifier validDestination( address to ) {
        require(to != address(0x0));
        require(to != address(this) );
        _;
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
