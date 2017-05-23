//
//  ImageUtility.swift
//  MergeImages
//
//  Created by Hemang on 5/22/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

//A big thank you to Michael (mixel on StackOverflow) for his answer: http://stackoverflow.com/a/44099380/1603234

extension UIViewController {
    static func mergeImages(img: UIImage, sizeWaterMark: CGRect, waterMarkImage: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(img.size, false, UIScreen.main.scale)
        img.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: img.size))
        let (frameAspect, _) = getAspectFitFrame(from: sizeWaterMark.size, to: waterMarkImage.size)
        let frameOrig = CGRect(x: sizeWaterMark.origin.x + frameAspect.origin.x, y: sizeWaterMark.origin.y + frameAspect.origin.y, width: frameAspect.size.width, height: frameAspect.size.height)
        waterMarkImage.draw(in: frameOrig, blendMode: .normal, alpha: 1)
        let result = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }
    
    static func getAspectFitFrame(from: CGSize, to: CGSize) -> (CGRect, CGFloat) {
        let (hfactor, vfactor, factor) = ViewController.getFactor(from: from, to: to)
        
        // Divide the size by the greater of the vertical or horizontal shrinkage factor
        let newWidth = to.width / factor
        let newHeight = to.height / factor
        
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        if hfactor > vfactor {
            y = (from.height - newHeight) / 2
        } else {
            x = (from.width - newWidth) / 2
        }
        return (CGRect(x: x, y: y, width: newWidth, height: newHeight), factor)
    }
    
    static func getFactor(from: CGSize, to: CGSize) -> (CGFloat, CGFloat, CGFloat) {
        let hfactor = to.width / from.width
        let vfactor = to.height / from.height
        return (hfactor, vfactor, max(hfactor, vfactor))
    }
    
    static func getScaledFrame(from: CGSize, to: CGSize, target: CGRect) -> CGRect {
        let (aspectFitFrame, factor) = ViewController.getAspectFitFrame(from: from, to: to)
        return CGRect(
            origin: CGPoint(
                x: (target.origin.x - aspectFitFrame.origin.x) * factor,
                y: (target.origin.y - aspectFitFrame.origin.y) * factor),
            size: CGSize(width: target.width * factor, height: target.height * factor)
        )
    }
}
