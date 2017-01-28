//
//  Search.swift
//  provides the functions to serach a movie from Omdb api.
//
//  Created by Raouf on 27/01/2017.
//  Copyright © 2017 Raouf Maz. All rights reserved.
//

import Foundation

/**
 delegate for  Search that provides callbacks about the search results
 */
protocol SearchDelegate : class {
    /**
     called when the search process fails. shows error as an alert
     - Parameter error : error msg
     */
    func search(didFail error:String)
    /**
     called when the search process suucceed.
     - Parameter movies : result as an array of movies
     - Parameter totalResults : total number of results.
     */
    func search(didSuccess movies:Array<Movie>, totalResults:Int)
}

class Search {
    
    // MARK: public globals 
    
    /**delegate to recieve the serach callbacks */
    weak var delegate : SearchDelegate?
    /**return true if there are more result can be fetched fot the last search done*/
    private(set) var canSearchMore = false
    /**true if searching is in progress*/
    private(set) var searching = false
    /**search result of movies*/
    private(set) var movies = Array<Movie>()
    
    // MARK: private globals
    private var totalResults = 0
    private var currentPage = 1
    private var textToSearch = ""
    private var task : URLSessionDataTask?
    
    // MARK: Methods
    
    /**cancels and pending process and clears the results*/
    func clear(){
        task?.cancel()
        self.movies.removeAll()
        self.delegate?.search(didSuccess: self.movies, totalResults: 0 )
    }
    
    /**
     start search process using the passed tect
     - Parameter textToSearch : text to be searched
     */
    func search(textToSearch:String){
        // trim the extra white spaces , add + intead of spaces and url encode the passed text
        self.textToSearch = textToSearch.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "+").addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        // reset
        self.totalResults = 0
        self.currentPage = 1
        self.movies.removeAll()
        task?.cancel()
        // start search
        search()
    }
    
    /**if there is more results can be shown fetch them*/
    func searchMore(){
        if canSearchMore {
            currentPage += 1
            search()
        }
    }
    
    /**
     do the search by calling omdb api pasing the text to search along with the page number if neeeded.
     if sucess call delegate success method pasing the results, else call delgate failed method passing the error messege.
     */
    private func search(){
        // set search state true
        searching = true
        // create URLRequest for omdb api
        let request = URLRequest(url: URL(string: "http://www.omdbapi.com/?type=movie&y=true&page=\(currentPage)&s=\(textToSearch)")!)
        // setup URLSessionDataTask to handle the results from URLRequest operation
        task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            // if failed due to connection problem
            if error != nil {
                DispatchQueue.main.async{
                    // fail callback
                    self.delegate?.search(didFail: "Error communicating with the server. Please make sure you have internet access.")
                }
                
            } else {
                // parse the json replied from api
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data!, options: [])
                    let jsonDictionary = jsonObject as! [String: Any]
                    let response = jsonDictionary["Response"] as! String
                    if response == "True" {
                        // parse the search jason array to create array of movies resuelt
                        let jsonArrayDictionary =  jsonDictionary["Search"] as! [Any]
                        for object in jsonArrayDictionary{
                            self.movies.append(Movie(jsonObject: object ))
                        }
                        // parse the total results
                        self.totalResults = Int(jsonDictionary["totalResults"] as! String)!
                        // update the state of Bool if we can search more or not
                        self.canSearchMore = self.movies.count<self.totalResults
                        DispatchQueue.main.async{
                            // success callback
                            self.delegate?.search(didSuccess: self.movies, totalResults: self.totalResults )
                        }
                        
                    } else {
                        // failed reply from the server
                        let errorMsg = jsonDictionary["Error"] as! String
                        DispatchQueue.main.async{
                            // fail callback
                            self.delegate?.search(didFail: errorMsg)
                        }
                    }
                    
                } catch let error {
                    // failed to parse json
                    print(error)
                    DispatchQueue.main.async{
                        // fail callback
                        self.delegate?.search(didFail: String(describing: error))
                    }
                }
            }
            self.searching = false
        })
        // start the URLSessionDataTask
        task?.resume()
    }
}
