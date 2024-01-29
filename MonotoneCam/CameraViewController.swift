import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let photoOutput = AVCapturePhotoOutput()

    // ビューの読み込み時の設定
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }

    // カメラセッションの設定
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()

        // バックカメラの設定
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            fatalError("カメラが取得できませんでした。")
        }
        captureSession.addInput(videoDeviceInput)
        
        // 写真出力の設定
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        captureSession.commitConfiguration()

        // プレビューレイヤーを設定して、カメラ映像を表示
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // カメラセッションの開始
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

        // 写真データを取得してライブラリに保存
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        } else {
            print("画像データを取得できませんでした。")
        }
    }

    // ステータスバーを非表示に設定
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
