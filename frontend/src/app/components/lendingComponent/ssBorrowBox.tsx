
import { useState, useEffect } from 'react';
import { useWeb3ModalProvider, useWeb3ModalAccount } from '@web3modal/ethers5/react';
import { ethers } from 'ethers';
import { getChainName } from '@/app/utils/getChainName';
import { ShylockCErc20Abi } from '@/app/utils/abi/shylockCErc20Abi';
import { getMockERC20Address, getDaoAddress, getCurrentTimestamp } from '@/app/utils/getAddress';


export default function LendBox() {
  const [borrowAmount, setBorrowAmount] = useState('');
  const [defaultCurrency, setDefaultCurrency] = useState('ETH');
  const [selectedToken, setSelectedToken] = useState('ETH');
  const [showTokenList, setShowTokenList] = useState(false);
  const { address, chainId, isConnected } = useWeb3ModalAccount();
  const { walletProvider } = useWeb3ModalProvider();

  const mockERC20Address = getMockERC20Address();
  const daoAddress = getDaoAddress();

  useEffect(() => {
    const chainName = getChainName(chainId ?? 0);
    const currency = chainName === 'Avalanche Fuji' ? 'AVAX' : 'ETH';
    setDefaultCurrency(currency);
    setSelectedToken(currency);
  }, [chainId]);

  const handleInputChange = (e: any) => {
    setBorrowAmount(e.target.value);
  };

  const handleBorrow = async (e: any) => {
    e.preventDefault();
    if (!walletProvider || !isConnected) {
      console.log('Wallet not connected');
      return;
    }

    try {
      const provider = new ethers.providers.Web3Provider(walletProvider);
      const signer = provider.getSigner();
      const shylockCMockERC20 = new ethers.Contract(
        mockERC20Address,
        ShylockCErc20Abi,
        signer
      );
      const tx = await shylockCMockERC20.borrow(
        daoAddress,
        // 3 weeks from now
        getCurrentTimestamp() + 181440,
        ethers.utils.parseEther(borrowAmount)
      );
      await tx.wait();
      const timestamp = await getCurrentTimestamp();
      console.log('Borrow transaction completed');
    } catch (error) {
      console.error('Error during deposit transaction:', error);
    }
  };

  const toggleTokenList = () => {
    setShowTokenList(!showTokenList);
  };

  const handleTokenSelection = (token: string) => {
    setSelectedToken(token);
    setShowTokenList(false);
  };

  return (
    <div className='w-full'>
      <form onSubmit={handleBorrow}>
        <div className="mb-4">
          <label className="block text-gray-700 text-sm font-bold mb-2">
            Select Token:
          </label>
          <button type="button" onClick={toggleTokenList} className="bg-white border rounded py-2 px-4">
            {selectedToken} ↓
          </button>
          {showTokenList && (
          <div className="absolute mt-1 bg-white border border-gray-200 rounded shadow-lg z-10 w-40">
            <button 
              type="button" 
              onClick={() => handleTokenSelection(defaultCurrency)} 
              className="block w-full text-left px-4 py-2 hover:bg-gray-100"
            >
              {defaultCurrency}
            </button>
            <button 
              type="button" 
              onClick={() => handleTokenSelection('mockERC20')} 
              className="block w-full text-left px-4 py-2 hover:bg-gray-100"
            >
              mockERC20
            </button>
          </div>
        )}
        </div>
        <div className="mb-4 w-full">
          <label htmlFor="borrowAmount" className="block text-gray-700 text-sm font-bold mb-2">
            Borrow Amount ({selectedToken}):
          </label>
          <input
            type="number"
            id="borrowAmount"
            value={borrowAmount}
            onChange={handleInputChange}
            placeholder={`Enter amount in ${selectedToken}`}
            min="0"
            step="0.00001"
            className="shadow appearance-none border rounded w-full h-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          />
        </div>
        <button type="submit" className="bg-[#755f44] hover:bg-[#765f99] text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline">
          Borrow
        </button>
      </form>
    </div>
  );
}