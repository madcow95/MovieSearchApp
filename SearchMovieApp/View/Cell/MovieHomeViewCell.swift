//
//  MovieHomeViewCell.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/8.
//

import UIKit
import Combine
import SnapKit

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
        progressIndicator.snp.makeConstraints { [weak self] indicator in
            guard let self = self else { return }
            indicator.top.equalTo(self.contentView.snp.top).offset(10)
            indicator.left.equalTo(self.contentView.snp.left).offset(10)
            indicator.right.equalTo(self.contentView.snp.right).offset(-10)
            indicator.bottom.equalTo(self.contentView.snp.bottom).offset(-10)
        }
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
            
                    vStack.snp.makeConstraints { [weak self] stack in
                        guard let self = self else { return }
                        stack.top.equalTo(self.contentView.snp.top)
                        stack.left.equalTo(self.contentView.snp.left)
                        stack.right.equalTo(self.contentView.snp.right)
                        stack.bottom.equalTo(self.contentView.snp.bottom)
                    }
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
