//
//  TrailerModel.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/8/6.
//

import Foundation

class TrailerModel: Decodable {
    let id: Int
    let results: [Trailers]
}

class Trailers: Decodable {
    let key, site, type: String
    let official: Bool
}
