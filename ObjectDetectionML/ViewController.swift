//
//  ViewController.swift
//  ObjectDetectionML
//
//  Created by Emre HAVAN on 31.01.2018.
//  Copyright © 2018 Emre HAVAN. All rights reserved.


//  Please run it on an actual device.
//  Not much of a safe code, error handling is ignored.

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var objectDescriptionLabel: UILabel!
    @IBOutlet weak var detectionPercentageLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        startTheCamera()
        
    }
    
    func startTheCamera() {
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        // Specifying the capture device as video to access back camera.
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        // Set the preview layer to adjust itself to the device.
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Just insert a model of your interest, there are many ML Models for specific uses.
        // Check https://developer.apple.com/machine-learning/
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (completedRequest, error) in
            
            guard let results = completedRequest.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            DispatchQueue.main.async {
                
                // We update our labels as we get the object information each time an observation is completed.
                self.objectDescriptionLabel.text = firstObservation.identifier
                self.detectionPercentageLabel.text = "\(String(Double(firstObservation.confidence * 100.0).roundNumber(digitsToShow: 2)))%"
            }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

}


