//
//  SecondViewController.swift
//  offers the capabiltiy to search the omdb api for a movie the list the results.
//
//  Created by Raouf on 27/01/2017.
//  Copyright © 2017 Raouf Maz. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController , UISearchBarDelegate , UITableViewDelegate, UITableViewDataSource , SearchDelegate {

    // MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: private globals
    private let search = Search()
    
    // MARK: UIViewController
    
    /**
     called when view is loaded. setup the tableview and search
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup the tableview
        tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil) , forCellReuseIdentifier: "MovieTableViewCell")
        tableView.contentInset.top = 64
        tableView.contentInset.bottom = 44
        tableView.tableFooterView = UIView()
        // setup search
        search.delegate = self
    }


    // MARK: UISearchBarDelegate
    
    /**
     called when search button is clicked from keyboard. initiate search process
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // hide keyboard
        searchBar.resignFirstResponder()
        // clear the old search resulats if any
        search.clear()
        // show indicator at status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // start the search
        search.search(textToSearch: searchBar.text!)
    }
    
    
    // MARK: UITableViewDataSource , UITableViewDelegate
    
    /**called to get the number of sections in table. return 1 section*/
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /**called to get the number of rows in table. return the current search list items number*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return search.movies.count
    }
    
    /**called to set the cells for the table. set MovieTableViewCell as cell and set the movie from the row number*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchCell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
        searchCell.setMovie(viewController: self, movie: search.movies[indexPath.row])
        return searchCell
    }
    
    /**called when the table scrolls. if scrolls end of the list try to fetch more search results*/
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // if reached end of the list
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            // if there is no current searching proces and there are more results can be show, ask to fetch more results
            if !search.searching && search.canSearchMore {
                // show indicator at status bar
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                //fetch more results
                search.searchMore()
            }
        }
    }
    
    // MARK: SearchDelegate
    
    /**
     called when the search process fails. shows error as an alert
     - Parameter error : error msg
     */
    func search(didFail error: String) {
        // hide indicator at status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // show the error msg in an alert.
        let alert = UIAlertController(title: "Unsuccessful", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     called when the search process suucceed. refresh table.
     - Parameter movies : result as an array of movies
     - Parameter totalResults : total number of results.
     */
    func search(didSuccess movies: Array<Movie>, totalResults:Int) {
        // hide indicator at status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // refresh table
        tableView.reloadData()
    }

    // MARK: Actions
    /**
     called when the table view is tapped. hides keyboard if shown.
     - Parameter sender : view tapped.
     */
    @IBAction func tap(_ sender: Any) {
        // hide keyboard
        searchBar.resignFirstResponder()
    }
}

