//
//  MovieSearchListCell.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/11.
//

import UIKit
import Combine

class MovieSearchListCell: UITableViewCell {
    
    private let viewModel = MovieHomeViewModel()
    private var cancellable = Set<AnyCancellable>()
    private lazy var posterImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.widthAnchor.constraint(equalToConstant: self.contentView.frame.width / 3).isActive = true
        
        return image
    }()
    private lazy var movieTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .white
        
        return label
    }()
    private lazy var rateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        
        return label
    }()
    private lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 4
        
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(movie: MovieInfo) {
        do {
            try viewModel.service.getPosterImage(posterURL: movie.posterPath)
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self.posterImage)
                .store(in: &cancellable)
        } catch {
            print("error in MovieSearchListCell - configureUI() > \(error.localizedDescription)")
        }
        self.movieTitle.text = "\(movie.title) (\(movie.releaseDate.components(separatedBy: "-")[0]))"
        self.rateLabel.text = "\(String(format: "%.2f", movie.voteAverage)) (\(movie.voteCount))"
        self.tagLabel.text = movie.overview
        
        [posterImage, movieTitle, rateLabel, tagLabel].forEach{ self.contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            self.posterImage.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.posterImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            self.posterImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            self.movieTitle.topAnchor.constraint(equalTo: self.posterImage.topAnchor),
            self.movieTitle.leadingAnchor.constraint(equalTo: self.posterImage.trailingAnchor, constant: 15),
            self.movieTitle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            self.rateLabel.topAnchor.constraint(equalTo: self.movieTitle.bottomAnchor, constant: 8),
            self.rateLabel.leadingAnchor.constraint(equalTo: self.movieTitle.leadingAnchor),
            
            self.tagLabel.topAnchor.constraint(equalTo: self.rateLabel.bottomAnchor, constant: 8),
            self.tagLabel.leadingAnchor.constraint(equalTo: self.movieTitle.leadingAnchor),
            self.tagLabel.trailingAnchor.constraint(equalTo: self.movieTitle.trailingAnchor),
            self.tagLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable.removeAll()
        posterImage.image = nil
    }
}
