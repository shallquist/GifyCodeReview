//
//  WebService.swift
//  Giphy
//
//  Created by Steven Bishop on 10/21/15.
//  Copyright © 2015 WillowTree. All rights reserved.
//

import Foundation

//SH-COMMENT:  No delegate needed just use a handler
protocol NetworkErrorDelegate: class {
    func errorOccured(_ description: String)
    func errorSerializingResponse()
}

open class WebService {
    
    //SH-COMMENT:  use the Apple API - URLComponents
    class UrlComponents {
        let offset: Int
        let limit: Int
        let path: String
        let baseUrlString = "https://api.giphy.com/v1/gifs/"
        let apiKey = "dc6zaTOxFJmzC"
        
        var url: URL {
            var query = [String]()
            query.append("api_key=\(self.apiKey)")
            query.append("offset=\(self.offset)")
            query.append("limit=\(self.limit)")
            
            return URL(string: "?" + query.joined(separator: "&"), relativeTo: URL(string: self.baseUrlString + self.path + "?"))!
        }
        
        init(offset: Int, limit: Int, path: String) {
            self.offset = offset
            self.limit = limit
            self.path = path
        }
    }
    
    fileprivate let trendingUrlPath = "trending"
    
    weak var networkErrorDelegate: NetworkErrorDelegate?
    
    static let sharedInstance = WebService()
    
    fileprivate let sessionManager: URLSession = {
        let urlSessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
        return URLSession(configuration: urlSessionConfiguration, delegate: nil, delegateQueue: nil)
    }()
    
    //MARK: Trending Gifs
    
    func fetchTrendingGifs(_ amount: Int, offset: Int, completion: @escaping ([AnyObject]) -> Void) {
        
        let urlComponents = UrlComponents(offset: offset, limit: amount, path: trendingUrlPath)
        let request = URLRequest(url: urlComponents.url)
        
        let dataTask = self.sessionManager.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            do {
                if (error != nil) {
                    DispatchQueue.main.async { () -> Void in
                        //SH-COMMENT: Why a delegate, why not just use the completion handler
                        self.networkErrorDelegate?.errorOccured(error!.localizedDescription)
                    }
                } else if data != nil {
                    
                    //SH-COMMENT: Use if let with the OPTIONAL.  This could easily crash
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    if let arrayOfGifs = jsonResponse["data"] as? [AnyObject] {
                        completion(arrayOfGifs)
                    } else {
                        completion([])
                    }
                }
                
            } catch {
                DispatchQueue.main.async { () -> Void in
                    self.networkErrorDelegate?.errorSerializingResponse()
                }
            }
        }) 
        
        dataTask.resume()
    }
    
}
