//
//  MovieBookMarkViewController.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/13.
//

import UIKit
import Combine

class MovieBookMarkView: UIViewController {
    
    private lazy var bookmarkList: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(MovieBookmarkTableCell.self, forCellReuseIdentifier: "MovieBookmarkTableCell")
        
        return table
    }()
    
    private let bookmarkViewModel = MovieBookMarkViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setSubscriber()
        setConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bookmarkViewModel.loadAllBookmarkMovies()
    }
    
    func setSubscriber() {
        bookmarkViewModel.$bookmarkMovies
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] movies in
                guard let self = self else { return }
                self.bookmarkList.reloadData()
            })
            .store(in: &cancellable)
    }
    
    func setConstraint() {
        self.view.addSubview(bookmarkList)
        
        bookmarkList.snp.makeConstraints { [weak self] list in
            guard let self = self else { return }
            list.top.equalTo(self.view.snp.top)
            list.left.equalTo(self.view.snp.left)
            list.right.equalTo(self.view.snp.right)
            list.bottom.equalTo(self.view.snp.bottom)
        }
    }
}

extension MovieBookMarkView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkViewModel.bookmarkMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieBookmarkTableCell", for: indexPath) as? MovieBookmarkTableCell else {
            return UITableViewCell()
        }
        
        if bookmarkViewModel.bookmarkMovies.count > 0 {
            let movie = bookmarkViewModel.bookmarkMovies[indexPath.row]
            cell.configureUI(movie: movie)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = self.bookmarkViewModel.bookmarkMovies[indexPath.row]
        let detailView = MovieDetailView()
        detailView.movieInfo = selectedMovie
        navigationController?.pushViewController(detailView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            bookmarkViewModel.deleteBookmark(movie: bookmarkViewModel.bookmarkMovies[indexPath.row])
        }
    }
}
