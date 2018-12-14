//
//  ListTableViewController.swift
//  SmoothTransfers
//
//  Created by Noritaka Sekiyama on 2018/08/31.
//  Copyright © 2018年 Noritaka Sekiyama. All rights reserved.
//

import UIKit
import APIKit
import EventKit
import MapKit

class ListTableViewController: UITableViewController {
    var testEventLocation = ""
    var cellIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.rowHeight = 300

        // Accessing Calendar data
        let eventStore = EKEventStore()
        
        let status = EKEventStore.authorizationStatus(for: .event)
        var isAuth = false
        switch status {
        case .notDetermined:
            isAuth = false
        case .restricted:
            isAuth = false
        case .denied:
            isAuth = false
        case .authorized:
            isAuth = true
        }
        if !isAuth {
            eventStore.requestAccess(to: .event, completion: {
                (granted, error) in
                if granted {
                    print("granted")
                }
                else {
                    print("rejected")
                    return
                }
            })
        }

        // Adding Calendar data (Dummy)
        let event = EKEvent(eventStore: eventStore)
        event.title = "test 2018-08-31"
        event.location = "Meguro station"
        event.startDate = Calendar.current.date(from: DateComponents(year: 2018, month: 8, day: 10, hour: 19, minute: 30, second: 00))
        event.endDate = Calendar.current.date(from: DateComponents(year: 2018, month: 8, day: 10, hour: 22, minute: 00, second: 00))
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.save(event, span: .thisEvent)
        }
        catch let error {
            print(error)
        }
        
        // Retrieving Calendar data
        let startDate = Calendar.current.date(from: DateComponents(year: 2018, month: 8, day: 1, hour: 00, minute: 00, second: 00))
        let endDate = Calendar.current.date(from: DateComponents(year: 2018, month: 8, day: 31, hour: 23, minute: 59, second: 59))
        let defaultCalendar = eventStore.defaultCalendarForNewEvents
        let predicate = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: [defaultCalendar!])
        let events = eventStore.events(matching: predicate)
        print(events)
        
        
        print("Retrieving location for events")
        for e in events {
            testEventLocation = e.location!
            
            // Placemark to latitude/longtitude
            CLGeocoder().geocodeAddressString(testEventLocation, completionHandler: { placemarks, error in
                if (error != nil) {
                    return
                }
                
                if let placemark = placemarks?[0]  {
                    let lat = String(format: "%.04f", (placemark.location?.coordinate.longitude ?? 0.0)!)
                    let lon = String(format: "%.04f", (placemark.location?.coordinate.latitude ?? 0.0)!)
                    let name = placemark.name!
                    let country = placemark.country!
                    let region = placemark.administrativeArea!
                    print("\(lat),\(lon)\n\(name),\(region) \(country)")
                }
            })
        }
        
        
        
        // Tokyo Ko-tsu Open Data API
        let request1 = TokyoChallengeAPI.StationTimetable(stationID: "odpt.Station:JR-East.JobanRapid.Ueno")
        //Session.send(request1) { print($0) }
       
        let request2 = TokyoChallengeAPI.Railway(railwayID: "odpt.Railway:JR-East.JobanRapid")
        //Session.send(request2) { print($0) }

        let request3 = TokyoChallengeAPI.TrainTimetable(railwayID: "odpt.Railway:JR-East.JobanRapid")
        //Session.send(request3) { print($0) }

        // MapKit API to get route
        print("Accessing MapKit")
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 35.681382, longitude: 139.76608399999998), addressDictionary: nil)) // tokyo station
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 35.63398, longitude: 139.716), addressDictionary: nil)) // meguro station
        request.requestsAlternateRoutes = true;
        request.transportType = MKDirectionsTransportType.any
        
        let directions = MKDirections(request: request)
        
//        directions.calculate(completionHandler: {(response, error) in
//
//            guard let routes = response?.routes else {
//                print(error)
//                return
//            }
//            for route in routes {
//                print("==Route==")
//                print(route.name)
//                print(route.transportType)
//                print(route.distance)
//                print(route.expectedTravelTime)
//                print(route.advisoryNotices)
//                for step in route.steps {
//                    print(step.distance)
//                    print(step.instructions)
//                    print(step.transportType)
//                }
//            }
//
//        })
        
        // calculate ETA
        print("Accessing MapKit for ETA")
        let requestETA = MKDirectionsRequest()
        requestETA.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 35.706419, longitude: 139.7812513), addressDictionary: nil)) // Okachimachi church
        requestETA.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 35.6320029, longitude: 139.7113484), addressDictionary: nil)) // Meguro Gajoen
        requestETA.requestsAlternateRoutes = true;
        requestETA.transportType = MKDirectionsTransportType.transit
        
        let directionsETA = MKDirections(request: requestETA)
        
        directionsETA.calculateETA(completionHandler: {(response, error) in
            
            if (error != nil){
                print(error)
            }
            
            print(response?.source)
            print(response?.destination)
            print(response?.expectedDepartureDate)
            print(response?.expectedArrivalDate)
            print(response?.expectedTravelTime)

            
        })

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            as! TableViewCell
        // Configure the cell...
        
       
        cell.timeLabel.text = "00:00"
        cell.timerLabel.text = "0"
        cell.judgementLabel.text = testEventLocation
        
        print()
        if (cellIndex % 2 == 0) {
            cell.contentView.backgroundColor = UIColor.red
        } else {
            cell.contentView.backgroundColor = UIColor.green
        }
        cellIndex += 1

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
