//
//  ErrorView.swift
//  UnsplashApp
//
//  Created by Ilya on 12.09.2024.
//

import UIKit

protocol ErrorViewDelegate: AnyObject {
    func errorView(shouldRestartLastRequest errorView: ErrorView)
}

class ErrorView: UIView {

    weak var delegate: ErrorViewDelegate?
    
    lazy var smthWentWrong: UILabel = {
       let label = UILabel()
        label.text = "Ой, что-то пошло не так"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var errorIcon: UIImageView = {
       let icon = UIImageView()
        icon.image = UIImage(systemName: "nosign")?.withRenderingMode(.alwaysTemplate)
        icon.tintColor = .red
        icon.contentMode = .scaleAspectFill
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    lazy var btt: UIButton = {
       let btt = UIButton()
        btt.backgroundColor = .black
        btt.setTitle("Перезагрузить", for: .normal)
        btt.titleLabel?.font =  .systemFont(ofSize: 16, weight: .bold)
        btt.setTitleColor(.white, for: .normal)
        btt.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        btt.translatesAutoresizingMaskIntoConstraints = false
        return btt
    }()
    
    lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 34
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        vStack.addArrangedSubview(smthWentWrong)
        vStack.addArrangedSubview(errorIcon)
        addSubview(btt)
        
        addSubview(vStack)
        
        NSLayoutConstraint.activate([
            
            errorIcon.heightAnchor.constraint(equalToConstant: 90),
            errorIcon.widthAnchor.constraint(equalToConstant: 90),
            
            btt.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            btt.heightAnchor.constraint(equalToConstant: 59),
            btt.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            btt.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            vStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            vStack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            
        ])
    }
    
    @objc private func buttonTapped() {
        delegate?.errorView(shouldRestartLastRequest: self)
    }
    
}
