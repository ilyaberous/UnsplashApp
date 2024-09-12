//
//  DetailViewController.swift
//  UnsplashApp
//
//  Created by Ilya on 12.09.2024.
//

import UIKit

class DetailViewController: UIViewController {
    
    let viewModel: DetailViewModel
    
    private lazy var image: UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFill
        imgV.clipsToBounds = true
        imgV.translatesAutoresizingMaskIntoConstraints = false
        return imgV
    }()
    
    private lazy var descript: UILabel = {
        let desc = UILabel()
        desc.font = .systemFont(ofSize: 30, weight: .bold)
        desc.textColor = .black
        desc.numberOfLines = 0
        desc.textAlignment = .left
        desc.translatesAutoresizingMaskIntoConstraints = false
        return desc
    }()
    
    private lazy var authorName: UILabel = {
        let name = UILabel()
        name.font = .systemFont(ofSize: 16, weight: .medium)
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    private lazy var username: UILabel = {
        let username = UILabel()
        username.font = .systemFont(ofSize: 16, weight: .medium)
        username.textColor = .systemGray
        username.translatesAutoresizingMaskIntoConstraints = false
        return username
    }()
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [authorName, username])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .equalCentering
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isHidden = true
        return indicator
    }()
    
    private lazy var errorView: ErrorView = {
        let error = ErrorView()
        error.translatesAutoresizingMaskIntoConstraints = false
        error.isHidden = true
        error.delegate = self
        return error
    }()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configure()
    }
    
    @objc private func rightButtonAction(sender: UIBarButtonItem) {
        guard let image = image.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Изображение успешно сохранено в галерею", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    private func configureNavBar() {
        let rightButtonItem = UIBarButtonItem.init(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(rightButtonAction)
        )
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    private func setupUI() {
        configureNavBar()
        view.backgroundColor = .systemBackground
        view.addSubview(image)
        view.addSubview(descript)
        view.addSubview(hStack)
        view.addSubview(loadingIndicator)
        view.addSubview(errorView)
        
        
        NSLayoutConstraint.activate([
        
            image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13),
            image.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            image.heightAnchor.constraint(equalTo: view.widthAnchor),
            
            descript.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
            descript.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descript.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            hStack.topAnchor.constraint(equalTo: descript.bottomAnchor, constant: 16),
            hStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
           // hStack.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: -16),
            
        ])
    }
    
    func configure() {
        loadingIndicator.startAnimating()
        image.loadImageFromURL(urlString: viewModel.detailImageItem.img) { [weak self] _ in
            self?.viewModel.state = .error
            print("DEBUG: toggle to error state!!!")
        }
        descript.text = viewModel.detailImageItem.description
        authorName.text = "Author: \(viewModel.detailImageItem.firstName) \(viewModel.detailImageItem.lastName)"
        username.text = "(@\(viewModel.detailImageItem.username))"
    }
}

extension DetailViewController: DetailViewModelDelegate {
    func detailViewModel(_ viewModel: DetailViewModel, wantsToUpdateStateOn state: DetailScreenState) {
        switch state {
        case .loading:
            DispatchQueue.main.async { [weak self] in
                self?.loadingIndicator.isHidden = false
                self?.errorView.isHidden = true
                self?.loadingIndicator.startAnimating()
            }
        case .ok:
            DispatchQueue.main.async { [weak self] in
                self?.loadingIndicator.stopAnimating()
                self?.loadingIndicator.isHidden = true
                self?.errorView.isHidden = true
            }
        case .error:
            DispatchQueue.main.async { [weak self] in
                self?.loadingIndicator.stopAnimating()
                self?.loadingIndicator.isHidden = true
                self?.errorView.isHidden = false
            }
        }
    }
}

extension DetailViewController: ErrorViewDelegate {
    func errorView(shouldRestartLastRequest errorView: ErrorView) {
        print("DEBUG: reload detail view")
    }
}
