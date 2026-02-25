// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public networkPointer;

    uint8 public constant DECIMAL_MOCKV3 = 8;
    int256 public constant INITIAL_ANSWER_MOCKV3 = 2000e8;

    constructor() {
        if (block.chainid == 1) {
            networkPointer = getEthMainnetUsdPriceFeed();
        } else if (block.chainid == 11155111) {
            networkPointer = getSepoliaEthUsdPriceFeed();
        } else {
            networkPointer = getOrCreateAnvilEthUsdPriceFeed();
        }
    }

    function getSepoliaEthUsdPriceFeed() public pure returns (NetworkConfig memory) {
        // Sepolia ETH/USD price feed address
        NetworkConfig memory sepoliaNetworkConfig =
            NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaNetworkConfig;
    }

    function getEthMainnetUsdPriceFeed() public pure returns (NetworkConfig memory) {
        // Mainnet ETH/USD price feed address
        NetworkConfig memory mainnetNetworkConfig =
            NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainnetNetworkConfig;

        // return NetworkConfig({
        //     priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        // });
    }

    function getOrCreateAnvilEthUsdPriceFeed() public returns (NetworkConfig memory) {
        if (networkPointer.priceFeed != address(0)) {
            return networkPointer;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMAL_MOCKV3, INITIAL_ANSWER_MOCKV3);
        vm.stopBroadcast();

        NetworkConfig memory anvilNetworkConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilNetworkConfig;

        // return NetworkConfig({
        //     priceFeed: address(0) // temporary, but should be mock
        // });
    }
}
