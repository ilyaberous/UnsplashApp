//
//  ResultItem.swift
//  UnsplashApp
//
//  Created by Ilya on 11.09.2024.
//

import Foundation

struct ResultsCollectionItem: Hashable {
    let uuid: UUID = UUID()
    let img: String
    let description: String
    let username: String
    let firstName: String
    let lastName: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
