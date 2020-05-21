//
//  CameraViewController.swift
//  Questo
//
//  Created by Taichi Kato on 25/8/17.
//  Copyright © 2017 Questo Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Answers
extension UIView{
    func fadeIn(_ duration: TimeInterval = 0.6, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 0.3, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    @IBOutlet weak var guidanceView: UIView!
    @IBOutlet weak var albumImageView: UIImageView!
    var mediumImpactFeedbackGenerator: UIImpactFeedbackGenerator? = nil
    weak var delegate: BaseViewController!
    @IBOutlet weak var shutterFlash: UIView!
    @IBOutlet weak var uploadButton: UIButton!
//    @IBOutlet weak var cameraOverlay: UIImageView!
//    @IBAction func onFakePhoto(_ sender: Any) {
//    }
//
//    @IBAction func openAlbum(_ sender: Any) {
//        performSegue(withIdentifier: "openMenu", sender: nil)
//    }
    @IBAction func onTakePhoto(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.guidanceView.alpha = 0 // Here you will get the animation you want
        }) { _ in
            self.guidanceView.isHidden = true
        }
        guidanceView.alpha = 0.0
        uploadButton.alpha = 1
        Answers.logCustomEvent(withName: "TookPhoto", customAttributes: ["hola": "hello"])
        if let parent = parent as? BaseViewController{
            if UIDevice.current.hasHapticFeedback {
                mediumImpactFeedbackGenerator?.impactOccurred()
            } else if UIDevice.current.hasTapticEngine {
                // Fallback for older devices
                let peek = SystemSoundID(1519)
                AudioServicesPlaySystemSound(peek)
            } else {
                // Can't play haptic signal...
            }
            
            shutterFlash.fadeIn()
            shutterFlash.fadeOut()
            parent.takePhoto()
//            uploadButton.setTitle("Upload \(parent.albumDelegate.images.count)", for: .normal)
            self.guidanceView.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 2, options: .curveEaseInOut, animations: {
                self.guidanceView.alpha = 1 // Here you will get the animation you want
            }) { _ in
            }
        }
    }
    @IBOutlet weak var flashButton: UIButton!
    @IBAction func toggleFlash(_ sender: Any) {
        if flashButton.isSelected{
            flashButton.isSelected = false
        }else{
            flashButton.isSelected = true
        }
    }
    internal var capturedImages = [UIImage]()
    private var stillImageOutput: AVCapturePhotoOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let session = AVCaptureSession()
    private let interactor = Interactor()
    override func viewDidLoad() {
        self.guidanceView.isHidden = true
        self.guidanceView.alpha = 0.0
        if UIDevice.current.hasHapticFeedback {
            mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        }
        setupUI()
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        capturedImages = []
        albumImageView.image = UIImage()
        self.guidanceView.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 2, options: .curveEaseInOut, animations: {
            self.guidanceView.alpha = 1 // Here you will get the animation you want
        }) { _ in
        }
    }
    private func setupUI() {
        uploadButton.alpha = 0
        albumImageView.clipsToBounds = true
        albumImageView.contentMode = .scaleAspectFill
        flashButton.setImage(UIImage(named: "FlashOff"), for: .normal)
        flashButton.setImage(UIImage(named: "FlashOn"), for: .selected)
//        cameraOverlay.isUserInteractionEnabled = false
    }
    @IBAction func generate(_ sender: Any) {
        let vc = EditorViewController()
        vc.images = capturedImages
        self.presentAsStork(vc)
    }
}
