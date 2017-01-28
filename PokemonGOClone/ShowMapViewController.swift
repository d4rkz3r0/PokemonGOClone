//
//  ViewController.swift
//  PokemonGOClone
//
//  Created by Steve Kerney on 1/22/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import UIKit
import MapKit

class ShowMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate
{

    // VC UI Vars
    @IBOutlet weak var mapView: MKMapView!
    
    // MapKit Location Manager
    var manager = CLLocationManager();
    
    // Pokemon
    var pokemonArr : [Pokemon] = [];
    
    // Misc
    var updateCount = 0;
    
    // Consts
    let INITIAL_UPDATE_THRESHOLD = 3;
    let LATITUDE_SPAN = 350.0;
    let LONGITUDE_SPAN = 350.0;
    let POKEMON_CATCH_LATITUDE_SPAN = 200.0;
    let POKEMON_CATCH_LONGITUDE_SPAN = 200.0;
    let PKMN_INTERVAL_SPAWN_TIMER = 5.0;
    
    
    // Init
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        pokemonArr = getAllPokemon();
        
        
        //Get user GPS access
        if(CLLocationManager.authorizationStatus() != .authorizedWhenInUse)
        {
            manager.requestWhenInUseAuthorization();
        }
        
        //Setup Manager
        manager.delegate = self;
        
        //Enable GPS heartbeat function
        manager.startUpdatingLocation();
        
        //Setup MapView
        mapView.delegate = self;
        
        //Spawn Pokemon Annotations on MapView
        Timer.scheduledTimer(withTimeInterval: PKMN_INTERVAL_SPAWN_TIMER, repeats: true) { (timer) in
          
            //Spawn a Pokemon randomly near the user's location on a fixed interval.
            if let userCoordinate = self.manager.location?.coordinate
            {
                //Create Annotation
                let pokemonToSpawn = self.pokemonArr[Int(arc4random_uniform(UInt32(self.pokemonArr.count)))];
                
                let mapAnnotation = PKMNAnnotation(coordinate : userCoordinate, pokemon : pokemonToSpawn);
                
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
    
    // Custom Annotation View
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        //Use Trainer Image for User
        if(annotation is MKUserLocation)
        {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil);
            annotationView.image = UIImage(named : "player");
            
            //Proper image scaling
            var adjustedFrame = annotationView.frame;
            adjustedFrame.size.height = 50.0;
            adjustedFrame.size.width = 50.0;
            annotationView.frame = adjustedFrame;
            
            return annotationView;
        }
        
        //Use Appropriate Pokemon Image for all other overriden PKMNAnnotations
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil);
        let pokemonToSpawn = (annotation as! PKMNAnnotation).pokemon;
        
        annotationView.image = UIImage(named : pokemonToSpawn.imageName!);
        
        //Proper image scaling
        var adjustedFrame = annotationView.frame;
        adjustedFrame.size.height = 50.0;
        adjustedFrame.size.width = 50.0;
        annotationView.frame = adjustedFrame;
        
        
        return annotationView;
    }
    
    //Annotation Select Func
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        //Ignore Selecting self
        if(view.annotation is MKUserLocation)
        {
            return;
        }
        //Allow unlimited selection of pokemon
        mapView.deselectAnnotation(view.annotation!, animated: true);
        
        //Define new region for selecting pokemon
        let selectedRegion = MKCoordinateRegionMakeWithDistance(view.annotation!.coordinate, POKEMON_CATCH_LATITUDE_SPAN, POKEMON_CATCH_LONGITUDE_SPAN);
        mapView.setRegion(selectedRegion, animated: true);
        
        //Delay to prevent zoom-out catch bug
        Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false)
        { (timer) in
            
            //Catch pokemon condition
            if let userCoordinate = self.manager.location?.coordinate
            {
                let selectedPokemon = (view.annotation as! PKMNAnnotation).pokemon;
                
                //is user annotation within pokemon catch region?
                if(MKMapRectContainsPoint(mapView.visibleMapRect, MKMapPointForCoordinate(userCoordinate)))
                {
                    //Able to catch Popup Creation
                    let alertVC = UIAlertController(title: "Throw Pokeball succeeded!", message: "You caught a \(selectedPokemon.name!). \(selectedPokemon.name!) has been added to your Pokedex!", preferredStyle: .alert);
                    
                    //Popup Action - OK
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil);
                    alertVC.addAction(okAction);
                    
                    //Popup Action - Goto Pokedex
                    let pokedexAction = UIAlertAction(title: "Pokedex", style: .default, handler: { (action) in
                        self.performSegue(withIdentifier: "pokedexSegue", sender: nil);
                    
                    });
                    alertVC.addAction(pokedexAction);
                    
                    //Show Popup
                    self.present(alertVC, animated: true, completion: nil);
                    
                    //Modify pokemon as caught and save to CoreData.
                    selectedPokemon.isCaught = true;
                    (UIApplication.shared.delegate as! AppDelegate).saveContext();
                    
                    //Remove pokemon annotation from map
                    mapView.removeAnnotation(view.annotation!);
                }
                else
                {
                    //Unable to catch Popup Creation
                    let alertVC = UIAlertController(title: "Throw Pokeball failed!", message: "You are too far away to catch the \(selectedPokemon.name!).", preferredStyle: .alert);
                    
                    //Popup Action - OK
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil);
                    alertVC.addAction(okAction);
                    
                    //Show Popup
                    self.present(alertVC, animated: true, completion: nil);
                }
            }
        }
    }
    
    
    // UI Button Funcs
    //Location Button
    @IBAction func MyLocationPressed(_ sender: Any)
    {
        if let userCoordinate = manager.location?.coordinate
        {
            let currRegion = MKCoordinateRegionMakeWithDistance(userCoordinate, LATITUDE_SPAN , LONGITUDE_SPAN);
            mapView.setRegion(currRegion, animated: true);
        }
    }
}
