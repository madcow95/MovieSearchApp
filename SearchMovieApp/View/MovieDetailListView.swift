//
//  MovieDetailListViewController.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/5.
//

import UIKit

class MovieDetailListView: UIViewController {
    
    var loadedMovies: [MovieInfo] = []
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 150, height: 250)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.register(MovieDetailListViewCell.self, forCellWithReuseIdentifier: "MovieDetailListViewCell")
        
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        setCollectionView()
    }
    
    func setCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { [weak self] collection in
            guard let self = self else { return }
            collection.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            collection.left.equalTo(self.view.snp.left)
            collection.right.equalTo(self.view.snp.right)
            collection.bottom.equalTo(self.view.snp.bottom)
        }
    }
}

extension MovieDetailListView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieDetailListViewCell", for: indexPath) as? MovieDetailListViewCell else {
            return UICollectionViewCell()
        }
        
        if self.loadedMovies.count > 0 {
            let movie = self.loadedMovies[indexPath.row]
            cell.configureCell(movie: movie)
        }
        
        return cell
    }
}
