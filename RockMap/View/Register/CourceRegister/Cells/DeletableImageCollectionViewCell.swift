//
//  DeletableImageCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/19.
//

import UIKit

class DeletableImageCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let deleteButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = Resources.Const.UI.View.radius
        imageView.clipsToBounds = true
        
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage.SystemImages.xmarkCircleFill, for: .normal)
        deleteButton.tintColor = .white
        imageView.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.topAnchor.constraint(equalTo: imageView.topAnchor),
            deleteButton.rightAnchor.constraint(equalTo: imageView.rightAnchor)
        ])
    }
    
    func configure(
        data: Data,
        deleteButtonTapped: @escaping () -> Void
    ) {
        imageView.image = UIImage(data: data)
        
        deleteButton.addAction(
            .init { _ in
                deleteButtonTapped()
            },
            for: .touchUpInside
        )
    }
}
