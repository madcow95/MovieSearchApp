//
//  MovieBookmarkTableCell.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/16.
//

import UIKit
import Combine

class MovieBookmarkTableCell: UITableViewCell {
    private lazy var posterImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalToConstant: 150).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        return iv
    }()
    private let movieTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 3
        label.textAlignment = .left
        
        return label
    }()
    
    private let service = MovieSearchService()
    private var cancellable = Set<AnyCancellable>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUIComponents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUIComponents()
    }
    
    func setUIComponents() {
        [posterImage, movieTitle].forEach{ self.contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            self.posterImage.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.posterImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            self.posterImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            self.movieTitle.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.movieTitle.leadingAnchor.constraint(equalTo: self.posterImage.trailingAnchor, constant: 10),
            self.movieTitle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func configureUI(movie: MovieInfo) {
        self.movieTitle.text = movie.title
        
        do {
            try service.getPosterImage(posterURL: movie.posterPath)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] poster in
                    guard let self = self else { return }
                    self.posterImage.image = poster
                }
                .store(in: &cancellable)
        } catch {
            print("error configureUI > \(error.localizedDescription)")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable.removeAll()
//        posterView.image = nil
    }
}
