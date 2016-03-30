//
//  GridViewCell.swift
//  SimplePhotoFrameworkDemo
//
//  Created by Erickson on 16/3/30.
//  Copyright © 2016年 paiyipai. All rights reserved.
//

import UIKit

class GridViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var representedAssetIdentifier:String?
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func loadImage(image:UIImage) {
        imageView.image = image
    }
    
    
}
