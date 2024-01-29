import UIKit
import AVFoundation
import Photos
import CoreImage
import MobileCoreServices
import SwiftUI

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var hostingController: UIHostingController<PreviewView>?
    @State private var isPreviewActive = false

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

        // AVCapturePhotoOutputの初期化
        photoOutput = AVCapturePhotoOutput()

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
              let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            print("画像の加工に失敗しました。")
            return
        }

        // CIImageの向き情報を取得
        if let orientation = photo.metadata[kCGImagePropertyOrientation as String] as? UInt32,
           let uiOrientation = UIImage.Orientation(rawValue: Int(orientation)) {
            // CGImageからUIImageに変換し、向き情報を設定
            let finalImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: uiOrientation)

            // 上下反転
            let flippedImage = finalImage.withHorizontallyFlippedOrientation()

            // 180度回転
            let rotatedImage = flippedImage.rotate(radians: .pi)

            // 撮影した写真をフォトライブラリに保存
            UIImageWriteToSavedPhotosAlbum(rotatedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

            // 撮影した写真をPreviewViewに渡して遷移
            let previewView = PreviewView(capturedImage: rotatedImage, isPreviewActive: $isPreviewActive)
            let hostingController = UIHostingController(rootView: previewView)
            hostingController.modalPresentationStyle = .fullScreen
            self.present(hostingController, animated: true, completion: nil)
        } else {
            print("向き情報が取得できませんでした。")
        }
    }

    // 写真保存後のコールバック
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("写真の保存に失敗しました: \(error.localizedDescription)")
        } else {
            print("写真が正常に保存されました。")
        }
    }

    // ステータスバーを非表示に設定
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// rotateメソッドの定義
extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            context.rotate(by: radians)
            draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return rotatedImage ?? self
        }
        return self
    }
}
