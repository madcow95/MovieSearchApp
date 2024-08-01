//
//  MovieDetailListViewCell.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/13.
//

import UIKit
import Combine

class MovieDetailListViewCell: UICollectionViewCell {
    private let tempViewModel = MovieDetailViewModel()
    private var cancellable = Set<AnyCancellable>()
    private lazy var posterView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        imgView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imgView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUIComponents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUIComponents()
    }
    
    func setUIComponents() {
        self.contentView.addSubview(posterView)
        
        posterView.snp.makeConstraints { [weak self] poster in
            guard let self = self else { return }
            poster.centerX.equalTo(self.contentView.snp.centerX)
            poster.centerY.equalTo(self.contentView.snp.centerY)
        }
    }
    
    func configureCell(movie: MovieInfo) {
        do {
            try tempViewModel.service.getPosterImage(posterURL: movie.posterPath)
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self.posterView)
                .store(in: &cancellable)
        } catch {
            print("error in \(#function) \(#line)")
        }
    }
}
