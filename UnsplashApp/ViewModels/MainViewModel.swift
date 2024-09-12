//
//  MainViewModel.swift
//  UnsplashApp
//
//  Created by Ilya on 10.09.2024.
//

import Foundation

enum MainScreenState {
    case ok
    case error
    case loading
    case notfound
}

protocol MainViewControllerDelegate: AnyObject {
    func mainViewModel(_ viewModel: MainViewModel, wantsToUpdateStateOn state: MainScreenState)
    func mainViewModel(_ viewModel: MainViewModel, wantsToUpdateResultsCollection items: [ResultsCollectionItem])
}

final class MainViewModel {
    weak var delegate: MainViewControllerDelegate?
    var images: [UnsplashImage]! {
        didSet {
            delegate?.mainViewModel(self, wantsToUpdateResultsCollection: self.resultsCollectionItems)
        }
    }
    
    var resultsCollectionItems: [ResultsCollectionItem] {
        images.map {
            let img = $0.urls.regular
            guard let desc = $0.description else { return nil }
            let username = $0.user.username
            let firstName = $0.user.first_name
            let lastName = $0.user.last_name ?? ""
            
            return ResultsCollectionItem(img: img, description: desc, username: username, firstName: firstName, lastName: lastName)
        }
        .compactMap { $0 }
    }
    
    let apiService: UnsplashAPIService
    let historyManager: HistoryManager
    
    var state: MainScreenState = .ok {
        didSet {
            delegate?.mainViewModel(self, wantsToUpdateStateOn: self.state)
        }
    }
    
    init(apiService: UnsplashAPIService, historyManager: HistoryManager) {
        self.apiService = apiService
        self.historyManager = historyManager
    }
    
    func getLastHints() -> [Hint] {
        return historyManager.getLastStringHints().map {
            Hint(title: $0, icon: "magnifyingglass")
        }
    }
    
    func getFilteredHints(for query: String) -> [Hint] {
        return historyManager.filter(query: query).map { Hint(title: $0, icon: "") }
    }
    
    func getImages(on textRequest: String, page: Int) {
        state = .loading
        let endpoint = UnsplashAPIEndpoint.getImages(query: textRequest, page: page, itemsNumber: 30)
        
        apiService.getResults(from: endpoint) { [weak self] (response: Result<UnsplashSearchResponse, Error>) in
            switch response {
            case .success(let data):
                if data.results.isEmpty {
                    self?.state = .notfound
                    return
                }
                self?.images = data.results
                self?.state = .ok
                
            case .failure(let error):
                self?.state = .error
            }
        }
    }
}
