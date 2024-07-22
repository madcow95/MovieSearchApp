//
//  MovieHomeViewCell.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/8.
//

import UIKit
import Combine

class MovieHomeViewCell: UICollectionViewCell {
    
    var viewModel: MovieHomeViewModel?
    private var cancellable = Set<AnyCancellable>()
    
    private let progressIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        indicator.isHidden = false
        
        return indicator
    }()
    private var posterView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 150).isActive = true
        img.heightAnchor.constraint(equalToConstant: 200).isActive = true
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
        contentView.addSubview(progressIndicator)
        NSLayoutConstraint.activate([
            progressIndicator.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            progressIndicator.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            progressIndicator.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            progressIndicator.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 10)
        ])
    }
    
    func configureCell(movie: MovieInfo) {
        guard let viewModel = self.viewModel else { return }
        self.titleLabel.text = movie.title
        do {
            try viewModel.service.getPosterImage(posterURL: movie.posterPath)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] poster in
                    guard let self = self else { return }
                    self.progressIndicator.stopAnimating()
                    self.progressIndicator.isHidden = true
                    self.posterView.image = poster
                    contentView.addSubview(vStack)
            
                    NSLayoutConstraint.activate([
                        vStack.topAnchor.constraint(equalTo: contentView.topAnchor),
                        vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                        vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                        vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                    ])
                })
                .store(in: &cancellable)
        } catch {
            print(error)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable.removeAll()
//        posterView.image = nil
    }
}
