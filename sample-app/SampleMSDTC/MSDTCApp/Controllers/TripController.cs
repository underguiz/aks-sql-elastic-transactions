using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

using MSDTCApp.DataAccessRepository;
using MSDTCApp.Models;

namespace MSDTCApp.Controllers
{
    public class TripController : Controller
    {

        MakeReservation reserv;

        public TripController()
        {
            reserv = new MakeReservation();
        }
        // GET: Trip
        public ActionResult Index()
        {
            return RedirectToAction("create");
        }

        public ActionResult Create()
        {
            return View("TripReservation");
        }

        //The Reservation Process
        [HttpPost]
        public ActionResult Create(TripReservation tripinfo)
        {
            try
            {
                tripinfo.Flight.TravellingDate = DateTime.Now;
                tripinfo.Hotel.BookingDate = DateTime.Now;
                var res = reserv.ReservTrip(tripinfo);

                if (!res)
                {
                    return View("Error");
                }
            }
            catch (Exception)
            {
                return View("Error");
            }
            return View("Success");
        }
    }
}