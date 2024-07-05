//
//  CustomDivider.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/3.
//

import UIKit

class CustomDivider: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setDivider()
    }
    
    required init?(coder: NSCoder) {
        self.init()
        setDivider()
    }
    
    func setDivider() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}
