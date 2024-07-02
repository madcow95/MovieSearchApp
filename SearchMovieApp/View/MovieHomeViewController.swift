//
//  MovieHomeViewController.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/2.
//

import UIKit

class MovieHomeViewController: UIViewController {
    
    private let popularMovieButton = LabelButton(label: "인기 영화")
    private let horizontalScrollView = HorizontalScrollView(width: 1000, height: 200)
    
    private let viewModel = MovieHomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        fetchMovieDatas()
        configureUI()
    }
    
    func fetchMovieDatas() {
        Task {
            await viewModel.fetchPopularMovie()
        }
    }
    
    func configureUI() {
        setPopularMovie()
    }
    
    func setPopularMovie() {
        [popularMovieButton, horizontalScrollView].forEach{ view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            popularMovieButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            popularMovieButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            horizontalScrollView.topAnchor.constraint(equalTo: popularMovieButton.bottomAnchor, constant: 15),
            horizontalScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            horizontalScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            horizontalScrollView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        for i in 0..<10 {
            let contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = i % 2 == 0 ? .red : .blue
            contentView.frame = CGRect(x: CGFloat(i) * 100, y: 0, width: 100, height: 200)
            horizontalScrollView.subviews.first!.addSubview(contentView)
        }
        
        horizontalScrollView.contentSize = CGSize(width: 1000, height: 200)
    }
}
