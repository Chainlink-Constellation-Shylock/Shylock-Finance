export function getMockERC20Address(chainId: number) {
  if (chainId === 43113) {
    return "0xF0452f5cB881C3fF5f8E81dD6De7ACB6E1df4375";
  } else {
    return "0xF87f500691277971aF04D4F8eb3DB2C5CFCAcdec";
  }
}

export function getCERC20Address(chainId: number) {
  if (chainId === 43113) {
    return "0xE3777aCccBa34F04E1cb9e05D16644F60CbCb489";
  } else {
    // TODO: change to gateway address maybe?
    return "0xe1988030b35095BE6FF9F527e9C4dE73A101C1A0";
  }
}

export function getDaoAddress() {
  return "0x7878099b167Abed0eB458727dCFe82200E4f7123";
}

export function getCurrentTimestamp() {
  return Math.floor(+ new Date() / 1000);
}