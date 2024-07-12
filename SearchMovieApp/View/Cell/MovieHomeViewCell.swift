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
//        img.backgroundColor = .lightGray
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        
        return label
    }()
    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.addArrangedSubview(posterView)
        stack.addArrangedSubview(titleLabel)
        
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        contentView.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
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
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable.removeAll()
        posterView.image = nil
    }
}
