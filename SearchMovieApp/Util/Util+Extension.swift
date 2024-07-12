//
//  Util.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/5.
//

import UIKit

extension UIViewController {
    func showAlert(msg: String) {
        let alertController = UIAlertController(title: "오류!", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension Int {
    var minuteToHour: String {
        get {
            let hours = self / 60
            let minutes = self % 60
            return "\(hours)h \(minutes)m"
        }
    }
}
