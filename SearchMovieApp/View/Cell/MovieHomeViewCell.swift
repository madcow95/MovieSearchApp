//
//  MovieHomeViewCell.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/8.
//

import UIKit
import Combine

class MovieHomeViewCell: UICollectionViewCell {
    
    let viewModel = MovieHomeViewModel()
    private var cancellable = Set<AnyCancellable>()
    private var posterView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 150).isActive = true
        img.heightAnchor.constraint(equalToConstant: 200).isActive = true
        img.backgroundColor = .lightGray
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureCell(movie: MovieInfo) {
        self.titleLabel.text = movie.title
        do {
            try viewModel.service.getPosterImage(posterURL: movie.posterPath)
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self.posterView)
                .store(in: &cancellable)
        } catch {
            print(error)
        }
        
        [self.posterView, self.titleLabel].forEach{ self.addSubview($0) }
        
        NSLayoutConstraint.activate([
            self.posterView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.posterView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.posterView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.posterView.bottomAnchor, constant: 10),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable.removeAll()
        posterView.image = nil
    }
}
