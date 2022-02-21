// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
import "./ERC721.sol";
import "./utils/Counters.sol";
import "./utils/Ownable.sol";
import "./HasTokenURI.sol";


contract KITT_CONTRACT is ERC721, Ownable, HasTokenURI {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

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

    function mint(address to, string memory tokenURI) public {
        ERC721._mint(to, _tokenIds.current());
        HasTokenURI._setTokenURI(_tokenIds.current(), tokenURI);
        _tokenIds.increment();
    }

}
