//
//  BaseViewController.swift
//  Questo
//
//  Created by Taichi Kato on 6/9/17.
//  Copyright © 2017 Questo Inc. All rights reserved.
//

import UIKit
import Vision
import AVFoundation
import Lottie
protocol BaseViewControllerDelegate {
    func beginCoach()
}
class BaseViewController: UIViewController {
    @IBOutlet weak var liveView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    private var haveDisplayedOCRWarning = false
    public var displayOnboarding = false {
        didSet {
            onboard()
        }
    }
    private var stillImageOutput: AVCapturePhotoOutput?
    private var sampleBufferOutput: AVCaptureVideoDataOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let session = AVCaptureSession()
    private let interactor = Interactor()
    private let screenSize = UIScreen.main.bounds
    private var rectangleShape = CAShapeLayer()
    private var consecutiveNonCount = 0
    private var rectangle: VNRectangleObservation?
    var delegate: BaseViewControllerDelegate? = nil
    var rectanglePath = UIBezierPath()
    var capturedImage = UIImage()
    var recentsViewController: RecentsTableViewController!
    var onboardingView = UIView()
    weak var cameraDelegate: CameraViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        do{
            try setupSession()
        }catch{
            print(error)
            view.backgroundColor = .black
            let errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
            errorLabel.center = liveView.center
            errorLabel.text = "There's no camera \(error)"
            view.addSubview(errorLabel)
        }
        setUpViewControllers()
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    func presentOCRWarning(){
        let alert = UIAlertController(title: "Warning",
                                      message: "Camera functionality is still in the testing stage. For the best result, use document upload instead.",
                                      preferredStyle: .alert)
        let doneAction = UIAlertAction(title:"Got it!", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(doneAction)
        self.present(alert, animated: true, completion:nil)

    }
    override func viewDidAppear(_ animated: Bool) {
        onboard()
        self.delegate?.beginCoach()
    }
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: screenSize.width * 3, height: scrollView.frame.height)
        scrollView.setContentOffset(CGPoint(x: screenSize.width, y: 0), animated: false)
        scrollView.alwaysBounceVertical = false
    }
    private func setUpViewControllers(){
        let sb = UIStoryboard(name: "Camera", bundle: nil)
        let sb2 = UIStoryboard(name: "Recents", bundle: nil)
        //MARK: View_01 Camera View
        let cameraView = sb.instantiateViewController(withIdentifier: "camera") as! CameraViewController
        cameraView.delegate = self
        
        self.addChildViewController(cameraView)
        scrollView.addSubview(cameraView.view)
        cameraView.didMove(toParentViewController: self)
        self.cameraDelegate = cameraView
        var cameraViewFrame = cameraView.view.frame
        cameraViewFrame.origin = CGPoint(x: 0, y: 0.0)
        cameraView.view.frame = cameraViewFrame

        //MARK: View_02 Documents View
        let documentView = sb2.instantiateViewController(withIdentifier: "documentUpload")
        self.delegate = documentView as! BaseViewControllerDelegate
        self.addChildViewController(documentView)
        scrollView.addSubview(documentView.view)
        documentView.didMove(toParentViewController: self)
        var documentViewFrame = cameraView.view.frame
        documentViewFrame.origin = CGPoint(x: screenSize.width, y: 0.0)
        documentView.view.frame = documentViewFrame
        
        //MARK: View_03 Recents
        recentsViewController = RecentsTableViewController()
        let nc =  UINavigationController(rootViewController: recentsViewController)
        self.addChildViewController(nc)
        scrollView.addSubview(nc.view)
        nc.didMove(toParentViewController: self)
        var recentsFrame = nc.view.frame
        recentsFrame.origin = CGPoint(x: screenSize.width * 2, y: 0.0)
        nc.view.frame = recentsFrame
    }
    
    func onboard(){
        //MARK: Onboarding View
        if(displayOnboarding){
            displayOnboarding = false
            onboardingView = UIView()
            onboardingView.backgroundColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.8)
            view.addSubview(onboardingView)
            
            var onboardingViewFrame = view.frame
            onboardingViewFrame.origin = CGPoint(x: 0.0, y: 0.0)
            onboardingView.frame = onboardingViewFrame
            
            let animationView = AnimationView()
            animationView.animation = Animation.named("animation-w96-h64")
            onboardingView.addSubview(animationView)
            animationView.loopMode = .loop
            animationView.play()
            animationView.translatesAutoresizingMaskIntoConstraints = false
            
            let closeButton = UIButton()
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.setTitle("Got it", for: .normal)
            closeButton.layer.cornerRadius = 10
            closeButton.layer.borderColor = UIColor.white.cgColor
            closeButton.layer.borderWidth = 1.0
            closeButton.clipsToBounds = true
            closeButton.titleLabel?.textColor = .white
            closeButton.addTarget(self, action: #selector(animateDown), for: .touchDown)
            closeButton.addTarget(self, action: #selector(animateUp), for: .touchUpInside)
            closeButton.addTarget(self, action: #selector(animateUp), for: .touchUpOutside)
            
            onboardingView.addSubview(closeButton)

            let label = UILabel()
            label.numberOfLines = 2
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            onboardingView.addSubview(label)
            label.text = "Swipe left to take a photo, right to access your studysets"
            label.textColor = .white
            
            NSLayoutConstraint.activate([
                closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0),
                closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60.0),
                closeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0),
                label.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20.0),
                label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                animationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            ])
        }
    }
    @objc private func animateDown(sender: Any?) {
        if let button = sender as? UIButton {
            button.animateButtonDown()
            UIView.animate(withDuration: 0.1) {
                button.alpha = 0.6
            }
        }
    }
    @objc private func animateUp(sender: Any?) {
        if let button = sender as? UIButton {
            button.animateButtonUp()

            UIView.animate(withDuration: 0.1, animations: {
                button.alpha = 1.0
                self.onboardingView.alpha = 0.0
            }, completion: { (_) in
                self.onboardingView.removeFromSuperview()
            })
        }
    }
    private func setupSession() throws{
        session.sessionPreset = AVCaptureSession.Preset.photo
        if let backCamera = AVCaptureDevice.default(for: AVMediaType.video){
            do {
                let input = try AVCaptureDeviceInput(device: backCamera)
                stillImageOutput = AVCapturePhotoOutput()
                stillImageOutput?.isHighResolutionCaptureEnabled = true
                sampleBufferOutput = AVCaptureVideoDataOutput()
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(stillImageOutput!) {
                    session.addOutput(stillImageOutput!)
                    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                    videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspect
                    videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                    liveView.layer.addSublayer(videoPreviewLayer!)
                    videoPreviewLayer!.frame = liveView.bounds
                }
                if session.canAddOutput(sampleBufferOutput!){
                    session.addOutput(sampleBufferOutput!)
                    sampleBufferOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
                }
                session.startRunning()
            } catch let error as NSError {
                throw error
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateImage(_ image: UIImage){
        DispatchQueue.main.async {
            self.cameraDelegate.capturedImages.append(image)
            self.cameraDelegate.albumImageView.image = image
        }
    }
    func takePhoto(){
        guard let stillImageOutput = self.stillImageOutput else { return }
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = true
        settings.isHighResolutionPhotoEnabled = true
        if cameraDelegate.flashButton.isSelected{
            settings.flashMode = .on
        }else{
            settings.flashMode = .off
        }
        //Call capture photo method
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
}
extension BaseViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(0.0 < self.scrollView.contentOffset.x && (self.scrollView.contentOffset.x < self.screenSize.width) && !self.haveDisplayedOCRWarning){
            self.presentOCRWarning()
            self.haveDisplayedOCRWarning = true
        }
        if(self.screenSize.width < self.scrollView.contentOffset.x){
            recentsViewController.reload(self)
        }
    }
}
extension BaseViewController: AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer){
            if let rectangle = RectangleDetection.detectRectangle(image: cvBuffer){
                consecutiveNonCount = 0
                self.rectangle = rectangle
                DispatchQueue.main.async {
                    let targetSize = self.liveView.frame.size
                    self.rectangleShape.opacity = 1
                    self.rectangleShape.lineWidth = 5
                    self.rectangleShape.lineJoin = kCALineJoinRound
                    self.rectangleShape.strokeColor = UIColor.magenta.cgColor
                    self.rectangleShape.fillColor = UIColor.magenta.withAlphaComponent(0.6).cgColor
                    
                    let path = UIBezierPath()
                    path.move(to: rectangle.topLeft.scaled(to: targetSize))
                    path.addLine(to: rectangle.topRight.scaled(to: targetSize))
                    path.addLine(to: rectangle.bottomRight.scaled(to: targetSize))
                    path.addLine(to: rectangle.bottomLeft.scaled(to: targetSize))
                    path.close()
                    
                    let animation = CABasicAnimation(keyPath: "path")
                    animation.duration = 0.5
                    // Your new shape here
                    animation.toValue = path.cgPath
                    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                    
                    // The next two line preserves the final shape of animation,
                    // if you remove it the shape will return to the original shape after the animation finished
                    animation.fillMode = kCAFillModeForwards
                    animation.isRemovedOnCompletion = false
                    
                    self.rectangleShape.add(animation, forKey: nil)
                    
                    self.rectangleShape.path = self.rectanglePath.cgPath
                    // The next two line preserves the final shape of animation,
                    // if you remove it the shape will return to the original shape after the animation finished
                    animation.fillMode = kCAFillModeForwards
                    animation.isRemovedOnCompletion = false
                    
                    self.rectangleShape.add(animation, forKey: nil)
                    self.liveView.layer.addSublayer(self.rectangleShape)
                }
            }else{
                DispatchQueue.main.async {
                    if(self.consecutiveNonCount > 10){
                        self.rectangleShape.removeFromSuperlayer()
                    }
                    self.consecutiveNonCount += 1

                }
            }
        }

    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue(label: "imageProcessing").async {
            if let cgImage = photo.cgImageRepresentation()?.takeUnretainedValue(){
                let image = CIImage(cgImage: cgImage)
                let imageSize = image.extent.size
                if let detectedRectangle = RectangleDetection.detectRectangle(image: image, orientation: CGImagePropertyOrientation.up){
                    // Verify detected rectangle is valid.
                    let boundingBox = detectedRectangle.boundingBox.scaled(to: imageSize)
                    if image.extent.contains(boundingBox){
                        // Rectify the detected image and reduce it to inverted grayscale for applying model.
                        let topLeft = detectedRectangle.topLeft.appleScaled(to: imageSize)
                        let topRight = detectedRectangle.topRight.appleScaled(to: imageSize)
                        let bottomLeft = detectedRectangle.bottomLeft.appleScaled(to: imageSize)
                        let bottomRight = detectedRectangle.bottomRight.appleScaled(to: imageSize)
                        let correctedImage = image
                            .cropped(to: boundingBox)
                            .applyingFilter("CIPerspectiveCorrection", parameters: [
                                "inputTopLeft": CIVector(cgPoint: topLeft),
                                "inputTopRight": CIVector(cgPoint: topRight),
                                "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                "inputBottomRight": CIVector(cgPoint: bottomRight)
                                ])
                        self.updateImage(UIImage(ciImage: correctedImage))
                    }
                }else{
                    return
                }
            }
        }
    }
}
