//
//  TrendingCollectionViewCell.swift
//  Giphy
//
//  Created by Steven Bishop on 10/21/15.
//  Copyright © 2015 WillowTree. All rights reserved.
//

import Foundation

class GifCollectionViewCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "GifCollectionViewCell"
    @IBOutlet var animatedImageView: FLAnimatedImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //for debugging gif aspect ratio
        //        animatedImageView.backgroundColor = getRandomColor()
    }
    
    func getRandomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.animatedImageView.animatedImage = nil
    }
}