import UIKit
import AVFoundation
import Photos
import CoreImage
import MobileCoreServices
import SwiftUI


class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, ObservableObject {
    var onPhotoCaptureCompleted: (() -> Void)?
    @Published var isCameraFlipped: Bool = false
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var hostingController: UIHostingController<PreviewView>?
    @State private var isPreviewActive = false

    var flashMode: AVCaptureDevice.FlashMode = .off
    var autoFocusEnabled: Bool = true

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

        // オートフォーカスの設定
        if autoFocusEnabled {
            if videoDevice.isFocusModeSupported(.continuousAutoFocus) {
                try? videoDevice.lockForConfiguration()
                videoDevice.focusMode = .continuousAutoFocus
                videoDevice.unlockForConfiguration()
            }
        } else {
            if videoDevice.isFocusModeSupported(.locked) {
                try? videoDevice.lockForConfiguration()
                videoDevice.focusMode = .locked
                videoDevice.unlockForConfiguration()
            }
        }

        captureSession.commitConfiguration()

        // AVCapturePhotoOutputの初期化
        photoOutput = AVCapturePhotoOutput()

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

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
        photoSettings.flashMode = flashMode
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    // 写真撮影が完了した後の処理
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        // デバッグ出力
        print("Camera is flipped: \(isCameraFlipped)")
        
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
            var finalImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: uiOrientation)

            if !isCameraFlipped {
                finalImage = finalImage.withHorizontallyFlippedOrientation().rotate(radians: .pi)
            }

            // 撮影した写真をフォトライブラリに保存
            UIImageWriteToSavedPhotosAlbum(finalImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
            // 画像をDocumentディレクトリに保存する
            saveImageToDocumentsDirectory(image: finalImage)
            

            // 撮影した写真をPreviewViewに渡して遷移
            let previewView = PreviewView(capturedImage: finalImage, isPreviewActive: $isPreviewActive)
            let hostingController = UIHostingController(rootView: previewView)
            hostingController.modalPresentationStyle = .fullScreen
            self.present(hostingController, animated: true, completion: nil)
        } else {
            print("向き情報が取得できませんでした。")
        }
    }

    // フラッシュモードの設定
    func setFlashMode(_ mode: AVCaptureDevice.FlashMode) {
        flashMode = mode
    }

    // オートフォーカスの設定
    func setAutoFocusEnabled(_ enabled: Bool) {
        autoFocusEnabled = enabled
    }
    
    func setCameraFlipped(_ isFlipped: Bool) {
        self.isCameraFlipped = isFlipped
        if let connection = previewLayer?.connection, connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = isFlipped
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
    
    /*
    // ステータスバーを非表示に設定
    override var prefersStatusBarHidden: Bool {
        return true
    }
     */
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

private func saveImageToDocumentsDirectory(image: UIImage) {
    guard let data = image.jpegData(compressionQuality: 1.0) ?? image.pngData() else {
        print("画像データの変換に失敗しました。")
        return
    }

    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileName = "capturedImage_\(Date().timeIntervalSince1970).jpg"
    let fileURL = documentsDirectory.appendingPathComponent(fileName)

    do {
        try data.write(to: fileURL, options: .atomic)
        print("画像を保存しました: \(fileURL)")
    } catch {
        print("画像の保存に失敗しました: \(error)")
    }
}

