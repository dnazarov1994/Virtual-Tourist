//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Dzhavid Babakishiiev on 5/7/19.
//  Copyright © 2019 Dzhavid. All rights reserved.
//

import Foundation
import CoreLocation

class Client {
    
    enum Endpoints {
        static let flickrBase = "https://api.flickr.com/services/rest"
        static let apiKey = "63f4f060789abe2ed8251700e0fa4551"
        static let responseFormat = "json"
        
        static let paramFormat = "format=\(Endpoints.responseFormat)"
        static let paramApiKey = "api_key=\(Endpoints.apiKey)"
        
        case getPhotos(CLLocationCoordinate2D)
        
        var stringValue: String {
            switch self {
            case .getPhotos(let coordinates):
                return Endpoints.flickrBase + "?" + Endpoints.paramApiKey + "&" + Endpoints.paramFormat + "&" + FlickrMethod.getPhotos.param + "&" + "lat=\(coordinates.latitude)&lon=\(coordinates.longitude)"
            }
        }
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
    }
    
    enum FlickrMethod {
        case getPhotos
        
        var method: String {
            switch self {
            case .getPhotos:
                return "flickr.photos.search"
            }
        }
        
        var param: String {
            return "method=\(method)"
        }
    }
    
    class func taskForGetRequest<ResponseType: Decodable>(url:URL, responseType: ResponseType.Type, completion:@escaping(ResponseType?,Error?)->Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let data = cleanJSON(data: data)
                let response = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }

    private class func cleanJSON(data: Data) -> Data {
        var responseJSON = String(data:data, encoding: .utf8)!
        let stringToRemove = "jsonFlickrApi("
        guard responseJSON.contains(stringToRemove) else { return data }
        let startIndex = responseJSON.startIndex
        let range = startIndex...responseJSON.index(startIndex, offsetBy: stringToRemove.count - 1)
        responseJSON.removeSubrange(range)
        responseJSON.removeLast()
        let data = responseJSON.data(using: .utf8)!
        return data
    }
}
