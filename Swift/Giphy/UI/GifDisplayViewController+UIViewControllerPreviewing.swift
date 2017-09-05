//
//  GifDisplayViewController+UIViewControllerPreviewing.swift
//  Giphy
//
//  Created by Steven Bishop on 10/22/15.
//  Copyright © 2015 WillowTree. All rights reserved.
//

import Foundation

extension GifCollectionViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = collectionView.indexPathForItem(at: location),
            let cell = collectionView.cellForItem(at: indexPath) else { return nil }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailController = storyboard.instantiateViewController(withIdentifier: "GifDetailViewController") as! GifDetailViewController
        detailController.shareDelegate = self
        
        previewingContext.sourceRect = cell.frame
        
        detailController.gif = self.gifs[(indexPath as NSIndexPath).item]
        detailController.preferredContentSize = CGSize(width: 0.0, height: 400.0)
        
        return detailController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Reuse the "Peek" view controller for presentation.
        show(viewControllerToCommit, sender: self)
    }
}
