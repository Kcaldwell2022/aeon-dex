import { useState, useRef } from 'react'
import { makeBuyOrder, makeSellOrder } from '../store/interactions'
import { useDispatch, useSelector } from 'react-redux'

const Order = () => {

  //If true, buyHandler is called on submit, else sellHandler is called
  const [isBuy, setIsBuy] = useState(true)

  //Input values for order creation
  const [amount, setAmount] = useState(0)
  const [price, setPrice] = useState(0)

  //Variables pulled from Redux store
  const provider = useSelector(state => state.provider.connection)
  const tokens = useSelector(state => state.tokens.contracts)
  const exchange = useSelector(state => state.exchange.contract)

  const dispatch = useDispatch()

  //Refs for buttons on line 59/69
  const buyRef = useRef(null)
  const sellRef = useRef(null)

  //Changes button styling and determines if buyHandler or sellHandler is called on submit
  const tabHandler = (e) => {
    if(e.target.className !== buyRef.current.className) {
      e.target.className = 'tab tab--active'
      buyRef.current.className = 'tab'
      setIsBuy(false)
    } else {
      e.target.className = 'tab tab--active'
      sellRef.current.className = 'tab'
      setIsBuy(true)
    }
  }

  //Passes variables and calls makeBuyOrder function
  const buyHandler = (e) => {
    e.preventDefault()
    makeBuyOrder(provider, exchange, tokens, { amount, price }, dispatch)
    console.log('BUYING>>>')
    setAmount(0)
    setPrice(0)
  }

  //Passes variables and calls makeSellOrder function
  const sellHandler = (e) => {
    e.preventDefault()
    makeSellOrder(provider, exchange, tokens, { amount, price }, dispatch)
    console.log("SELLING>>>")
    setAmount(0)
    setPrice(0)
  }

  return (
    <div className="component exchange__orders">
      <div className='component__header flex-between'>
        <h2>New Order</h2>
        <div className='tabs'>
          <button onClick={tabHandler} ref={buyRef} className='tab tab--active'>Buy</button>
          <button onClick={tabHandler} ref={sellRef} className='tab'>Sell</button>
        </div>
      </div>

      <form onSubmit={isBuy ? buyHandler : sellHandler }>
        {isBuy ? <label htmlFor='amount'>Buy Amount</label> : <label htmlFor='amount'>Sell Amount</label>}
        <input 
          type="text" 
          id='amount'
          placeholder='0.0000'
          value={amount === 0 ? '' : amount}
          onChange={(e) => setAmount(e.target.value)}
        />
        {isBuy ? <label>Buy Price</label> : <label>Sell Price</label>}
        <input 
          type="text" 
          id='price' 
          placeholder='0.0000'
          value={price === 0 ? '' : price} 
          onChange={(e) => setPrice(e.target.value)}
        />

        <button className='button button--filled' type='submit'>
          {isBuy ? <span>Buy Order</span> : <span>Sell Order</span>}
        </button>
      </form>
    </div>
  );
}

export default Order;
