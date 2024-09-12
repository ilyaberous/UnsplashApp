//
//  SplashApiModels.swift
//  UnsplashApp
//
//  Created by Ilya on 12.09.2024.
//

import Foundation

struct UnsplashImage: Codable {
    let id: String
    let urls: URLs
    let description: String?
    let user: User
}

struct URLs: Codable {
    let thumb: String
    let regular: String
}

struct User: Codable {
    let name: String
    let username: String
    let first_name: String
    let last_name: String?
}

struct UnsplashSearchResponse: Codable {
    let results: [UnsplashImage]
}
