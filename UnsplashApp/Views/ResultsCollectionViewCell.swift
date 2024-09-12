//
//  ResultsCollectionViewCell.swift
//  UnsplashApp
//
//  Created by Ilya on 11.09.2024.
//

import UIKit

final class ResultsCollectionViewCell: UICollectionViewCell {
    static let identifier = "results_cell"
    
    private let gradientLayer = CAGradientLayer()
    
    private var image: UIImageView = {
        let imageV = UIImageView()
        imageV.clipsToBounds = true
        imageV.contentMode = .scaleAspectFill
        imageV.translatesAutoresizingMaskIntoConstraints = false
        return imageV
    }()
    
    private var descript: UILabel = {
       let desc = UILabel()
        desc.numberOfLines = 2
        desc.textColor = .white
        desc.font = .systemFont(ofSize: 14, weight: .medium)
        desc.translatesAutoresizingMaskIntoConstraints = false
        return desc
    }()
    
    private var username: UILabel = {
       let username = UILabel()
        username.textColor = .lightText
        username.font = .systemFont(ofSize: 10, weight: .semibold)
        username.translatesAutoresizingMaskIntoConstraints = false
        return username
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .systemGroupedBackground
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = bounds
        clipsToBounds = true
        layer.cornerRadius = 8
    }
    
    private func setupUI() {
        addSubview(image)
        configureGradientLayer()
        addSubview(descript)
        addSubview(username)
        
        NSLayoutConstraint.activate([
        
            image.leadingAnchor.constraint(equalTo: leadingAnchor),
            image.topAnchor.constraint(equalTo: topAnchor),
            image.trailingAnchor.constraint(equalTo: trailingAnchor),
            image.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            descript.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descript.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descript.bottomAnchor.constraint(equalTo: username.topAnchor, constant: -8),
            
            username.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            username.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
    
    private func configureGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        layer.addSublayer(gradientLayer)
    }
    
    func configure(resultItem: ResultsCollectionItem) {
        descript.text = resultItem.description
        username.text = "@" + resultItem.username
        image.loadImageFromURL(urlString: resultItem.img) { error in
            print("DEBUG: loadImage error")
        }
        //to do image!
    }
}
