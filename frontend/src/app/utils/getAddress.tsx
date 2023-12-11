export function getMockERC20Address(chainId: number) {
  if (chainId === 43113) {
    return "0xA0A92Fc977b988955d82cd53380c9ba762AA1046";
  } else {
    return "";
  }
}

export function getCERC20Address(chainId: number) {
  if (chainId === 43113) {
    return "0xA0A92Fc977b988955d82cd53380c9ba762AA1046";
  } else {
    return "";
  }
}

export function getDaoAddress() {
  return "0x000000";
}

export function getCurrentTimestamp() {
  return Math.floor(+ new Date() / 1000);
}