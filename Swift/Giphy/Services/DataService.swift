//
//  DataService.swift
//  Giphy
//
//  Created by Steven Bishop on 10/21/15.
//  Copyright © 2015 WillowTree. All rights reserved.
//


//SH-COMMENT: I'd consider combining this class with the web service glass, given that the comments below are considered

import Foundation

let errorGifUrl = Bundle.main.url(forResource: "Error", withExtension: "gif")!
let errorGifWidthOrHeight = 200
let errorGifSizeDetails = GifSizeDetail(height: errorGifWidthOrHeight, url: errorGifUrl, width: errorGifWidthOrHeight)

class DataService: NSObject {
    static let sharedInstance = DataService()

    
    
    let errorGif: Gif = {
        let gifData = try! Data(contentsOf: errorGifUrl)
        let animatedGif = FLAnimatedImage(animatedGIFData: gifData)!
        
        return Gif(animatedImage: animatedGif, smallGif: errorGifSizeDetails, largeGif: errorGifSizeDetails)
    }()
    
    func fetchTrendingGifs(_ offset: Int, amount: Int, gifHandler: ((Gif) -> Void)? = nil, completion: (([Gif]) -> Void)? = nil) {
        
        WebService.sharedInstance.fetchTrendingGifs(amount, offset: offset) { gifs in
            var gifArray: [Gif] = []
            
            for gif in gifs {
                guard let gifDictionary = gif as? [AnyHashable: Any] else {
                    continue
                }
                
                let gif = self.configureGifFromJSONResponse(gifDictionary)
                gifArray.append(gif)
                gifHandler?(gif)
            }
            
            completion!(gifArray)
        }
    }
    
    
    //SH-COMMENT: Move this to the GIF class to handle the conversion of the dictionary to the GIF
    // as part of the initializers in the GIF class make it a failable initializer.  Wouldn't even show an error if can't create a GIF what's the point?
    func configureGifFromJSONResponse(_ gif: [AnyHashable: Any]) -> Gif {
        
        guard let imageDictionary = gif["images"] as? [AnyHashable: Any] else {
            return self.errorGif
        }
        
        guard let downsizedDictionary = imageDictionary["fixed_width_downsampled"] as? [AnyHashable: Any] else {
            return self.errorGif
        }
        
        guard let fullsizedDictionary = imageDictionary["original"] as? [AnyHashable: Any] else {
            return self.errorGif
        }
        
        var downsizedUrl = errorGifUrl
        if let downsizedUrlString = downsizedDictionary["url"] as? String {
            if downsizedUrlString != "" {
                downsizedUrl = URL(string: downsizedUrlString)!
            }
        }
        
        guard let animatedImage = FLAnimatedImage(animatedGIFData: try? Data(contentsOf: downsizedUrl)) else {
            return self.errorGif
        }
        let smallGif = getGifSizeDetail(downsizedDictionary)
        let largeGif = getGifSizeDetail(fullsizedDictionary)
        
        let gifToReturn = Gif(animatedImage: animatedImage, smallGif: smallGif, largeGif: largeGif)
        gifToReturn.id = gif["id"] as? String
        
        if let trendDateString = gif["trending_datetime"] as? String {
            gifToReturn.trendDate = DateFormatterCache.trendingDateFormatter.date(from: trendDateString)!
        }
        
        return gifToReturn
    }
    
    //SH-COMMENT: Move to  GifSizeDetail Initializer Class
    func getGifSizeDetail(_ dictionary: [AnyHashable: Any]) -> GifSizeDetail {
        if let height = dictionary["height"] as? String,
            let heightInt = Int(height),
            let width = dictionary["width"] as? String,
            let widthInt = Int(width),
            let url = dictionary["url"] as? String, url != "" {

                let gifUrl = URL(string: url)
                
                return GifSizeDetail(height: heightInt, url: gifUrl!, width: widthInt)
        }
        
        return errorGifSizeDetails
    }
    
}
