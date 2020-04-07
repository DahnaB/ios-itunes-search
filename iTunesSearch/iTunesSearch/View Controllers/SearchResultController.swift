//
//  SearchResultController.swift
//  iTunesSearch
//
//  Created by Dahna on 4/6/20.
//  Copyright © 2020 Dahna Buenrostro. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case badRequestURL
}

final class SearchResultController {
    enum HTTPMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
    
    
    
    var searchResults: [SearchResult] = []
    
    private let baseURL = URL(string: "https//itunes.apple.com")!
    private var task: URLSessionTask?
    
    func performSearch(searchTerm: String, resultType: ResultType, completion: @escaping (Error?) -> Void) {
        task?.cancel()
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let searchQueryItem = URLQueryItem(name: "/search", value: searchTerm)
        urlComponents?.queryItems = [searchQueryItem]
        
        guard let requestURL = urlComponents?.url else {
            print("Request URL is nil")
            completion(NetworkError.badRequestURL)
            return
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let self = self else { return }
            
            guard let data = data else {
                return completion(NSError())
            }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let iTunesSearch = try jsonDecoder.decode(SearchResults.self, from: data)
                self.searchResults = iTunesSearch.results
                completion(nil)
            } catch {
                completion(error)
            }
        }
        
        task?.resume()
        
    }
}
