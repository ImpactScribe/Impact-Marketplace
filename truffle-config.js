// require('dotenv').config();
// const { OP_PRIVATE_KEY } = process.env;
// const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    // mainnet: {
    //   provider: () => new HDWalletProvider(OP_PRIVATE_KEY, "https://optimism-mainnet.infura.io", 0, 2),
    //   network_id: 10,
    //   gas: 8500000,
    //   gasPrice: 1000000000000,
    //   skipDryRun: true
    // }
  },

  compilers: {
    solc: {
      version: "0.8.20",      // Fetch exact version from solc-bin (default: truffle's version)
    }
  },
};