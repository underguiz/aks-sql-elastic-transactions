using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MSDTCApp.Models
{
    public class TripReservation
    {
        public Flight Flight { get; set; }
        public Hotel Hotel { get; set; }
    }
}