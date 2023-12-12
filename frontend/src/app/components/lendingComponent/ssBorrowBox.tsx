
import { useState, useEffect } from 'react';
import { useWeb3ModalProvider, useWeb3ModalAccount } from '@web3modal/ethers5/react';
import { ethers } from 'ethers';
import { getChainName } from '../../utils/getChainName';
import { ShylockCErc20Abi } from '../../utils/abi/ShylockCErc20Abi';
import { getCERC20Address, getDaoAddress, getCurrentTimestamp } from '../../utils/getAddress';
import { toast, ToastContainer } from 'react-toastify';

export default function LendBox() {
  const [borrowAmount, setBorrowAmount] = useState('');
  const [defaultCurrency, setDefaultCurrency] = useState('ETH');
  const [selectedToken, setSelectedToken] = useState('ETH');
  const [showTokenList, setShowTokenList] = useState(false);
  const { address, chainId, isConnected } = useWeb3ModalAccount();
  const { walletProvider } = useWeb3ModalProvider();

  
  const daoAddress = getDaoAddress();

  useEffect(() => {
    const chainName = getChainName(chainId ?? 0);
    const currency = chainName === 'Avalanche Fuji' ? 'AVAX' : 'ETH';
    setDefaultCurrency(currency);
    setSelectedToken(currency);
  }, []);

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
      if (!chainId || !address) {
        console.log('ChainId not found');
        return;
      }
      const cERC20Address = getCERC20Address(chainId);
      const shylockCERC20 = new ethers.Contract(cERC20Address, ShylockCErc20Abi, signer);
      toast.info('Borrowing...', {
        position: "top-right",
        autoClose: 15000,
        hideProgressBar: false,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "dark",
      });
      const dueTimeStamp = getCurrentTimestamp() + 181440;

      const tx = await shylockCERC20.borrow(daoAddress, dueTimeStamp, ethers.utils.parseUnits(borrowAmount));
      const receipt = await tx.wait();
      console.log('Borrow transaction completed');
      toast.success(`Success! Here is your transaction:${receipt.transactionHash} `, {
        position: "top-right",
        autoClose: 18000,
        hideProgressBar: false,
        closeOnClick: false,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "dark",
      });
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
          <label className="block text-gray-700 text-medium font-bold mb-2">
            Deposit and Earn Interest
          </label>
          <hr/>
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
              onClick={() => handleTokenSelection('DAI')} 
              className="block w-full text-left px-4 py-2 hover:bg-gray-100"
            >
              DAI
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
      <ToastContainer
        position="top-right"
        autoClose={5000}
        hideProgressBar={false}
        newestOnTop={false}
        closeOnClick
        rtl={false}
        pauseOnFocusLoss
        draggable
        pauseOnHover
        theme="dark"
      />
    </div>
  );
}