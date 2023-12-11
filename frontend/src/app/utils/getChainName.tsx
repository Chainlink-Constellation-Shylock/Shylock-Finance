export function getChainName(chainId: number) {
  switch (chainId) {
    case 43113:
      return "Avalanche Fuji";
    case 1442:
      return "Polygon zkEVM Testnet";
    case 11155111:
      return "Ethereum Sepolia Testnet";
    default:
      return "Unknown";
  }
}