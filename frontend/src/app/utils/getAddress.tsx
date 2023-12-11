export function getMockERC20Address(chainId: number) {
  if (chainId === 43113) {
    return "0xA0A92Fc977b988955d82cd53380c9ba762AA1046";
  } else {
    return "0x6C059fb878D1c552b41BcdA72C3E07c12618AaBD";
  }
}

export function getCERC20Address(chainId: number) {
  if (chainId === 43113) {
    return "0x2ac96E775d9aba016fD6f50F63B6D57cf43766A0";
  } else {
    return "0xe1988030b35095BE6FF9F527e9C4dE73A101C1A0";
  }
}

export function getDaoAddress() {
  return "0x8d92b1E5B022b60c2662Ad8CAb7E6F409f9fF496";
}

export function getCurrentTimestamp() {
  return Math.floor(+ new Date() / 1000);
}