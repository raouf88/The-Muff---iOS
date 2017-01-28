//
//  MovieHelper.swift
//  privides functins for a move to fetch poster , rating and release. add/remove favorite. share to social media
//
//  Created by Raouf on 27/01/2017.
//  Copyright © 2017 Raouf Maz. All rights reserved.
//

import Foundation
import UIKit

class MovieHelper {
    
    // MARK: private globals
    unowned let movie:Movie
    private let posterDocumentPath:String
    private unowned let imagesCache = (UIApplication.shared.delegate as! AppDelegate).imagesCache
    private unowned let favorites = (UIApplication.shared.delegate as! AppDelegate).favorites
    
    // MARK: Initializers
    /**
     initilize using Movie.
     - Parameter movie : movie object.
     */
    init(movie:Movie) {
        self.movie = movie
        // set the file path for the poster
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        posterDocumentPath = documentPath.appending("/"+movie.id)
    }
    
    // MARK: Methods
    /**
     fetch the movie poster image from cache if any or file storage if any or movie poster link.
     - Parameter completion : call back when process is completed.
     */
    func fetchPoster(completion: @escaping (UIImage)->Void){
        if let cachedImage = imagesCache.object(forKey: movie.id as AnyObject){
            completion(cachedImage)
        } else {
            if(FileManager.default.fileExists(atPath: posterDocumentPath)){
                let image = UIImage(contentsOfFile: posterDocumentPath)!
                imagesCache.setObject(image, forKey: movie.id as AnyObject)
                completion(image)
            } else {
                // fetch image online
                let downloader = URLSession.shared.dataTask(with: movie.poster, completionHandler: {
                    (data, _, error) -> Void in
                    guard let data = data , error == nil, let image = UIImage(data: data) else {
                        print(error as Any)
                        let noPosterImage = UIImage(named: "image_noposter")!
                        self.imagesCache.setObject(noPosterImage, forKey: self.movie.id as AnyObject)
                        DispatchQueue.main.async{
                            completion(noPosterImage)
                        }
                        
                        return
                    }
                    self.imagesCache.setObject(image, forKey: self.movie.id as AnyObject)
                    try? UIImagePNGRepresentation(image)!.write(to: URL(fileURLWithPath: self.posterDocumentPath), options: [])
                    DispatchQueue.main.async{
                        completion(image)
                    }
                })
                downloader.resume()
            }
        }
    }
    
    /**
     fetch the movie rating and release from omdp api.
     - Parameter completion : call back when process is completed.
     */
    func fetchRatingAndRelease(completion: @escaping (Float?, String?)->Void){
        let request = URLRequest(url: URL(string: "http://www.omdbapi.com/?i=\(movie.id)")!)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if error != nil {
                DispatchQueue.main.async{
                    completion(nil,nil)
                }
                
            } else {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data!, options: [])
                    let jsonDictionary = jsonObject as! [String: Any]
                    let response = jsonDictionary["Response"] as! String
                    if response == "True" {
                        self.movie.released = jsonDictionary["Released"] as? String
                        self.movie.rating = Float(jsonDictionary["imdbRating"] as! String)
                        DispatchQueue.main.async{
                            completion(self.movie.rating,self.movie.released)
                        }
                        
                    } else {
                        DispatchQueue.main.async{
                             completion(nil,nil)
                        }
                    }
                    
                } catch let error {
                    print(error)
                    DispatchQueue.main.async{
                         completion(nil,nil)
                    }
                }
            }
        })
        task.resume()
    }
    
    /**
     do favorite click/ it will add the movie to favorite if not added before, else removes it.
     - Parameter completion : call back when process is completed.
     */
    func favoritesClick() {
        if favorites.isFavorite(movie: movie){
            favorites.removeFavorite(movie: movie)
        } else {
            favorites.addFavorite(movie: movie)
        }
    }
    
    /**
     - Returns : true if the movie is favorited.
     */
    func isFavorite()->Bool{
        return favorites.isFavorite(movie: movie)
    }
    
    /**
     Shares the movie to social media using UIActivityViewController 
     - Parameter viewController : UIViewController needed to present UIActivityViewController.
     - Parameter viewController : sender UIView needed to present UIActivityViewController for ipads.
     */
    func shareClick(viewController : UIViewController? , sender : UIView?){
        if let cachedImage = imagesCache.object(forKey: movie.id as AnyObject){
            let text = "\(movie.title) (\(movie.year))"
            let sharingItems : [Any] = [text,cachedImage]
            let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [ .airDrop,  .copyToPasteboard, .addToReadingList, .assignToContact, .print ]
            activityViewController.popoverPresentationController?.sourceView = sender
            viewController?.present(activityViewController, animated: true, completion: nil)
        }
    }

}
