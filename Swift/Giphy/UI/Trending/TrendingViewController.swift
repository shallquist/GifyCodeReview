//
//  TrendingViewController.swift
//  Giphy
//
//  Created by Steven Bishop on 10/21/15.
//  Copyright © 2015 WillowTree. All rights reserved.
//

import UIKit

//SH-COMMENT:  Does this make sense? It doesn't no need for this inheriting class
class TrendingViewController: GifCollectionViewController {
    
    override func requestGifs(_ gifHandler: ((Gif) -> Void)?, completion: (([Gif]) -> Void)? = nil) {
        DataService.sharedInstance.fetchTrendingGifs(self.offset, amount: self.batchSize, gifHandler: gifHandler, completion: completion)
    }
    
}
