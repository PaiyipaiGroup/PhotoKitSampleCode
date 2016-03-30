//
//  ViewController.swift
//  SimplePhotoFrameworkDemo
//
//  Created by Erickson on 16/3/29.
//  Copyright © 2016年 paiyipai. All rights reserved.
//

import UIKit
import Photos
//import PhotosUI
class ViewController: UIViewController {

//    var sectionFetchResults = [PHAssetCollection]()
    var fetchResults : PHFetchResult!
    let imageManager = PHCachingImageManager()
    var previousPreheatRect = CGRectZero
    var AssetGridThumbnailSize = CGSizeZero
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetch()
        
        setupCollectionView()
        
        resetCachedAssets()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let scale = UIScreen.mainScreen().scale

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        AssetGridThumbnailSize = CGSizeMake(layout.itemSize.width * scale, layout.itemSize.height * scale)
        
        
    }
    override func viewDidAppear(animated: Bool) {
//        updateCachedAssets()
    }
    
    func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
    }
    func setupCollectionView() {
        
        
        let flowLayout = UICollectionViewFlowLayout()
        let border:CGFloat = 2.0
        let itemW = (self.view.frame.size.width - CGFloat(5 * border)) / 4
        flowLayout.itemSize = CGSizeMake(itemW, itemW)
        flowLayout.minimumInteritemSpacing = border;
        flowLayout.minimumLineSpacing = border;
        flowLayout.sectionInset = UIEdgeInsetsMake(3*border, border, 9, border);
        flowLayout.scrollDirection = .Vertical;
        collectionView.collectionViewLayout = flowLayout
        
    }
    
    func setupFetch() {
        let allPhotosOptions = PHFetchOptions()
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        allPhotosOptions.sortDescriptors = [sort]

        
        fetchResults = PHAsset.fetchAssetsWithOptions(allPhotosOptions)

        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        
    }
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }

    

}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    func updateCachedAssets() {
        let isViewVisible = self.isViewLoaded() && self.view.window != nil
        if !isViewVisible {
            return
        }
        
        let preheatRect = CGRectInset(collectionView.bounds, 0.0, -0.5 * CGRectGetHeight(collectionView.bounds));
        let delta = abs(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
        
        if delta > CGRectGetHeight(collectionView.bounds)/3.0 {
            
            var addedIndexPaths  = [NSIndexPath]()
            var removedIndexPaths  = [NSIndexPath]()
            
            computeDifferenceBetweenRect(previousPreheatRect, newRect: preheatRect, removedHandler: { (removedRect) in
                if self.collectionView.pyp_IndexPathsForElementsInRect(removedRect) != nil {
                    removedIndexPaths = self.collectionView.pyp_IndexPathsForElementsInRect(removedRect)!

                }

                }, addedHandler: { (addedHandler) in
                    if self.collectionView.pyp_IndexPathsForElementsInRect(addedHandler) != nil {
                        addedIndexPaths = self.collectionView.pyp_IndexPathsForElementsInRect(addedHandler)!

                    }

            })
         
            
            let assetsToStartCaching = assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching = assetsAtIndexPaths(removedIndexPaths)
            let size = CGSizeZero
            imageManager.startCachingImagesForAssets(assetsToStartCaching, targetSize: size, contentMode: .AspectFill, options: nil)
            imageManager.stopCachingImagesForAssets(assetsToStopCaching, targetSize: size, contentMode: .AspectFill, options: nil)
            previousPreheatRect = preheatRect
        }
        
    }
    
    func assetsAtIndexPaths(indexPaths:[NSIndexPath])->[PHAsset] {
        if indexPaths.count == 0 {
            return []
        }
        var assets = [PHAsset]()
        for indexPath in indexPaths {
            let asset = fetchResults[indexPath.item] as! PHAsset
            assets.append(asset)
        }
        return assets
        
    }
    
    
    func computeDifferenceBetweenRect(oldRect:CGRect, newRect:CGRect, removedHandler:(CGRect)->Void,addedHandler:(CGRect)->Void) {
        
        
        if CGRectIntersectsRect(newRect, oldRect) {
            let oldMaxY = CGRectGetMaxY(oldRect)
            let oldMinY = CGRectGetMinY(oldRect)
            let newMaxY = CGRectGetMaxY(newRect)
            let newMinY = CGRectGetMinY(newRect)
            
            if (newMaxY > oldMaxY) {
                let rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY))
                
                addedHandler(rectToAdd)
            }
            
            if (oldMinY > newMinY) {
                let rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            
            if (newMaxY < oldMaxY) {
                let rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            
            if (oldMinY < newMinY) {
                let rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    
    
}

extension ViewController : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(changeInstance: PHChange) {
        
    }
}

extension ViewController : UICollectionViewDataSource {
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let asset = fetchResults[indexPath.item] as! PHAsset
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GridCell", forIndexPath: indexPath) as! GridViewCell
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImageForAsset(asset, targetSize: AssetGridThumbnailSize, contentMode: .AspectFill, options: nil) { (result, info) in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.imageView.image = result
            }
        }
                
        return cell
    }
    
}




extension ViewController : UICollectionViewDelegate {
    
}