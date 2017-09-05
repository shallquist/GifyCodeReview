//
//  GifDetailViewController.swift
//  Giphy
//
//  Created by Steven Bishop on 10/22/15.
//  Copyright © 2015 WillowTree. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

protocol PeekShareDelegate {
    func shareViaSMS(_ activityController: UIActivityViewController)
}

class GifDetailViewController: UIViewController {

    @IBOutlet var animatedImageView: FLAnimatedImageView!
    @IBOutlet var trendingLabel: UILabel!
    @IBOutlet var smsShareButton: UIButton!
    @IBOutlet var copyToClipboardButton: UIButton!

    var gif: Gif!
    var fullSizeGifData: Data?
    var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var shareDelegate: PeekShareDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchFullSizeGif()
    }
    
    func setupView() {
        self.activityIndicatorView.hidesWhenStopped = true
        let rightBarButtonView = UIBarButtonItem(customView: self.activityIndicatorView)
        self.navigationItem.rightBarButtonItem = rightBarButtonView
        self.activityIndicatorView.startAnimating()
        
        self.animatedImageView.animatedImage = self.gif.animatedImage
        setTrendingingLabel()
    }
    
    func setTrendingingLabel() {
        guard let trendDate = gif.trendDate else {
            self.trendingLabel.text = ""
            return
        }
        
        let dateStringPartOne = DateFormatterCache.trendedOnDateFormatter.string(from: trendDate)
        self.trendingLabel.text = "Trended on: \(dateStringPartOne)"
        
    }
    
    //SH-COMMENT: move this functionality to the GIF class.
    func fetchFullSizeGif() {
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            if let largeGifData = try? Data(contentsOf: self.gif.largeGif.url as URL) {
                
                //SH-COMMENT: assignment should be done on the main thread
                self.fullSizeGifData = largeGifData
                let animatedImage = FLAnimatedImage(animatedGIFData: largeGifData)
                
                DispatchQueue.main.async { () -> Void in
                    self.activityIndicatorView.stopAnimating()
                    self.smsShareButton.isEnabled = true
                    self.copyToClipboardButton.isEnabled = true
                    self.animatedImageView.animatedImage = animatedImage
                }
            }
        })
    }
    
    @IBAction func smsShareButtonTapped(_ sender: UIButton) {
        let activityController = UIActivityViewController(activityItems: [self.fullSizeGifData!], applicationActivities: [])
        self.navigationController?.present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func copyToClipboardTapped(_ sender: UIButton) {
        UIPasteboard.general.setData(self.fullSizeGifData!, forPasteboardType: kUTTypeGIF as String)
    }
    
    // MARK: Preview actions
    
    override var previewActionItems : [UIPreviewActionItem] {
        
        let copyActionItem = UIPreviewAction(title: "Copy", style: UIPreviewActionStyle.default) { (action, controller) -> Void in
            let data = self.getBestGifDataAvailable()
            UIPasteboard.general.setData(data, forPasteboardType: kUTTypeGIF as String)
        }
        
        let shareActionItem = UIPreviewAction(title: "Share", style: UIPreviewActionStyle.default) { (action, controller) -> Void in
            let data = self.getBestGifDataAvailable()
            let activityController = UIActivityViewController(activityItems: [data], applicationActivities: [])
            if self.shareDelegate != nil {
                self.shareDelegate?.shareViaSMS(activityController)
            }
        }
        
        return [copyActionItem, shareActionItem]
    }
    
    
    fileprivate func getBestGifDataAvailable() -> Data {
        
        //SH-COMMENT: Replace below with this:
        //return self.fullSizeGifData ?? self.gif.animatedImage.data
        
        var data: Data
        if self.fullSizeGifData != nil {
            data = self.fullSizeGifData!
        } else {
            data = self.gif.animatedImage.data
        }
        
        return data
    }
}
