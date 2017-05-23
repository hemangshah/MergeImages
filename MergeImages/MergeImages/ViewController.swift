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
        imgBackground.image = UIImage.init(named: "sample-4.png")
        imgForeground.image = UIImage.init(named: "sign-2.png")
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
        
        let previewImage = ViewController.mergeImages(img: imgBackground.image!, sizeWaterMark: ViewController.getScaledFrame(from: imgBackground.frame.size, to: imgBackground.image!.size, target: imgForeground.frame),
            waterMarkImage: imgForeground.image!
        )
        
        print("New Image: \(String(describing: previewImage))")
        
        imgPreview.image = previewImage
        setPreviewImageContentMode()
        showPreview()
    }
}
