//
//  HintCell.swift
//  UnsplashApp
//
//  Created by Ilya on 10.09.2024.
//

import Foundation

// Модель ячейки с подсказкой
struct Hint: Hashable {
    let uuid: UUID = UUID()
    let title: String
    let icon: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
