//
//  CustomScrollView.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/2.
//

import UIKit

class CustomHorizontalScroll: UICollectionView {
    
    private let popularMovieCollectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 9
        layout.itemSize = CGSize(width: 150, height: 250)
        layout.collectionView?.backgroundColor = .white
        
        return layout
    }()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: popularMovieCollectionViewFlowLayout)
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureCollectionView()
    }
    
    func configureCollectionView() {
        self.heightAnchor.constraint(equalToConstant: 250).isActive = true
        self.isScrollEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.contentInset = .zero
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
