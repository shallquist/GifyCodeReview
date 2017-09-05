//
//  Gif.swift
//  Giphy
//
//  Created by Steven Bishop on 10/21/15.
//  Copyright © 2015 WillowTree. All rights reserved.
//

import Foundation

class Gif {
    let animatedImage: FLAnimatedImage
    var id: String!
    var bitlyUrl: URL!
    var source: URL!
    var trendDate: Date!
    let smallGif: GifSizeDetail
    let largeGif: GifSizeDetail
    
    init(animatedImage: FLAnimatedImage, smallGif: GifSizeDetail, largeGif: GifSizeDetail) {
        self.animatedImage = animatedImage
        self.smallGif = smallGif
        self.largeGif = largeGif
    }
}

class GifSizeDetail {
    let height: Int
    let url: URL
    let width: Int
    
    init(height: Int, url: URL, width: Int) {
        self.height = height
        self.url = url
        self.width = width
    }
}
