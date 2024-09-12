//
//  SplashApiService.swift
//  UnsplashApp
//
//  Created by Ilya on 12.09.2024.
//

import Foundation


protocol APIService: AnyObject {
    associatedtype Success: Any
    func getResults(from endpoint: API, completion: @escaping (Result<Success, Error>) -> ())
}

enum SplashAPIEndpoint: API {
    case getImages(query: String, page: Int, itemsNumber: Int)
    var scheme: HTTPScheme {
        switch self {
        case .getImages:
            return .https
        }
    }
    
    var baseURL: String {
        switch self {
        case .getImages:
            return "api.unsplash.com"
        }
    }
    
    var path: String {
        switch self {
        case .getImages:
            return "/search/photos"
        }
    }
    
    var parameters: [URLQueryItem] {
        switch self {
        case .getImages(let query, let page, let itemsNumber):
            let params = [
                URLQueryItem(name: "client_id", value: "p-lrf4Gd_azpJGOSMn0I5-nUQoJcQmSxi-zRWer6vMs"),
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(itemsNumber)),
            ]
            return params
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getImages:
            return .get
        }
    }
}


final class SplashAPIService: APIService {
    
    internal func buildURL(endpoint: API) -> URLComponents {
        var components = URLComponents()
        components.scheme = endpoint.scheme.rawValue
        components.host = endpoint.baseURL
        components.path = endpoint.path
        components.queryItems = endpoint.parameters
        return components
    }
    
    func getResults(from endpoint: API, completion: @escaping (Result<UnsplashSearchResponse, Error>) -> ()) {
        let components = buildURL(endpoint: endpoint)
        guard let url = components.url else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = endpoint.method.rawValue
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) {
            data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard response != nil, let data = data else {
                return
            }
            
            do {
                let responseObject = try JSONDecoder().decode(UnsplashSearchResponse.self,
                                                            from: data)
                completion(.success(responseObject))
            } catch let jsonError as NSError {
                completion(.failure(jsonError))
            }
        }
        dataTask.resume()
    }
}
