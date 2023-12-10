
import { useState, useEffect } from 'react';
import { useWeb3ModalProvider, useWeb3ModalAccount } from '@web3modal/ethers5/react';
import { ethers } from 'ethers';
import { getChainName } from '@/app/utils/getChainName';

export default function LendBox() {
  const [depositAmount, setDepositAmount] = useState('');
  const [defaultCurrency, setDefaultCurrency] = useState('ETH');
  const [selectedToken, setSelectedToken] = useState('ETH');
  const [showTokenList, setShowTokenList] = useState(false);
  const { address, chainId, isConnected } = useWeb3ModalAccount();
  const { walletProvider } = useWeb3ModalProvider();

  // @TODO Fix this
  const mockERC20Address = "0x3f0A0EA2f86baE6362CF9799B523BA06647Da018";

  useEffect(() => {
    const chainName = getChainName(chainId ?? 0);
    const currency = chainName === 'Avalanche Fuji' ? 'AVAX' : 'ETH';
    setDefaultCurrency(currency);
    setSelectedToken(currency);
  }, [chainId]);

  const handleInputChange = (e: any) => {
    setDepositAmount(e.target.value);
  };

  const handleDeposit = (e: any) => {
    e.preventDefault();
    console.log(`Depositing ${depositAmount} ${selectedToken}`);
    // Add your smart contract interaction logic here
  };

  const toggleTokenList = () => {
    setShowTokenList(!showTokenList);
  };

  const handleTokenSelection = (token: string) => {
    setSelectedToken(token);
    setShowTokenList(false);
  };

  // const handleAddTokenToMetamask = async (token: string) => {
  //   console.log(`Adding ${token} to Metamask`);
  //   await addMockERC20TokenToMM();
  // };

  // const addMockERC20TokenToMM = async () => {
  //   try {
  //     const provider = walletProvider;
  //     if (isConnected && provider) {
  //       await provider?.request?({
  //         method: 'wallet_watchAsset',
  //         params: {
  //           type: 'ERC20',
  //           options: {
  //             address: mockERC20Address,  // ERC20 token address
  //             symbol: `MockERC20`,
  //             decimals: 18,
  //             image: 'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x6B175474E89094C44Da98b954EedeAC495271d0F/logo.png',
  //           },
  //         },
  //       });
  //     }
      
  //   } catch (error) {
  //     console.error('Error adding token to Metamask:', error);
  //   }
  // }

  return (
    <div className='w-full'>
      <form onSubmit={handleDeposit}>
        <div className="mb-4">
          <label className="block text-gray-700 text-sm font-bold mb-2">
            Select Token:
          </label>
          <button type="button" onClick={toggleTokenList} className="bg-white border rounded py-2 px-4">
            {selectedToken} ↓
          </button>
          {showTokenList && (
            <div className="mt-2">
              <div className="flex justify-between items-center mb-2">
                <button type="button" onClick={() => handleTokenSelection(defaultCurrency)}>{defaultCurrency}</button>
              </div>
              <div className="flex justify-between items-center">
                <button type="button" onClick={() => handleTokenSelection('mockERC20')}>mockERC20</button>
                {/* <button type="button" onClick={() => handleAddTokenToMetamask('mockERC20')}>Add to Metamask</button> */}
              </div>
            </div>
          )}
        </div>
        <div className="mb-4 w-full">
          <label htmlFor="depositAmount" className="block text-gray-700 text-sm font-bold mb-2">
            Deposit Amount ({selectedToken}):
          </label>
          <input
            type="number"
            id="depositAmount"
            value={depositAmount}
            onChange={handleInputChange}
            placeholder={`Enter amount in ${selectedToken}`}
            min="0"
            step="0.00001"
            className="shadow appearance-none border rounded w-full h-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          />
        </div>
        <button type="submit" className="bg-[#755f44] hover:bg-[#765f99] text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline">
          Deposit
        </button>
      </form>
    </div>
  );
}