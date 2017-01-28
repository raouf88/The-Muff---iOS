//
//  MovieTableViewCell.swift
//  holds movie details and offer the capability to share or favorite the movie
//
//  Created by Raouf on 27/01/2017.
//  Copyright © 2017 Raouf Maz. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    // MARK: private globals
    private weak var viewController : UIViewController?
    private weak var movie : Movie?
    private var movieHelper : MovieHelper?
    
    // MARK: Helpers
    
    /**
     set the movie details into the cell. sets title ,year , poster, rating and released date.
     - Parameter viewController : ViewController that is the parent of this cell. needed for sharing feature.
     - Parameter movie : Moview to fill into the cell.
     */
    func setMovie(viewController : UIViewController,  movie : Movie){
        self.viewController = viewController
        self.movie = movie
        self.movieHelper = MovieHelper(movie:movie)
        // set title
        titleLabel.text = "\(movie.title) (\(movie.year))"
        // set favorite staus
        if movieHelper!.isFavorite(){
            favoriteButton.setImage(UIImage(named: "ic_star"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(named: "ic_star_border"), for: .normal)
        }
        // set rating and release date
        // note* : rating and released date are not found in the list from search api by default, so we need to fetch them from another api .
        if let rating = movie.rating{
            releaseLabel.text = movie.released
            ratingView.rating = rating
            ratingView.alpha = 1
        } else {
            releaseLabel.text = " "
            ratingView.rating = 0
            ratingView.alpha = 0
            movieHelper?.fetchRatingAndRelease(completion: { (rating, released) in
                if self.movie!.id == movie.id {
                    self.releaseLabel.text = released
                    if let r = rating{
                        self.ratingView.rating = r
                        self.ratingView.alpha = 1
                    }
                    
                }
            })
        }

        // set cover image
        coverImageView.image = nil
        movieHelper?.fetchPoster { (image) in
            if self.movie!.id == movie.id {
                self.coverImageView.image = image
            }
        }
        
    }
    
    
    // MARK: Actions
    
    /**
     called when favorite button is tapped. add/remove the movie from favories
     - Parameter sender : view tapped.
     */
    @IBAction func favoriteButtonAction(_ sender: Any) {
        // change the favorite image based on the favorite state
        if movieHelper!.isFavorite(){
            favoriteButton.setImage(UIImage(named: "ic_star_border"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(named: "ic_star"), for: .normal)
        }
        // do a favorite click
        movieHelper?.favoritesClick()
    }

    /**
     called when share button is tapped. share the movie in socila media.
     - Parameter sender : view tapped.
     */
    @IBAction func shareButtonAction(_ sender: Any) {
        movieHelper?.shareClick(viewController: self.viewController, sender: sender as? UIView)
    }
}
