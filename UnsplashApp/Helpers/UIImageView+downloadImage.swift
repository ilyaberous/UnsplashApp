//
//  UIImageView+downloadImage.swift
//  UnsplashApp
//
//  Created by Ilya on 12.09.2024.
//

import Foundation
import UIKit


let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    @discardableResult
    func loadImageFromURL(urlString: String,
                          placeholder: UIImage? = nil, completion: @escaping (Error?) -> ()) ->
    URLSessionDataTask? {
        self.image = nil
        let key = NSString(string: urlString)
        if let cachedImage = imageCache.object(forKey: key) {
            self.image = cachedImage
            return nil
        }
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        if let placeholder = placeholder {
            self.image = placeholder
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let data = data,
                   error == nil,
                   let downloadedImage = UIImage(data: data) {
                    imageCache.setObject(downloadedImage,
                                         forKey:
                                            NSString(string: urlString))
                    self.image = downloadedImage
                    completion(nil)
                } else if let error = error {
                    completion(error)
                }
            }
        }
        
        task.resume()
        return task
    }
}
