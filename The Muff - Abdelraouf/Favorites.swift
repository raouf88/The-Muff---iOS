//
//  Favorites.swift
//  provides functions to add/remove movie to favoroite list as well as storing and restoring the list locally.
//
//  Created by Raouf on 28/01/2017.
//  Copyright © 2017 Raouf Maz. All rights reserved.
//

import Foundation

/**
 delegate for Favorites that provides callbacks when list updates
 */
protocol FavoritesDelegate : class {
    /**
     called when the favorite list is updated.
     - Parameter movies : Favorite movies list as dictionary
     */
    func favorites(didUpdate movies : [String : Movie])
}

class Favorites {
    
    // MARK: public globals
    /**current favorited movies list*/
    private(set) var movies : [String : Movie] = [:]
    /**delegate for Favorites that provides callbacks when list updates*/
    weak var delegate : FavoritesDelegate?
    
    // MARK: Initializers
    
    /**initilize the object. restore the favorite lists from local storage.*/
    init() {
        // restore the list from local storage
        restoreFavorites()
    }
    
    // MARK: Methods
    /**
     add a Movie to the favorite list, store the list then calls delgate update method after.
     - Parameter movie : movie to be added.
     */
    func addFavorite(movie:Movie){
        movies[movie.id] = movie
        storeFavorites()
        delegate?.favorites(didUpdate: movies)
        
    }
    
    /**
     remove a Movie to the favorite list, store the list then calls delgate update method after.
     - Parameter movie : movie to be removed.
     */
    func removeFavorite(movie:Movie){
        movies[movie.id] = nil
        storeFavorites()
        delegate?.favorites(didUpdate: movies)
    }
    
    /**
     - Parameter movie : movie to be checked.
     - Returns : true if the movie is favorited.
     */
    func isFavorite(movie:Movie)->Bool{
        return movies[movie.id] != nil
    }
    
    /**
     restore the current favorite list from the local storage using UserDefaults
     */
    private func restoreFavorites(){
        if let dict = UserDefaults.standard.object(forKey: "favorites") as? Data{
            if let movies = NSKeyedUnarchiver.unarchiveObject(with: dict) as? [String : Movie] {
                self.movies = movies
            }
        }
    }
    
    /**
     store the current favorite list into the local storage using UserDefaults
     */
    private func storeFavorites(){
        let defaults = UserDefaults.standard
        defaults.setValue(NSKeyedArchiver.archivedData(withRootObject: movies), forKey: "favorites")
    }
    

}
