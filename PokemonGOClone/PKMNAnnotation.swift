//
//  PKMNAnnotation.swift
//  PokemonGOClone
//
//  Created by Steve Kerney on 1/24/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import UIKit
import MapKit

// Inherits from MKAnnotation
class PKMNAnnotation : NSObject, MKAnnotation
{
    var coordinate : CLLocationCoordinate2D;
    var pokemon : Pokemon;
    
    
    init(coordinate : CLLocationCoordinate2D, pokemon : Pokemon)
    {
        self.coordinate = coordinate;
        self.pokemon = pokemon;
    }
}
