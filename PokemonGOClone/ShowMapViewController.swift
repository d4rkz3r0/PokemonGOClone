//
//  ViewController.swift
//  PokemonGOClone
//
//  Created by Steve Kerney on 1/22/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import UIKit
import MapKit

class ShowMapViewController: UIViewController, CLLocationManagerDelegate
{

    // VC UI Vars
    @IBOutlet weak var mapView: MKMapView!
    
    // MapKit Location Manager
    var manager = CLLocationManager();
    
    // Misc
    var updateCount = 0;
    
    // Consts
    let INITIAL_UPDATE_THRESHOLD = 3;
    let LATITUDE_SPAN = 350.0;
    let LONGITUDE_SPAN = 350.0;
    
    
    
    
    // Init
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Setup Manager
        manager.delegate = self;
        
        //Get user GPS access
        if(CLLocationManager.authorizationStatus() != .authorizedWhenInUse)
        {
            manager.requestWhenInUseAuthorization();
        }
        //Enable GPS heartbeat function
        manager.startUpdatingLocation();
        
        //Spawn Pokemon Annotations on MapView
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
          
            //Spawn a Pokemon randomly near the user's location on a fixed interval.
            if let userCoordinate = self.manager.location?.coordinate
            {
                //Create Annotation
                let mapAnnotation = MKPointAnnotation();
                mapAnnotation.coordinate = userCoordinate;
                //Modify Annotation
                let randomLatitude = (Double(arc4random_uniform(200)) - 100.0) / 50000.0;
                let randomLongitude = (Double(arc4random_uniform(200)) - 100.0) / 50000.0;
                mapAnnotation.coordinate.latitude += randomLatitude;
                mapAnnotation.coordinate.longitude += randomLongitude;
                //Add to MapView
                self.mapView.addAnnotation(mapAnnotation);
            }
        };
    }
    
    // GPS Update Tick
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //Zoom in to users current location for 3 ticks.
        if(updateCount < INITIAL_UPDATE_THRESHOLD)
        {
            let currRegion = MKCoordinateRegionMakeWithDistance(manager.location!.coordinate, LATITUDE_SPAN , LONGITUDE_SPAN);
            mapView.setRegion(currRegion, animated: false);
            updateCount += 1;
        }
        else
        {
            manager.stopUpdatingLocation();
        }
    }
    
    // UI Button Funcs
    @IBAction func MyLocationPressed(_ sender: Any)
    {
        if let coordinate = manager.location?.coordinate
        {
            let currRegion = MKCoordinateRegionMakeWithDistance(coordinate, LATITUDE_SPAN , LONGITUDE_SPAN);
            mapView.setRegion(currRegion, animated: true);
        }
    }
}

