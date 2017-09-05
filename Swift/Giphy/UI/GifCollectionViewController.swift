//
//  GifDisplayViewController.swift
//  Giphy
//
//  Created by Steven Bishop on 10/21/15.
//  Copyright © 2015 WillowTree. All rights reserved.
//

import Foundation
import UIKit

protocol GifDisplayList {
    var gifs: [Gif] { get set }
    var offset: Int { get set }
    var batchSize: Int { get }
    func requestGifs(_ gifHandler: ((Gif) -> Void)?, completion: (([Gif]) -> Void)?)
}

//Don't need to create a separate class for this view, the activityIndicateor can be a property of the Collection View controller.
class LoadingFooterView: UICollectionReusableView {
    static let ReuseIdentifier = "LoadingFooterView"
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
}

let screenWidth = UIScreen.main.bounds.width  
let gifBatchSize = 12
let numberOfGifsPerScreenLimit = 1000  //SH-COMMENT: why limit it?

//SH-COMMENT: DelegateFlowLayout inherits from viewdelegate so viewdelegate can be dropped
class GifCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NetworkErrorDelegate, PeekShareDelegate, GifDisplayList {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    
    var footerView: LoadingFooterView?
    var gifs: [Gif] = []
    var offset = 0
    var batchSize: Int { return gifBatchSize }
    var previewingContext: UIViewControllerPreviewing!

    override func viewDidLoad() {
        super.viewDidLoad()
        requestGifs()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: self.collectionView)
        }
        
        WebService.sharedInstance.networkErrorDelegate = self
        registerCollectionViewCells()
        configureCollectionView()
    }

    deinit {
        unregisterForPreviewing(withContext: previewingContext)
    }
    
    func updateGifs(_ gif: Gif, indexPath: IndexPath, offset: Int) {
        DispatchQueue.main.async { () -> Void in
            
            self.gifs.append(gif)
            if self.gifs.count >= offset - 1 {
                self.footerView!.activityIndicator.stopAnimating()
            }
            
            if (indexPath as NSIndexPath).row == 0 {
                self.collectionView.reloadData()
            } else {
                self.collectionView.insertItems(at: [indexPath])
                self.collectionView!.reloadItems(at: [indexPath])
            }
        }
    }
    
    //MARK: GifDisplayList

    func requestGifs(_ gifHandler: ((Gif) -> Void)?, completion: (([Gif]) -> Void)? = nil) {
        assertionFailure("Subclass must implement")
    }
    
    func requestGifs() {
        self.offset += gifBatchSize
        requestGifs({ gif in
            let indexPath = IndexPath(item: self.gifs.count, section: 0)
            self.updateGifs(gif, indexPath: indexPath, offset: self.offset)
            }, completion: { gifs in
                self.offset = self.offset - gifBatchSize + gifs.count
        })
    }
    
    //MARK: UICollectionView Setup
    
    fileprivate func configureCollectionView() {
        self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        let defaultCellHeight = UITableViewCell().frame.height
        self.flowLayout.footerReferenceSize = CGSize(width: screenWidth, height: defaultCellHeight)
    }
    
    //SH-COMMENT: Don't create a separate method for as single line of code.  combine with method above, since they are both called from the some method.  Since the nib is simply a ImageView, I would consider not using a nib and just use the collectionviewcell element on the storyboard.
    fileprivate func registerCollectionViewCells() {
        self.collectionView.register(UINib(nibName: "GifCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: GifCollectionViewCell.ReuseIdentifier)
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let smallGif = self.gifs[(indexPath as NSIndexPath).item].smallGif
        
        
        /*
        let height = CGFloat(smallGif.height)
        
        //
        let separatorSpace = (self.flowLayout.sectionInset.left + self.flowLayout.sectionInset.right + self.flowLayout.minimumLineSpacing)/2
        
        //SH-COMMENT: remove /2 from above and rewrite as max(0,(x - y)) / 2
        var widthOfCell = screenWidth/2 - separatorSpace
        let widthOfGif = CGFloat(smallGif.width)
        
         //SH-COMMENT: - Need to check that widthOfGif is greater than zero or div by zero error
        var aspectHeight = widthOfCell * height / widthOfGif
        
        //SH-COMMENT: Remove based on change suggested above.
        if aspectHeight < 0 {
            aspectHeight = 0
        }
        
        //SH-COMMENT: why 1 is why not 0?   If so don't need to check either of these, since it's handled above.
        //flow layout cannot have a 0 or negative value as a width or height
        aspectHeight = aspectHeight <= 0 ? 1  : aspectHeight
        widthOfCell = widthOfCell <= 0 ? 1 : widthOfCell
        */
        //SH-COMMENT: I'd rewrite the above as follows:
        let separatorSpace = self.flowLayout.sectionInset.left + self.flowLayout.sectionInset.right + self.flowLayout.minimumLineSpacing

        let widthOfCell = max(0, (screenWidth - separatorSpace)) / 2
        let widthOfGif = CGFloat(smallGif.width)

        let aspectRatio = widthOfGif > 0 ? widthOfCell / widthOfGif  : 1.0

        return CGSize(width: widthOfCell, height: aspectRatio * CGFloat(smallGif.height))
    }
    
    //SH-COMMENT:  Use a segue attached to the collection view cell, and user a perform segue override to assign gif to view controller.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailController = storyboard.instantiateViewController(withIdentifier: "GifDetailViewController") as! GifDetailViewController
        
        detailController.gif = self.gifs[(indexPath as NSIndexPath).item]
        self.navigationController?.pushViewController(detailController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //SH-COMMENT: no need for number of gifs variable.
        let numberOfGifs = self.gifs.count
        
        //SH-COMMENT: This is not necessary, can just call the method on an optional
        guard let activityIndicatorFooter = self.footerView else {
            return
        }
        
        //SH-COMMENT: Not needed, calling start animating again on a cell that is animating will not cause an error
        if activityIndicatorFooter.activityIndicator.isAnimating {
            return
        }
        
        //SH-COMMENT: I'd put the activity view into a view at the bottom and combine the collection view and actiity view into a vertical stack, it's simpler
        if (indexPath as NSIndexPath).row == numberOfGifs - 1 && numberOfGifs >= gifBatchSize && (indexPath as NSIndexPath).row < numberOfGifsPerScreenLimit {
            self.requestGifs()
            
            self.footerView!.activityIndicator.startAnimating()
        } else {
            //SH-COMMENT: really don't need a separate variable!!
            activityIndicatorFooter.activityIndicator.stopAnimating()
        }
    }
    
    //MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCollectionViewCell.ReuseIdentifier, for: indexPath) as! GifCollectionViewCell
        
        if self.gifs.count > (indexPath as NSIndexPath).item {
            cell.animatedImageView!.animatedImage = self.gifs[(indexPath as NSIndexPath).item].animatedImage
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LoadingFooterView.ReuseIdentifier, for: indexPath) as! LoadingFooterView
        footerView.activityIndicator.startAnimating()
        footerView.activityIndicator.hidesWhenStopped = true
        
        self.footerView = footerView
        return footerView
    }
    
    //MARK: Network Error Delegate
    //SH-COMMENT: I would not use a delegate, use a completion handler for errors
    func errorOccured(_ description: String) {
        self.showErrorAlert(description)
    }
    
    func errorSerializingResponse() {
        self.showErrorAlert("There was a hiccup while fetching the most recent requested gifs!")
    }
    
    func showErrorAlert(_ message: String) {
        let alertController = UIAlertController(title: "An error occurred", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default) { (action) -> Void in
            self.footerView?.activityIndicator.stopAnimating()
            self.perform(#selector(GifCollectionViewController.reloadCollectionViewData), with: nil, afterDelay: 3.0)
            
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(alertAction)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    func reloadCollectionViewData() {
        self.collectionView!.reloadData()
    }
    
    //MARK: Peek Share Delegate
    
    func shareViaSMS(_ activityController: UIActivityViewController) {
        self.present(activityController, animated: true, completion: nil)
    }
    
}
