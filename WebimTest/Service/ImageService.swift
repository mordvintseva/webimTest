//
//  ImageService.swift
//  WebimTest
//
//  Created by Alena on 04/07/2019.
//  Copyright © 2019 Alena. All rights reserved.
//

import Foundation
import UIKit

class ImageService {
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, completion: @escaping ((Data) -> Void)) {
        let cache = URLCache.shared
        let request = URLRequest(url: url)

        DispatchQueue.global(qos: .userInitiated).async {
            if let data = cache.cachedResponse(for: request)?.data {
                print("loaded from cache")
                completion(data)
            } else {
                self.getData(from: url) { data, response, error in
                    guard let data = data, let response = response, error == nil else { return }
                    print("downloaded from the internet")
                    let cachedData = CachedURLResponse(response: response, data: data)
                    cache.storeCachedResponse(cachedData, for: request)
                    print("cached")
                    completion(data)
                }
            }
        }
    }
}
