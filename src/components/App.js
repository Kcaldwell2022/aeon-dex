import { useEffect } from 'react'
import config from '../config.json'
import { useDispatch } from 'react-redux'
import { 
  loadProvider, 
  loadNetwork, 
  loadAccount,
  loadTokens,
  loadExchange,
  subscribeToEvents,
  loadAllOrders
} from '../store/interactions'

import Navbar from './Navbar'
import Markets from './Markets'
import Balance from './Balance'
import Order from './Order'
import PriceChart from './PriceChart'
import Transactions from './Transactions'
import Trades from './Trades'
import OrderBook from './OrderBook'
import Alert from './Alert'

function App() {

  const dispatch = useDispatch()

  async function loadBlockchainData() {
    //Connect Ethers to blockchain
    const provider = loadProvider(dispatch)
    //Fetch current networks chainID
    const chainId = await loadNetwork(provider, dispatch)
    //Reload page when chain changes
    window.ethereum.on('chainChanged', () => {
      window.location.reload()
    })
    //Fetch currount account and balance from metamask when changed
    window.ethereum.on('accountsChanged', () => {
      loadAccount(provider, dispatch)
    })
    //Load token smart contracts
    const aeon = config[chainId].Aeon
    const mETH = config[chainId].mETH
    await loadTokens(provider, [aeon.address, mETH.address], dispatch)
    //Load exchange smart contracts
    const exchangeConfig = config[chainId].exchange
    const exchange = await loadExchange(provider, exchangeConfig.address, dispatch)
    //Fetch all orders: open, filled, cancelled
    loadAllOrders(provider, exchange, dispatch)
    //Listen to events
    subscribeToEvents(exchange, dispatch)
  }

  //Calls loadBlockchainData after render
  useEffect(() => {
    loadBlockchainData()
  })

  return (
    <div>

      <Navbar />

      <main className='exchange grid'>
        <section className='exchange__section--left grid'>

          <Markets />

          <Balance />

          <Order />

        </section>
        <section className='exchange__section--right grid'>

          <PriceChart />

          <Transactions />

          <Trades />

          <OrderBook />

        </section>
      </main>

      <Alert />

    </div>
  );
}

export default App;
