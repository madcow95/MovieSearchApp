//
//  MovieSearchError.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/2.
//

import Foundation

enum MovieSearchError: Error {
    case urlError
    case apiKeyError
    
    var errMsg: String {
        switch self {
        case .urlError:
            return "URL오류가 발생 관리자에게 문의"
        case .apiKeyError:
            return "API KEY의 유효기간 만료 및 에러 발생 관리자에게 문의"
        }
    }
}
