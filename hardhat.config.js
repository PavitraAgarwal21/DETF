require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */
const PRIVATE_KEY = process.env.PRIVATE_KEY;

module.exports = {
  defaultNetwork: "localhost", 
   networks: {
    hardhat: {
      chainId: 1337
    },
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/cmCgE3NJ3zeb_MnPym0Au115tETpdcMi",
      accounts: [PRIVATE_KEY]
    },
    pzkevm : {
      url : "https://polygonzkevm-cardona.g.alchemy.com/v2/cmCgE3NJ3zeb_MnPym0Au115tETpdcMi",
      accounts : [PRIVATE_KEY]
    },
    optimism : {
      url : "https://opt-sepolia.g.alchemy.com/v2/cmCgE3NJ3zeb_MnPym0Au115tETpdcMi",
      accouts : [PRIVATE_KEY]
    }
  },
  solidity: "0.8.24",
};
