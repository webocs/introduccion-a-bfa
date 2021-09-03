module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8877,
      network_id: "123456" // Match any network id
    },
    bfaDev: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "55555000000" // Network ID BFA test
    }
  },
  compilers: {
    solc: {
      version: "^0.7.0"
    }
  }
};
