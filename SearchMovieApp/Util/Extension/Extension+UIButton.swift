//
//  Extension+UIButton.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/12.
//

import UIKit

class LabelButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(
        label: String,
        buttonImage: UIImage? = UIImage(systemName: "chevron.right"),
        buttonColor: UIColor = .black
    ) {
        self.init()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.setTitle(label, for: .normal)
        self.setImage(buttonImage, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.semanticContentAttribute = .forceRightToLeft // title과 image의 위치 변경
    }
}

