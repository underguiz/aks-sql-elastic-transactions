using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using System.Transactions;
using MSDTCApp.Models;

namespace MSDTCApp.DataAccessRepository
{
    public class MakeReservation
    {

        Flight flight;
        Hotel hotel;

        public MakeReservation()
        {
            flight = new Flight();
            hotel = new Hotel();
        }

        //The method for handling transactions 
        public bool ReservTrip(TripReservation trip)
        {
            bool reserved = false;

            //Define the scope for bundling the transaction
          using (var txscope = new TransactionScope(TransactionScopeOption.Required,
            new TransactionOptions { IsolationLevel = System.Transactions.IsolationLevel.ReadCommitted }))
            {
                try
                {

                    //The Flight Information
                    flight.AddFlight(trip.Flight);

                    //The Hotel Information
                    hotel.AddHotel(trip.Hotel);

                    reserved = true;
                    //The Transaction will be completed
                   txscope.Complete();
                }
                catch(Exception ex)
                {
                    throw ex;
                }

            }
            return reserved;
        }

    }
}