//
//  CoreDataHelper.swift
//  PokemonGOClone
//
//  Created by Steve Kerney on 1/24/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import UIKit
import CoreData

func spawnAllPokemon()
{
    //Add PKMN
    createPokemon(name: "Pikachu", imgName: "pikachu-2");
    createPokemon(name: "Charmander", imgName: "charmander");
    createPokemon(name: "Bulbasaur", imgName: "bullbasaur");
    createPokemon(name: "Squirtle", imgName: "squirtle");
    
    //Save PKMN
    (UIApplication.shared.delegate as! AppDelegate).saveContext();
    
}

func createPokemon(name : String, imgName : String)
{
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;

    //Create a pokemon
    let pokemon = Pokemon(context: context);
    pokemon.name = name;
    pokemon.imageName = imgName;
}

func getAllPokemon() -> [Pokemon]
{
    //Fetch request
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;

    do
    {
        let pokemonArr = try context.fetch(Pokemon.fetchRequest()) as! [Pokemon];
        
        if(pokemonArr.count == 0)
        {
            spawnAllPokemon();
            return getAllPokemon();
        }
        
        return pokemonArr;

    } catch{ };

    return [];
}

func getAllUncaughtPokemon() -> [Pokemon]
{
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    
    //Custom Fetch request
    let uncaughtFetchRequest : NSFetchRequest<Pokemon> = Pokemon.fetchRequest();
    uncaughtFetchRequest.predicate = NSPredicate(format: "isCaught == %@", false as CVarArg);
    
    do
    {
        let unCaughtPokemonArr = try context.fetch(uncaughtFetchRequest) as [Pokemon];
        return unCaughtPokemonArr;
    } catch { }
    
    return [];
}

func getAllCaughtPokemon() -> [Pokemon]
{
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;

    //Custom Fetch request
    let caughtFetchRequest : NSFetchRequest<Pokemon> = Pokemon.fetchRequest();
    caughtFetchRequest.predicate = NSPredicate(format: "isCaught == %@", true as CVarArg);
    
    do
    {
        let caughtPokemonArr = try context.fetch(caughtFetchRequest) as [Pokemon];
        return caughtPokemonArr;
    } catch { }
    
    return [];
}
