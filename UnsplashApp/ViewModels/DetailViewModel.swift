//
//  DetailViewModel.swift
//  UnsplashApp
//
//  Created by Ilya on 12.09.2024.
//

import Foundation

enum DetailScreenState {
    case ok
    case error
    case loading
}

protocol DetailViewModelDelegate: AnyObject {
    func detailViewModel(_ viewModel: DetailViewModel, wantsToUpdateStateOn state: DetailScreenState)
}


final class DetailViewModel {
    weak var delegate: DetailViewModelDelegate?
    let detailImageItem: ResultsCollectionItem
    
    var state: DetailScreenState = .ok {
        didSet {
            delegate?.detailViewModel(self, wantsToUpdateStateOn: self.state)
        }
    }
    
    init(detailImageItem: ResultsCollectionItem) {
        self.detailImageItem = detailImageItem
    }
}
