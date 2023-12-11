
import { useState, useEffect } from 'react';
import { useWeb3ModalProvider, useWeb3ModalAccount } from '@web3modal/ethers5/react';
import { ethers } from 'ethers';
import { getChainName } from '../../utils/getChainName';
import { ShylockCErc20Abi } from '../../utils/abi/ShylockCErc20Abi';
import { ERC20Abi } from '@/app/utils/abi/erc20Abi';
import { getMockERC20Address, getDaoAddress, getCERC20Address } from '@/app/utils/getAddress';
import { toast } from 'react-toastify';

export default function LendBox() {
  const [repayAmount, setrepayAmount] = useState('');
  const [defaultCurrency, setDefaultCurrency] = useState('ETH');
  const [selectedToken, setSelectedToken] = useState('DAI');
  const [showTokenList, setShowTokenList] = useState(false);
  const { address, chainId, isConnected } = useWeb3ModalAccount();
  const { walletProvider } = useWeb3ModalProvider();

  

  const daoAddress = getDaoAddress();
  useEffect(() => {
    const chainName = getChainName(chainId ?? 0);
    const currency = chainName === 'Avalanche Fuji' ? 'AVAX' : 'ETH';
    setDefaultCurrency(currency);
    setSelectedToken(currency);
  }, [chainId]);

  const handleInputChange = (e: any) => {
    setrepayAmount(e.target.value);
  };

  const handleRepay = async (e: any) => {
    e.preventDefault();

    if (!walletProvider || !isConnected) {
      console.log('Wallet not connected');
      return;
    }

    try {
      // Connect to the network
      const provider = new ethers.providers.Web3Provider(walletProvider);
      const signer = provider.getSigner();
      if (!chainId) {
        console.log('ChainId not found');
        return;
      } 
      const mockERC20Address = getMockERC20Address(chainId);
      const cERC20Address = getCERC20Address(chainId);
      const contract = new ethers.Contract(mockERC20Address, ERC20Abi, signer);
      const cTokencontract = new ethers.Contract(cERC20Address, ShylockCErc20Abi, signer);
      toast.info('Approving...', {
        position: "top-right",
        autoClose: 15000,
        hideProgressBar: false,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "dark",
      });
      const approveTx = await contract.approve(cTokencontract, ethers.utils.parseUnits(repayAmount));
      console.log('Transaction:', approveTx);
      await approveTx.wait();

      toast.info('Repaying...', {
        position: "top-right",
        autoClose: 15000,
        hideProgressBar: false,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "dark",
      });
      const tx = await cTokencontract.repayBorrow(ethers.utils.parseUnits(repayAmount));

      console.log(`Repaying ${repayAmount} ${selectedToken}`);
      console.log('Transaction:', tx);

      // Wait for the transaction to be mined
      await tx.wait();
      console.log('Repay transaction completed');
      toast.success(`Success! Here is your transaction:${tx.receipt.transactionHash} `, {
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
      console.error('Error during repay transaction:', error);
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
      <form onSubmit={handleRepay}>
        <div className="mb-4">
          <label className="block text-gray-700 text-medium font-bold mb-2">
            Repay and Earn Interest
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
          <label htmlFor="repayAmount" className="block text-gray-700 text-sm font-bold mb-2">
            Repay Amount ({selectedToken}):
          </label>
          <input
            type="number"
            id="repayAmount"
            value={repayAmount}
            onChange={handleInputChange}
            placeholder={`Enter amount in ${selectedToken}`}
            min="0"
            step="0.00001"
            className="shadow appearance-none border rounded w-full h-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          />
        </div>
        <button onClick={() => handleRepay(repayAmount)} className="bg-[#755f44] hover:bg-[#765f99] text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline">
          Repay
        </button>
      </form>
    </div>
  );
}