import UIKit
import AVFoundation
import Photos
import CoreImage
import MobileCoreServices

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let photoOutput = AVCapturePhotoOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }

    // カメラセッションの設定
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            fatalError("バックカメラが取得できませんでした。")
        }
        captureSession.addInput(videoDeviceInput)
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        captureSession.commitConfiguration()

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    // 写真撮影の実行
    func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    //モノトーンフィルターの処理
    func applyMonochromeFilter(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image),
              let filter = CIFilter(name: "CIPhotoEffectMono") else {
            return nil
        }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        let context = CIContext(options: nil)
        guard let outputCIImage = filter.outputImage,
              let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    

    
    // 写真撮影が完了した後の処理
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("エラー発生: \(error.localizedDescription)")
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let ciImage = CIImage(data: imageData),
              let filter = CIFilter(name: "CIPhotoEffectMono") else {
            print("画像データを取得できませんでした。")
            return
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)

        let context = CIContext(options: nil)
        guard let outputCIImage = filter.outputImage,
              let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent),
              let finalImage = createUIImage(from: cgImage, with: photo.metadata) else {
            print("画像の加工に失敗しました。")
            return
        }

        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
    }

    // CGImageとメタデータを使用してUIImageを生成（向き情報保持のため）
    func createUIImage(from cgImage: CGImage, with metadata: [String: Any]) -> UIImage? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil) else {
            return nil
        }
        
        CGImageDestinationAddImage(destination, cgImage, metadata as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        
        return UIImage(data: data as Data)
    }


    // ステータスバーを非表示に設定
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
