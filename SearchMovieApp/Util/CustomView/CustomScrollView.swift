//
//  CustomScrollView.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/2.
//

import UIKit

class HorizontalScrollView: UIScrollView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setContentView()
    }
    
    required init?(coder: NSCoder) {
        self.init()
        setContentView()
    }
    
    convenience init(
        width: CGFloat,
        height: CGFloat
    ) {
        self.init()
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(content)
        
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: self.topAnchor),
            content.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            content.heightAnchor.constraint(equalToConstant: height),
//            content.widthAnchor.constraint(equalToConstant: width),
        ])
    }
    
    func setContentView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.showsHorizontalScrollIndicator = true
    }
}
