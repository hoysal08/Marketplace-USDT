// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

///@title Marketplace contract with USDT support
///@author Sooraj Hoysal
///@notice The contract Uses commit reveal pattern to prevent front running attacks
contract Marketplace is Initializable {

    ///@dev Address of the oracle contract
    address public oracle;

    ///@dev  Address of the USDT contract
    address public usdt;

    ///@dev  Mapping to store the shipping price for each item
    mapping(uint256 => uint256) public shippingPrices;

    ///@dev Mapping to store the commits by users
    mapping(address => bytes32) commitment;

    ///@dev Mapping to store the information of the items
    mapping(uint256 => Item) public items;
    
    ///@notice Details of ChainLink price oracle 
    /*
     * Network: Goerli
     * Aggregator: ETH/USD
     * Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
     */
    
    ///@dev instance of pricefeed contract
    AggregatorV3Interface internal priceFeed;
     
     ///@dev  Struct to handle marketplace Items
    struct Item {
        uint256 price;
        string name;
        address owner;
        bool exists;
    }

    ///@notice Events
    event ItemAdded(uint256 indexed id, string name);
    event ItemPurchased(address indexed buyer, uint256 indexed itemId);
     
     ///@dev Use of initialize instead of a contructor to achieve upgradable pattern
     ///@param _usdtcontract contract address of USDT
     ///@param _oracle contract address of pricefeed
    function initialize(address _usdtcontract, address _oracle)
        public
        initializer
    {
        priceFeed = AggregatorV3Interface(_oracle);
        oracle = _oracle;

        usdt = _usdtcontract;
    }

    ///@dev Function to add an item to the marketplace
    ///@param _id Id of new item to be added, must be unique
    ///@param _price,_shippingPrice has to passsed in terms of wei
    function addItem(
        uint256 _id,
        string memory _name,
        uint256 _price,
        uint256 _shippingPrice
    ) external {
        //Check for valid id
        require(!items[_id].exists, "Id already exists");

        // Add the item to the marketplace
        items[_id] = Item({
            price: _price,
            name: _name,
            owner: msg.sender,
            exists: true
        });

        // Add the shipping price for the item
        shippingPrices[_id] = _shippingPrice;

        // Emit an event to notify that the item was added
        emit ItemAdded(_id, _name);
    }

    ///@dev Function to add/Update shipping prices to the existing item
    ///@param _shippingPrice has to be passed in wei  
    function addShippingPrices(uint256 _id, uint256 _shippingPrice) external {
        require(
            items[_id].owner == msg.sender,
            "Only Item owner can add shipping prices"
        );
        shippingPrices[_id] = _shippingPrice;
    }

    ///@dev Function to purchase an item, only after reservation is done
    ///@notice the sending address should be the same as the one used for reserving

    function buyItem(uint256 id) external {
        bytes32 temphash = keccak256(abi.encodePacked(id, msg.sender));
        require(
            commitment[msg.sender] == temphash,
            "Please reserve item before purchase"
        );

        // Ensure that the item ID is valid
        require(items[id].exists, "Invalid item ID");

        // Get the item
        Item memory item = items[id];

        // Get the total cost of the item (including shipping)
        uint256 totalCost = item.price + shippingPrices[id];

        //Get eth price interms of USD
        uint256 latestusdtprice = uint256(getLatestPrice());

        //Convert usdt to 10**18 decimal
        latestusdtprice = latestusdtprice * 1e10;

        //The total cost in terms of USDT
        uint256 transferamount = (latestusdtprice * totalCost) / 1e18;

        //Converting transfer amount to 6 decimals for usdt token
        transferamount = transferamount / 1e12;

        // Ensure that the buyer has enough USDT
        require(
            IERC20(usdt).transferFrom(
                msg.sender,
                address(this),
                transferamount
            ),
            "Insufficient funds"
        );

        // Transfer ownership of the item to the buyer
        items[id].owner = msg.sender;

        //remove full filled commitment
        delete commitment[msg.sender];

        // Emit an event to notify that the item was purchased
        emit ItemPurchased(msg.sender, id);
    }
      
    ///@dev Function to get the shipping price for an item
    function getShippingPrice(uint256 id) external view returns (uint256) {
        return shippingPrices[id];
    }

    ///@dev Function to get the latest price from chainlink oracle
    function getLatestPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // for ETH / USD price is scaled up by 10 ** 8
        return price;
    }
  
  ///@dev generate hash using msg.sender to create unique hash's
    function generatehash(uint256 id) external view returns (bytes32) {
        return keccak256(abi.encodePacked(id, msg.sender));
    }

  ///@dev Reserve the item with out using Id using generatehash(uint256 id) function
    function reserve(bytes32 hash) external {
        require(
            commitment[msg.sender] == bytes32(0),
            "Please buy the item already reserved"
        );
        commitment[msg.sender] = hash;
    }
}