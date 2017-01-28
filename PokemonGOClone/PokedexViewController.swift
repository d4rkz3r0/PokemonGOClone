//
//  PokedexViewController.swift
//  PokemonGOClone
//
//  Created by Steve Kerney on 1/23/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import UIKit

class PokedexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var pokedexTableView: UITableView!

    // Pokedex Vars
    var caughtPokemon : [Pokemon] = [];
    var unCaughtPokemon : [Pokemon] = [];
    
    // Init
    override func viewDidLoad()
    {
        super.viewDidLoad()
        pokedexTableView.delegate = self;
        pokedexTableView.dataSource = self;

        //Grab Pokemon
        caughtPokemon = getAllCaughtPokemon();
        unCaughtPokemon = getAllUncaughtPokemon();
    }
    
    // UI Button Funcs
    //Back to map.
    @IBAction func MapButtonPressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil);
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let tempPokemon : Pokemon;
        
        
        if(indexPath.section == 0)
        {
            tempPokemon = caughtPokemon[indexPath.row];
        }
        else
        {
            tempPokemon = unCaughtPokemon[indexPath.row];
        }
        
        let newCell = UITableViewCell();
        newCell.textLabel?.text = tempPokemon.name;
        newCell.imageView?.image = UIImage(named: tempPokemon.imageName!);
        
        return newCell;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(section == 0)
        {
            return getAllCaughtPokemon().count;
        }
        else
        {
            return getAllUncaughtPokemon().count;
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if(section == 0)
        {
            return "CAUGHT POKEMON";
        }
        else
        {
            return "UNCAUGHT POKEMON";
        }
    }
}
