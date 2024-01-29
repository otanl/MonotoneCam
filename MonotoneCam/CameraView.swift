import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    //カメラのアクティブ制御
    @Binding var isCameraActive: Bool

    // CameraViewControllerのインスタンスを生成
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        return cameraViewController
    }

    // isCameraActiveがtrueの場合、写真を撮影する。
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if isCameraActive {
            uiViewController.capturePhoto()
            isCameraActive = false
        }
    }

}
