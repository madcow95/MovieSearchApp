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
    private lazy var rateStar: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "star.fill")
        iv.tintColor = .systemYellow
        iv.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        return iv
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
        self.rateLabel.text = "\((movie.voteAverage / 2).getTwoDecimal) (\(movie.voteCount.numberWithComma))"
        self.tagLabel.text = movie.overview
        
        [posterImage, movieTitle, rateStar, rateLabel, tagLabel].forEach{ self.contentView.addSubview($0) }
        
        posterImage.snp.makeConstraints { [weak self] img in
            guard let self = self else { return }
            img.top.equalTo(self.contentView.snp.top).offset(5)
            img.left.equalTo(self.contentView.snp.left).offset(8)
            img.bottom.equalTo(self.contentView.snp.bottom).offset(-5)
        }
        
        movieTitle.snp.makeConstraints { [weak self] title in
            guard let self = self else { return }
            title.top.equalTo(self.posterImage.snp.top)
            title.left.equalTo(self.posterImage.snp.right).offset(15)
            title.right.equalTo(self.contentView.snp.right)
        }
        
        rateStar.snp.makeConstraints { [weak self] star in
            guard let self = self else { return }
            star.top.equalTo(self.movieTitle.snp.bottom).offset(8)
            star.left.equalTo(self.movieTitle.snp.left)
        }
        
        rateLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.movieTitle.snp.bottom).offset(8)
            label.left.equalTo(self.rateStar.snp.right).offset(8)
        }
        
        tagLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.rateLabel.snp.bottom).offset(8)
            label.left.equalTo(self.movieTitle.snp.left)
            label.right.equalTo(self.movieTitle.snp.right)
            label.bottom.equalTo(self.contentView.snp.bottom)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable.removeAll()
//        posterImage.image = nil
    }
}
