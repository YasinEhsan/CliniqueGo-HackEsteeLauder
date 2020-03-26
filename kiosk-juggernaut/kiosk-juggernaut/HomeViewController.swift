//
//  HomeViewController.swift
//  kiosk-juggernaut
//
//  Created by Matthew Rodriguez on 10/12/19.
//  Copyright © 2019 Matthew Rodriguez. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Firebase

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    var modelMap = [
        "CICAgICAgLn0FxIGcHVycGxl": "CLINIQUE take the day off, makeup remover. 40 points", // purple
        "CICAgICAgLnCHhIFcGVhY2g=": "CLINIQUE moisture surge, extended thirst relief. 40 points",  // peach
        "CICAgICAgLn6PxIGb3Jhbmdl": "CLINIQUE fresh pressed, daily booster. 60 points"  // orange
    ]
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
    }
    @IBAction func onUpload(_ sender: Any) {
        if productImage.image == nil {
            print("No photo")
            // On failure: Present an error alert
            let title = "Error"
            let message = "An error has occured. No photo to upload."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            print("Clicked upload")
            // Upload photo to Firebase
            var orderItem = ""
            var orderPoints = ""
            print(productLabel.text!)
            
            if productLabel.text == "CLINIQUE take the day off, makeup remover. 40 points" {
                orderItem = "Makeup Remover"
                orderPoints = "40"
            } else if productLabel.text == "CLINIQUE moisture surge, extended thirst relief. 40 points" {
                orderItem = "Moisture Surge"
                orderPoints = "40"
            } else if productLabel.text == "CLINIQUE fresh pressed, daily booster. 60 points" {
                orderItem = "Fresh Pressed"
                orderPoints = "60"
            } else {
                orderItem = "Error"
                orderPoints = "Error points"
            }
            let uuid = UUID().uuidString
            //        self.ref.child("OrderHistory").child("Redness Solutions").setValue([orderItem: orderPoints])
            self.ref.child("OrderHistory/\(uuid)").setValue([orderItem:orderPoints])
            print("Posted to firebase)")
            let title = "Success"
            let message = "User profile points updated."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            productImage.image = nil
        }
        
        
    }
    
    @IBAction func onButtonPress(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Gets called when an image is selected
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // TODO: Add code here to talk to AutoML -> Upload to Firebase
        productImage.image = image
        //        let model = KioskScanner()
        //        let pixelBufferFromImage = pixelBuffer(forImage: image.cgImage!)
        //        guard let prediction = try? model.prediction(image__0: pixelBufferFromImage!) else { fatalError("Prediction error")}
        //        productLabel.text = "\(prediction.classLabel)"
        guard let ciImage = CIImage(image: image) else {
            fatalError("Not able to convert UIImage to CIImage")
        }
        
        detectProduct(image: ciImage)
    }
    
    //    func pixelBuffer (forImage image:CGImage) -> CVPixelBuffer? {
    //        let frameSize = CGSize(width: 224, height: 224)
    //
    //        var pixelBuffer:CVPixelBuffer? = nil
    //        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
    //
    //        if status != kCVReturnSuccess {
    //            return nil
    //
    //        }
    //        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
    //        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
    //        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    //        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
    //        let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
    //
    //
    //        context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
    //
    //        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    //
    //        return pixelBuffer
    //    }
    
    func detectProduct(image: CIImage) {
        productLabel.text = "Detecting product..."
        
        guard let model = try? VNCoreMLModel(for: KioskScanner().model) else {
            fatalError("Can't load KioskScanner ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("Unexpected result type from VNCoreMLRequest")
            }
            
            // Update UI on main queue
            DispatchQueue.main.async { [weak self] in
                self?.confidenceLabel.text = "\(Int(topResult.confidence * 100))% confidence"
                self?.productLabel.text = "\(self?.modelMap[topResult.identifier] ?? "model lookup error")"
            }
        }
        
        // Run the Core ML model classifier on global dispatch queue
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
}
