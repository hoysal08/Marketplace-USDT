// pragma solidity ^0.8.0;

//  import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// // import "@openzeppelin/contracts/proxy/UpgradeabilityProxy.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// contract Marketplace  {
//     // Mapping to store the shipping price for each item
//     mapping(uint => uint) public shippingPrices;

//     //Mapping to store the commits by users
//     mapping(address=>bytes32) commitment;

//     // Address of the oracle contract
//     address public oracle;

//     // Address of the USDT contract
//     address public usdt;

//     // Mapping to store the information of the items
//     mapping(uint => Item) public items;

//     struct Item {
//         uint price;
//         string name;
//         address owner;
//         bool exists;
//     }

//     // Events
//     event ItemAdded(uint id, string name);
//     event ItemPurchased(address buyer, uint itemId);


//     /**
//      * Network: Goerli
//      * Aggregator: ETH/USD
//      * Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
//      */

//      // assume usdt address : 0x6BABFBA7200f683c267ce892C94e1e110Df390c7
//     AggregatorV3Interface internal priceFeed;

//     constructor(address _usdtcontract,address _oracle)
//     {
//         //  priceFeed=AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
//         //  oracle=0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e;
        
//          priceFeed=AggregatorV3Interface(_oracle);
//          oracle=_oracle;
        
        
//          usdt=_usdtcontract;
//     }

//     // Function to add an item to the marketplace
//     function addItem(uint id,string memory name, uint price, uint shippingPrice) public {
//        //Check for valid id
//        require(!items[id].exists,"Id already exists");
      
//         // Add the item to the marketplace
//         items[id] = Item({
//             price: price,
//             name: name,
//             owner: msg.sender,
//             exists:true
//         });

//         // Add the shipping price for the item
//         shippingPrices[id] = shippingPrice;

//         // Emit an event to notify that the item was added
//         emit ItemAdded(id, name);
//     }

//     //Function to add shipping prices to the existing item
//     function addShippingPrices(uint id, uint shippingPrice) public{

//         require(items[id].owner==msg.sender,"Only Item owner can add shipping prices");
//         shippingPrices[id] = shippingPrice;
//     }

//     // Function to purchase an item
//     function buyItem(uint id) public {
       
        
//         bytes32  temphash = keccak256(abi.encodePacked(id,msg.sender));
//         require(commitment[msg.sender]==temphash,"Please reserve item before purchase");

//         // Ensure that the item ID is valid
//         require(items[id].exists, "Invalid item ID");
        
//         // Get the item
//         Item storage item = items[id];

//         // Get the total cost of the item (including shipping)
//         uint totalCost = item.price + shippingPrices[id];
         
//          //Get eth price interms of USD
//         uint latestusdtprice=uint(getLatestPrice());

//         //Coverting cost interms of ETH
//         totalCost=totalCost/1e18;

//         //The total cost in terms of USDT
//         uint transferamount=totalCost*latestusdtprice;
//         transferamount=transferamount*1e6;

//         // Ensure that the buyer has enough USDT
//         require(IERC20(usdt).transferFrom(msg.sender, address(this), transferamount), "Insufficient funds");

//         // Transfer ownership of the item to the buyer
//         item.owner = msg.sender;

//         //remove full filled commitment
//         delete commitment[msg.sender];
        
//         // Emit an event to notify that the item was purchased
//         emit ItemPurchased(msg.sender, id);
//     }

//     // Function to get the shipping price for an item
//     function getShippingPrice(uint id) public view returns (uint) {
//         return shippingPrices[id];
//     }
//     //Function to get the latest price from chainlink oracle
//     function getLatestPrice() public view returns (int) {
//     (
//       uint80 roundID,
//       int price,
//       uint startedAt,
//       uint timeStamp,
//       uint80 answeredInRound
//     ) = priceFeed.latestRoundData();
//     // for ETH / USD price is scaled up by 10 ** 8
//     return price / 1e8;
//   }
//     function generatehash( uint256 id) public view returns (bytes32) {
//         return keccak256(abi.encodePacked(id,msg.sender));
//     }

//     function reserve(bytes32 hash) public {
//         require(commitment[msg.sender]==bytes32(0),"Please buy the item already reserved");
//         commitment[msg.sender] = hash;
//     }

// }