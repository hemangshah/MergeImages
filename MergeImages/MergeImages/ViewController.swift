//
//  ViewController.swift
//  MergeImages
//
//  Created by Hemang on 5/10/17.
//  Copyright © 2017 Hemang Shah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imgPreview: UIImageView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgForeground: UIImageView!
    @IBOutlet weak var btnMerge: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.

        showDocument()
        setupDocumentImages()
        setDocumentImagesContentMode()
        setupGestures()
    }

    func showPreview() -> Void {
        imgPreview.isHidden = false
        imgBackground.isHidden = true
        imgForeground.isHidden = true
        btnMerge.setTitle("Back", for: .normal)
    }
    
    func showDocument() -> Void {
        imgPreview.isHidden = true
        imgBackground.isHidden = false
        imgForeground.isHidden = false
        btnMerge.setTitle("Merge", for: .normal)
    }
    
    func setupDocumentImages() -> Void {
        imgBackground.image = UIImage.init(named: "sample.png")
        imgForeground.image = UIImage.init(named: "sign-5.png")
    }
    
    func setDocumentImagesContentMode() -> Void {
        imgBackground.contentMode = .scaleAspectFit
        imgForeground.contentMode = .scaleAspectFit
    }
    
    func setPreviewImageContentMode() -> Void {
        imgPreview.contentMode = .scaleAspectFit
    }
    
    func setupGestures() {
        let pan = UIPanGestureRecognizer(target:self, action:#selector(self.pan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        imgForeground.addGestureRecognizer(pan)
        imgForeground.isUserInteractionEnabled = true
    }
    
    func pan(_ rec:UIPanGestureRecognizer) {
        let translation = rec.translation(in: self.view)
        rec.view!.center = CGPoint(x: rec.view!.center.x + translation.x, y: rec.view!.center.y + translation.y)
        rec.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @IBAction func actionMerge(_ sender: UIButton) {
        
        guard sender.title(for: .normal) == "Merge" else {
            showDocument()
            return
        }
        let previewImage:UIImage? = mergeImages(img: imgBackground.image!, sizeWaterMark: CGRect.init(origin: imgForeground.frame.origin, size: CGSize.init(width: 100, height: 100)), waterMarkImage: imgForeground.image!)
        
        guard previewImage != nil else {
            return
        }
        
        print("New Image: \(String(describing: previewImage))")
        
        imgPreview.image = previewImage
        setPreviewImageContentMode()
        showPreview()
    }
    
    //Answer by Michael (Mixel on SO) help to solve this issue. Thanks to him.
    //http://stackoverflow.com/a/43943956/1603234
    func mergeImages(img:UIImage, sizeWaterMark:CGRect, waterMarkImage:UIImage) -> UIImage {
        let size = self.imgBackground.frame.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        img.draw(in: getAspectFitFrame(sizeImgView: size, sizeImage: img.size))
        let frameAspect:CGRect = getAspectFitFrame(sizeImgView: sizeWaterMark.size, sizeImage: waterMarkImage.size)
        let frameOrig:CGRect = CGRect(x: sizeWaterMark.origin.x+frameAspect.origin.x, y: sizeWaterMark.origin.y+frameAspect.origin.y, width: frameAspect.size.width, height: frameAspect.size.height)
        waterMarkImage.draw(in: frameOrig, blendMode: .normal, alpha: 1)
        let result:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }
    
    //MARK - Get Aspect Fit frame of UIImage
    func getAspectFitFrame(sizeImgView:CGSize, sizeImage:CGSize) -> CGRect {
        
        let imageSize:CGSize  = sizeImage
        let viewSize:CGSize = sizeImgView
        
        let hfactor : CGFloat = imageSize.width/viewSize.width
        let vfactor : CGFloat = imageSize.height/viewSize.height
        
        let factor : CGFloat = max(hfactor, vfactor)
        
        // Divide the size by the greater of the vertical or horizontal shrinkage factor
        let newWidth : CGFloat = imageSize.width / factor
        let newHeight : CGFloat = imageSize.height / factor
        
        var x:CGFloat = 0.0
        var y:CGFloat = 0.0
        
        if hfactor > vfactor {
            y = (sizeImgView.height - newHeight) / 2
        } else {
            x = (sizeImgView.width - newWidth) / 2
        }
        let newRect:CGRect = CGRect(x: x, y: y, width: newWidth, height: newHeight)
        return newRect
    }
}
