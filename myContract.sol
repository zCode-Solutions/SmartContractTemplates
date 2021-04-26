pragma solidity ^0.8.0;
//includes metadata extension

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract HasTokenURI {
    //Token URI prefix
    using SafeMath for uint256;

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

    function _showtokenURI(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        return append(tokenURIPrefix, _tokenURIs[tokenId]);
    }

    function append(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal virtual {
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

contract MyContract is
    ERC721,
    HasTokenURI,
    ERC721Enumerable,
    ERC721Burnable,
    Ownable
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string private _baseURIextended = "google.com";
    address payable public ownerPay;

    struct Product {
        address payable recipient;
        uint256 price;
    }
    struct Creators {
        address payable owner1;
        address payable owner2;
    }

    //search by tokenId to find price and address of purchaser
    mapping(uint256 => Product[]) public productCatalog;
    mapping(uint256 => Creators) public creatorByTokenId;

    //create function to add creators to Creators struct

    constructor(string memory _name, string memory _symbol)
        public
        ERC721(_name, _symbol)
        HasTokenURI(_baseURIextended)
    {
        //set contract deployer to recieve payments
        ownerPay = payable(msg.sender);
    }

    event Deposit(address indexed _from, bytes32 indexed _id, uint256 _value);

    function deposit(bytes32 _id) public payable {
        emit Deposit(msg.sender, _id, msg.value);
    }

    function invest() external payable {
        //sends ether to smart contract
        require(msg.value > 0, "must be greater than 0");
    }

    function balanceOfContract() public returns (uint256) {
        return address(this).balance;
    }

    function withdraw(address owner1, address owner2) external payable {
        //address  owners = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        uint256 revenue = balanceOfContract();
        uint256 share = SafeMath.div(revenue, 2);
        payable(owner1).transfer(share);
        payable(owner2).transfer(share);
    }

    //create creator Struct to handle 2 payable addresses
    //update mint to designate creator struct according to tokenId
    //

    //function payPartners() retunrs

    function mintProduct(uint256 price, string memory tokenURI)
        external
        onlyOwner
        returns (uint256)
    {
        /*
         * increment tokenId
         * mint with new tokenId
         * set NFT url
         */
        _tokenIds.increment();
        uint256 newNftTokenId = _tokenIds.current();
        Product memory product1 = Product(payable(msg.sender), price); //create instance of product
        productCatalog[newNftTokenId].push(product1); //add purchase
        _mint(msg.sender, newNftTokenId);
        _setTokenURI(newNftTokenId, tokenURI);

        return newNftTokenId;
    }

    function showProductPrice(uint256 tokenId)
        public
        view
        returns (uint256[] memory)
    {
        Product[] memory _product = productCatalog[tokenId];
        uint256[] memory result = new uint256[](_product.length);
        for (uint256 i = 0; i < _product.length; i++) {
            result[i] = _product[i].price;
        }
        return result;
    }

    function showProductOwner(uint256 tokenId)
        public
        view
        returns (address payable[] memory)
    {
        Product[] memory _product = productCatalog[tokenId];
        address payable[] memory result =
            new address payable[](_product.length);
        for (uint256 i = 0; i < _product.length; i++) {
            result[i] = _product[i].recipient;
        }
        return result;
    }

    function purchaseProduct(address to, uint256 tokenId)
        external
        payable
        returns (Product[] memory)
    {
        /*
            require value = product.price
            msg.sender needs to have value >= product.price
            transfer money to tokenId owner
            
            need to add requirement to make sure msg.value is = amount or > 0
            check if tokenId exists
        */

        //address payable[] memory owner = showProductOwner(tokenId);
        uint256[] memory price = showProductPrice(tokenId);
        // require(msg.value >= price, "Fee value should greater or equal to product price");
        Product memory product = Product(payable(to), msg.value); //create instance of purchased product
        productCatalog[tokenId].push(product);
        address owner = ownerOf(tokenId);
        // pay partners
        payable(owner).transfer(msg.value); //transfer ether from smart contract to address
        _approve(to, tokenId);
        safeTransferFrom(owner, to, tokenId);
        return productCatalog[tokenId];
    }

    function setTokenUrl(uint256 tokenId, string memory uri) internal {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return interfaceId == type(IERC721).interfaceId;
    }
}
