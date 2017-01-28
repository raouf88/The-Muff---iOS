//
//  Movie.swift
//  holds a movie details.
//
//  Created by Raouf on 27/01/2017.
//  Copyright © 2017 Raouf Maz. All rights reserved.
//

import Foundation

class Movie: NSObject, NSCoding {
    
    // MARK: public globals
    /**imdbId*/
    let id:String
    /**title of the movie*/
    let title:String
    /**year of the movie*/
    let year:String
    /**poster link of the movie*/
    let poster:URL
    /**released date of the movie*/
    var released:String?
    /**imdb rating of the movie*/
    var rating:Float?
    
    // MARK: NSObject
    /**
     Initilize from a json object
     - Parameter jsonObject : a movie json object
     */
    init(jsonObject : Any) {
        let object = jsonObject as! [String : Any]
        self.id = object["imdbID"] as! String
        self.title = object["Title"] as! String
        self.year = object["Year"] as! String
        self.poster = URL(string:object["Poster"] as! String)!
    }
    
    // MARK : NSCoding
    
    /**
     Initilize from a decoder object. needed to be able to restore object from storage
     - Parameter decoder : NSCoder
     */
    required init(coder decoder: NSCoder) {
        id = decoder.decodeObject(forKey: "id") as! String
        title = decoder.decodeObject(forKey: "title") as! String
        year = decoder.decodeObject(forKey: "year") as! String
        poster = decoder.decodeObject(forKey: "poster") as! URL
        released = decoder.decodeObject(forKey: "released") as? String
        rating = decoder.decodeObject(forKey: "rating") as? Float
    }
    
    /**
     Encode object into encoder. needed to be able to store object into storage
     - Parameter decoder : NSCoder
     */
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(title, forKey: "title")
        coder.encode(year, forKey: "year")
        coder.encode(poster, forKey: "poster")
        coder.encode(released, forKey: "released")
        coder.encode(rating, forKey: "rating")
    }
}
