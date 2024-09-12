//
//  MainViewController.swift
//  UnsplashApp
//
//  Created by Ilya on 09.09.2024.
//

import UIKit

final class MainViewController: UIViewController {
    
    enum Section {
        case first
    }
    
    // MARK: - Properties
    
    let viewModel: MainViewModel
    
    private lazy var searchBar: UISearchController = {
        let search = UISearchController()
        search.searchBar.searchBarStyle = .minimal
        search.searchBar.delegate = self
        return search
    }()
    
    private lazy var historyHintsCollectionView: UICollectionView = makeHintsCollectionView()
    private lazy var hintsCollectionView: UICollectionView = makeHintsCollectionView()
    private lazy var resultsCollectionView: UICollectionView = makeResultsCollectionView()
    
    private var historyHintsDataSource: UICollectionViewDiffableDataSource<Section, Hint>!
    private var hintsDataSource: UICollectionViewDiffableDataSource<Section, Hint>!
    private var resultsDataSource: UICollectionViewDiffableDataSource<Section, ResultsCollectionItem>!
    
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
    
    private lazy var notFoundLabel: UILabel = {
        let notfound = UILabel()
        notfound.text = "По вашему запросу ничего не найдено"
        notfound.font = .systemFont(ofSize: 24, weight: .medium)
        notfound.numberOfLines = 2
        notfound.textAlignment = .center
        notfound.textColor = .black
        notfound.translatesAutoresizingMaskIntoConstraints = false
        notfound.isHidden = true
        return notfound
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        setupCollections()
        setupDataSources()
    }
    
    // MARK: - Setup UI
    
    private func configureNavigationBar() {
        navigationItem.title = "Поиск изображений"
        navigationItem.searchController = searchBar
    }
    
    private func setupDataSources() {
        historyHintsDataSource = makeDataSourceForHints(isHistory: true)
        hintsDataSource = makeDataSourceForHints(isHistory: false)
        resultsDataSource = makeDataSourceForResults()
        
    }
    
    private func setupCollections() {
        view.addSubview(resultsCollectionView)
        view.addSubview(hintsCollectionView)
        view.addSubview(historyHintsCollectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorView)
        view.addSubview(notFoundLabel)
        
        NSLayoutConstraint.activate([
            resultsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            resultsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            hintsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hintsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hintsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hintsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            historyHintsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            historyHintsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            historyHintsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            historyHintsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            notFoundLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            notFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notFoundLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            notFoundLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func makeResultsCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16)
        let width = (UIScreen.main.bounds.width - 10 - 2*16) / 2
        layout.itemSize = CGSize(width: width, height: width * 1.3)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        collectionView.register(ResultsCollectionViewCell.self, forCellWithReuseIdentifier: ResultsCollectionViewCell.identifier)
        collectionView.delegate = self
               return collectionView
    }
    
    private func makeHintsCollectionView() -> UICollectionView {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.headerMode = .none
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        collectionView.delegate = self
        return collectionView
    }
    
    private func makeDataSourceForHints(isHistory: Bool) -> UICollectionViewDiffableDataSource<Section, Hint> {
                let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Hint> { cell, indexPath, hint in
                    var configutation = UIListContentConfiguration.cell()
                    configutation.image = isHistory == true ? UIImage(systemName: hint.icon)?.withRenderingMode(.alwaysOriginal) : UIImage()
                    configutation.text = hint.title
                    cell.contentConfiguration = configutation
                }
                
                let collectionView = isHistory == true ? historyHintsCollectionView : hintsCollectionView
                let dataSource = UICollectionViewDiffableDataSource<Section, Hint>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, hint) -> UICollectionViewCell? in
                    collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: hint)
                })
        
                return dataSource
    }
    
    private func makeDataSourceForResults() -> UICollectionViewDiffableDataSource<Section, ResultsCollectionItem> {
        let dataSource = UICollectionViewDiffableDataSource<Section, ResultsCollectionItem>(collectionView: resultsCollectionView) { [weak self] collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "results_cell", for: indexPath) as! ResultsCollectionViewCell
            cell.configure(resultItem: self!.viewModel.resultsCollectionItems[indexPath.item])
            return cell
        }
        return dataSource
    }
    
    private func updateHintsDataSource(_ dataSource: UICollectionViewDiffableDataSource<Section, Hint>, from hints: [Hint]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Hint>()
        snapshot.appendSections([.first])
        snapshot.appendItems(hints)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateResultsDataSource(from results: [ResultsCollectionItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ResultsCollectionItem>()
        snapshot.appendSections([.first])
        snapshot.appendItems(results)
        resultsDataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if collectionView == self.historyHintsCollectionView {
            let lastHints = viewModel.historyManager.lastHints
            searchBar.searchBar.text = lastHints[indexPath.row]
            searchBarSearchButtonClicked(searchBar.searchBar)
        } else if collectionView == self.hintsCollectionView {
            let filteredHints = viewModel.historyManager.filteredHints
            searchBar.searchBar.text = filteredHints[indexPath.row]
            searchBarSearchButtonClicked(searchBar.searchBar)
        } else {
            let item = viewModel.resultsCollectionItems[indexPath.item]
            let vm = DetailViewModel(detailImageItem: item)
            let detailVC = DetailViewController(viewModel: vm)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - Search Delegates

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            hintsCollectionView.isHidden = true
            historyHintsCollectionView.isHidden = false
            return
        }
        hintsCollectionView.isHidden = false
        historyHintsCollectionView.isHidden = true
        updateHintsDataSource(hintsDataSource, from: viewModel.getFilteredHints(for: searchText))
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        errorView.isHidden = true
        loadingIndicator.isHidden = true
        notFoundLabel.isHidden = true
        historyHintsCollectionView.isHidden = false
        updateHintsDataSource(historyHintsDataSource, from: viewModel.getLastHints())
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resultsCollectionView.isHidden = false
        hintsCollectionView.isHidden = true
        historyHintsCollectionView.isHidden = true
        guard let text = searchBar.text else { return }
        viewModel.getImages(on: text, page: 1)
        viewModel.historyManager.saveQueryInHistory(text)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        historyHintsCollectionView.isHidden = true
        hintsCollectionView.isHidden = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        errorView.isHidden = true
        notFoundLabel.isHidden = true
    }
}

extension MainViewController: MainViewControllerDelegate {
    func mainViewModel(_ viewModel: MainViewModel, wantsToUpdateStateOn state: MainScreenState) {
        switch state {
        case .loading:
            DispatchQueue.main.async { [weak self] in
                self?.loadingIndicator.isHidden = false
                self?.resultsCollectionView.isHidden = true
                self?.errorView.isHidden = true
                self?.notFoundLabel.isHidden = true
                self?.loadingIndicator.startAnimating()
            }
        case .ok:
            DispatchQueue.main.async { [weak self] in
                self?.loadingIndicator.stopAnimating()
                self?.loadingIndicator.isHidden = true
                self?.resultsCollectionView.isHidden = false
                self?.notFoundLabel.isHidden = true
                self?.errorView.isHidden = true
            }
        case .error:
            DispatchQueue.main.async { [weak self] in
                self?.loadingIndicator.stopAnimating()
                self?.loadingIndicator.isHidden = true
                self?.resultsCollectionView.isHidden = true
                self?.errorView.isHidden = false
            }
        case .notfound:
            DispatchQueue.main.async { [weak self] in
                self?.loadingIndicator.stopAnimating()
                self?.loadingIndicator.isHidden = true
                self?.resultsCollectionView.isHidden = true
                self?.notFoundLabel.isHidden = false
            }
        }
    }
    
    func mainViewModel(_ viewModel: MainViewModel, wantsToUpdateResultsCollection items: [ResultsCollectionItem]) {
        updateResultsDataSource(from: items)
    }
}

extension MainViewController: ErrorViewDelegate {
    func errorView(shouldRestartLastRequest errorView: ErrorView) {
        guard let text = searchBar.searchBar.text else { return }
        viewModel.getImages(on: text, page: 1)
    }
}
