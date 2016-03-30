//
//  UICollectionViewExtension.swift
//  SimplePhotoFrameworkDemo
//
//  Created by Erickson on 16/3/29.
//  Copyright © 2016年 paiyipai. All rights reserved.
//

import Foundation
import UIKit


extension UICollectionView {
    func pyp_IndexPathsForElementsInRect(rect:CGRect) -> [NSIndexPath]? {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElementsInRect(rect)
        
        if allLayoutAttributes?.count == 0 {
            return nil
        }
        var indexPaths = [NSIndexPath]()
        for layoutAttributes in allLayoutAttributes! {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        return indexPaths
        
    }
}