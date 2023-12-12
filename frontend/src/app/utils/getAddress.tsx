export function getMockERC20Address(chainId: number) {
  if (chainId === 43113) {
    return "0xdA1E80e44B89F6a25e273f5e8A6E12a487e9fF65";
  } else {
    return "0x7D93981c72d974999C0dAC29D6502f47f213e274";
  }
}

export function getCERC20Address(chainId: number) {
  if (chainId === 43113) {
    return "0x64D31bffC434C64f694Fdae11f3144413356A636";
  } else {
    return "0xeBbAE973653c0e4C309ce4E3D453dD6F54425C17";
  }
}

export function getDaoAddress() {
  return "0x13fc9A39920f3de625763Aef00DE210F96EB345a";
}

export function getCurrentTimestamp() {
  return Math.floor(+ new Date() / 1000);
}