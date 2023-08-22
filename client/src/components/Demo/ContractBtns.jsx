import { useState, useEffect } from 'react'
import useEth from '../../contexts/EthContext/useEth'
import Web3 from 'web3'

function ContractBtns({ setValue }) {
  const {
    state: { contract, accounts },
  } = useEth()

  const [loading, setLoading] = useState(true)
  const [events, setEvents] = useState([])
  const [selectedEvent, setSelectedEvent] = useState(null)
  const [indexEvent, setIndexEvent] = useState(0)
  const [ticketNumber, setTicketNumber] = useState('')

  useEffect(() => {
    async function fetchData() {
      try {
        const totalEvents = await contract.methods
          .getTotalEvents()
          .call({ from: accounts[0] })
        console.log(totalEvents)
        const eventList = []

        for (let i = 0; i < totalEvents; i++) {
          const event = await contract.methods.events(i).call()
          const existingIndex = eventList.findIndex(
            (e) => e.name === event.name
          )

          if (existingIndex !== -1) {
            // Se l'evento esiste già nell'array, aggiornalo
            eventList[existingIndex] = {
              ...eventList[existingIndex],
              totalTickets: event.totalTickets,
              ticketsSold: event.ticketsSold,
              ticketPrice: event.ticketPrice,
            }
          } else {
            // Se l'evento non esiste, aggiungilo
            const eventData = {
              name: event.name,
              description: event.description,
              totalTickets: event.totalTickets,
              ticketsSold: event.ticketsSold,
              ticketPrice: event.ticketPrice,
            }
            eventList.push(eventData)
            console.log(eventData)
          }
        }
        setEvents(eventList)
        setLoading(false)
      } catch (error) {
        console.error('Errore durante la chiamata al contratto:', error)
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  const isPositiveInteger = (value) => {
    const intValue = parseInt(value)
    if (!isNaN(intValue) && intValue >= 0 && Number.isInteger(intValue)) {
      return true
    } else {
      return false
    }
  }

  const handleEventSelect = (eventIndex) => {
    setSelectedEvent(events[eventIndex])
    setIndexEvent(eventIndex)
  }

  const buyTicketsHandler = async () => {
    if (ticketNumber === '') {
      alert('Please enter all fields correctly')
    }
    if (!isPositiveInteger(ticketNumber)) {
      alert('Please insert a positive number')
    }
    try {
      const numberOfTicket = parseInt(ticketNumber)
      await contract.methods.buyTickets(indexEvent, numberOfTicket).send({
        from: accounts[0],
        gas: '500000',
        value: Web3.utils.toWei(ticketNumber, 'ether'),
      })
    } catch (error) {
      console.log(error)
    }
  }

  return (
    <>
      {loading ? (
        <p>Caricamento...</p>
      ) : (
        <div>
          <h1>Buy Tickets</h1>
          <form>
            <select onChange={(e) => handleEventSelect(e.target.value)}>
              <option value="">Select an event</option>
              {events.map((event, index) => (
                <option key={index} value={index}>
                  {event.name}
                </option>
              ))}
            </select>
            <input
              type="text"
              placeholder="Insert number of tickets"
              value={ticketNumber}
              onChange={(e) => {
                setTicketNumber(e.target.value)
              }}
            ></input>
            <button onClick={buyTicketsHandler}>Buy Tickets</button>
          </form>
          {selectedEvent && (
            <div>
              <h2>Selected Event Details:</h2>
              <p>Name: {selectedEvent.name}</p>
              <p>Description: {selectedEvent.description}</p>
              <p>Total Tickets: {selectedEvent.totalTickets}</p>
              <p>Tickets Sold: {selectedEvent.ticketsSold}</p>
              <p>Ticket Price: {selectedEvent.ticketPrice}$</p>
              {/* Aggiungi altri dettagli dell'evento qui */}
            </div>
          )}
        </div>
      )}
      <hr />
    </>
  )
}

export default ContractBtns
