//
//  MovieBookmarkTableCell.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/16.
//

import UIKit

class MovieBookmarkTableCell: UITableViewCell {
    private let movieTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUIComponents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUIComponents()
    }
    
    func setUIComponents() {
        self.contentView.addSubview(movieTitle)
        
        NSLayoutConstraint.activate([
            self.movieTitle.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.movieTitle.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
    
    func configureUI(movie: MovieInfo) {
        self.movieTitle.text = movie.title
    }
}
