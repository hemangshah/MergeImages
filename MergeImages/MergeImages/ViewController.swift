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
        imgForeground.image = UIImage.init(named: "sign.png")
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
        
        //print("\nNew Location of Signature View: \(NSStringFromCGPoint(rec.view!.frame.origin))")
    }
    
    func calculateOriginForForegroundImage() -> CGPoint {
        let sizeOfBackground = imgBackground.image!.size
        let bWidth:Int = Int(sizeOfBackground.width)
        let bHeight:Int = Int(sizeOfBackground.height)
        
        let originOfForeground = imgForeground.frame.origin
        let fX:Int = Int(originOfForeground.x)
        let fY:Int = Int(originOfForeground.y)
        
        let sizeOfForeground = imgForeground.frame.size
        let fWidth:Int = Int(sizeOfForeground.width)
        let fHeight:Int = Int(sizeOfForeground.height)
        
        let nX:Int = fX
        let nY:Int = fY
        
//        let v = UIView.init(frame: CGRect.init(x: 0, y: 0, width: bWidth, height: bHeight))
        
        print("\nBackground Size [Width:\(bWidth) Height:\(bHeight)]")
        print("\nForeground Origin [X:\(fX) Y:\(fY)]")
        print("\nForeground Size [Width:\(fWidth) Height:\(fHeight)]")
        print("\nNew Origin [X:\(nX) Y:\(nY)]")

        return CGPoint.init(x: nX, y: nY)
    }
    
    @IBAction func actionMerge(_ sender: UIButton) {
        
        guard sender.title(for: .normal) == "Merge" else {
            showDocument()
            return
        }
        
        //let previewImage:UIImage? = mixImagesWith(frontImage: imgForeground.image!, backgroundImage: imgBackground.image!, atPoint: calculateOriginForForegroundImage(), ofSize: CGSize.init(width: 100, height: 100))
        
        let point: CGPoint = calculateOriginForForegroundImage()
        let previewImage:UIImage? = mergeImages(img: imgBackground.image!, sizeWaterMark: CGRect.init(x: point.x, y: point.y, width: 100, height: 100), waterMarkImage: imgForeground.image!)
        
        print(previewImage!)
        
        guard previewImage != nil else {
            return
        }
        
        imgPreview.image = previewImage
        setPreviewImageContentMode()
        showPreview()
    }
    
    func mixImagesWith(frontImage:UIImage?, backgroundImage: UIImage?, atPoint point:CGPoint, ofSize signatureSize:CGSize) -> UIImage {
        let size = self.imgBackground.frame.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        backgroundImage?.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        frontImage?.draw(in: CGRect.init(x: point.x, y: point.y, width: signatureSize.width, height: signatureSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func mergeImages(img:UIImage, sizeWaterMark:CGRect, waterMarkImage:UIImage) -> UIImage {
        let size = self.imgBackground.frame.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        img.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
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
        if newWidth > newHeight{
            y = (sizeImgView.height - newHeight)/2
        }
        if newHeight > newWidth{
            x = (sizeImgView.width - newWidth)/2
        }
        let newRect:CGRect = CGRect(x: x, y: y, width: newWidth, height: newHeight)
        
        return newRect
        
    }
}
