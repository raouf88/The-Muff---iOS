//
//  FirstViewController.swift
//  lists the favorite movies.
//
//  Created by Raouf on 27/01/2017.
//  Copyright © 2017 Raouf Maz. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, FavoritesDelegate {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: private globals
    private unowned let favorites = (UIApplication.shared.delegate as! AppDelegate).favorites
    private var movies = Array<Movie>()
    
    // MARK: UIViewController
    /**
     called when view is loaded. setup the tableview and favorites
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup table view
        tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil) , forCellReuseIdentifier: "MovieTableViewCell")
        tableView.contentInset.top = 64
        tableView.contentInset.bottom = 44
        tableView.tableFooterView = UIView()
        // setup favorites
        favorites.delegate = self
        movies = Array(favorites.movies.values)
    }


    // MARK: UITableViewDataSource , UITableViewDelegate
    
    /**called to get the number of sections in table. return 1 section*/
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /**called to get the number of rows in table. return the current favorite list items number*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    /**called to set the cells for the table. set MovieTableViewCell as cell and set the movie from the row number*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchCell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
        searchCell.setMovie(viewController: self, movie: movies[indexPath.row])
        return searchCell
    }
    
    // MARK: FavoritesDelegate 
    
    /**called when favorite list updates. updates the table with updated list*/
    func favorites(didUpdate movies: [String : Movie]) {
        self.movies = Array(favorites.movies.values)
        tableView.reloadData()
    }
    
}

