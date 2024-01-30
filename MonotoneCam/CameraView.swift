import SwiftUI
import AVFoundation

struct CameraView: View {
    @Binding var isCameraActive: Bool
    @StateObject private var cameraViewController = CameraViewController()
    @State private var countdownSeconds = 3.0
    @State private var showCountdown = false
    @State private var isButtonEnabled = true
    @State private var flashEnabled = false
    @State private var autoFocusEnabled = true
    @State private var isCameraFlipped = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreview(cameraViewController: cameraViewController, isCameraActive: $isCameraActive)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        Spacer()

                        // フラッシュメニュー
                        flashMenu

                        // オートフォーカスメニュー
                        autoFocusMenu

                        // カメラの映像反転ボタン
                        cameraFlipMenu

                        Spacer()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                            .opacity(0.5)
                    )
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.03)
                    .padding(.top, 25)

                    Spacer()

                    // カウントダウン表示
                    if showCountdown {
                        countdownView
                    }

                    // 撮影ボタン
                    captureButton
                }
            }
        }
    }

    // フラッシュメニュー
    var flashMenu: some View {
        Menu {
            Button("オフ") {
                cameraViewController.setFlashMode(.off)
                flashEnabled = false
            }
            Button("オン") {
                cameraViewController.setFlashMode(.on)
                flashEnabled = true
            }
        } label: {
            Label("フラッシュ", systemImage: "bolt.fill")
                .font(.system(size: 14))
                .foregroundColor(flashEnabled ? .white : .gray)
        }
        .padding()
    }

    // オートフォーカスメニュー
    var autoFocusMenu: some View {
        Menu {
            Button("オン") {
                cameraViewController.setAutoFocusEnabled(true)
                autoFocusEnabled = true
            }
            Button("オフ") {
                cameraViewController.setAutoFocusEnabled(false)
                autoFocusEnabled = false
            }
        } label: {
            Label("AF", systemImage: "camera.metering.center.weighted")
                .font(.system(size: 14))
                .foregroundColor(autoFocusEnabled ? .white : .gray)
        }
        .padding()
    }

    // カメラの映像反転ボタン
    var cameraFlipMenu: some View {
        Menu {
            Button("オン") {
                cameraViewController.setCameraFlipped(true)
                isCameraFlipped = true
            }
            Button("オフ") {
                cameraViewController.setCameraFlipped(false)
                isCameraFlipped = false
            }
        } label: {
            Label(isCameraFlipped ? "反転" : "反転", systemImage: isCameraFlipped ? "arrow.triangle.2.circlepath.camera.fill" : "arrow.triangle.2.circlepath.camera")
                .font(.system(size: 14))
                .foregroundColor(isCameraFlipped ? .white : .gray)
        }
        .padding()
    }

    // カウントダウン表示
    var countdownView: some View {
        CountdownView(countdownSeconds: $countdownSeconds) {
            capturePhoto()
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
    }

    // 撮影ボタン
    var captureButton: some View {
        Button(action: {
            if isButtonEnabled {
                prepareForCapture()
            }
        }) {
            Image(systemName: "camera.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(20)
                .background(Color(.systemGray3))
                .clipShape(Circle())
        }
        .padding(.bottom)
        .disabled(!isButtonEnabled)
    }

    // 撮影準備
    func prepareForCapture() {
        showCountdown = true
        startCountdown()
    }

    // カウントダウン開始
    func startCountdown() {
        isButtonEnabled = false
        countdownSeconds = 3.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if countdownSeconds > 0 {
                countdownSeconds -= 0.1
            } else {
                timer.invalidate()
                DispatchQueue.main.async {
                    capturePhoto()
                }
            }
        }
        RunLoop.current.add(timer, forMode: .common)
    }

    // 写真を撮影
    func capturePhoto() {
        cameraViewController.capturePhoto()
        isCameraActive = false
        showCountdown = false
        isButtonEnabled = true
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var cameraViewController: CameraViewController
    @Binding var isCameraActive: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        return cameraViewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if isCameraActive {
            uiViewController.capturePhoto()
        }
    }
}

struct CountdownView: View {
    @Binding var countdownSeconds: Double
    var onCountdownEnd: () -> Void

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(Color.white)

            Circle()
                .trim(from: 0.0, to: CGFloat(countdownSeconds) / 3.0)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.white)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: countdownSeconds)

            Text("\(Int(countdownSeconds+0.99))")
                .font(.largeTitle)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 3, y: 3)
                .shadow(color: Color.white.opacity(0.4), radius: 3, x: -0.5, y: -0.5)
        }
        .frame(width: 100, height: 100)
        .background(Color(.systemGray3))
        .clipShape(Circle())
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 8, y: 8)
        .shadow(color: Color.white.opacity(0.4), radius: 8, x: -3, y: -3)
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(isCameraActive: .constant(false))
    }
}
