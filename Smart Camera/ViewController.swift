//
//  ViewController.swift
//  Smart Camera
//
//  Created by Jaskirat Singh on 13/04/18.
//  Copyright © 2018 jassie. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let textLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
        // MARK: Code to start up the camera.
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
            
        }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
            
        }
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        // MARK: monitor what's happening everytime frame is being captured by the camera.
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        setupTextLabel()
    }
    
    // MARK: to setup textlabel constraints
    
    func setupTextLabel()
    {
        view.addSubview(textLabel)
        textLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        textLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        textLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        textLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // MARK: To see what camera is seeing.
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // MARK: At line 74 download the Resnet50 model mentioned in ReadMe and drag it into the project.
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            return
        }
        let request = VNCoreMLRequest(model: model) { (completion, error) in

            guard let results = completion.results as? [VNClassificationObservation] else {
                return
            }
            guard let firstObservation = results.first else {
                return
            }
            print(firstObservation.identifier, firstObservation.confidence)
            DispatchQueue.main.async
            {
                self.textLabel.text = "\(firstObservation.identifier)"
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [ : ]).perform([request])
    }
    
}

