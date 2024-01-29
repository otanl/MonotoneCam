import SwiftUI
import AVFoundation

struct CameraView: View {
    @Binding var isCameraActive: Bool
    @State private var countdownSeconds = 3.0
    @State private var showCountdown = false
    @State private var isButtonEnabled = true 

    var body: some View {
        ZStack {
            // カメラプレビュー
            CameraPreview(isCameraActive: $isCameraActive)
                .edgesIgnoringSafeArea(.all)

            // カウントダウン表示
            if showCountdown {
                CountdownView(countdownSeconds: $countdownSeconds) {
                    // カウントダウン終了後に撮影
                    capturePhoto()
                }
            }

            VStack {
                Spacer()
                // 撮影ボタン
                Button(action: {
                    if isButtonEnabled {
                        showCountdown = true
                        startCountdown()
                    }
                }) {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                }
                .padding(.bottom)
                .disabled(!isButtonEnabled)
            }
        }
    }

    // カウントダウン開始
    func startCountdown() {
        isCameraActive = false
        isButtonEnabled = false
        countdownSeconds = 3.0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if countdownSeconds > 0 {
                countdownSeconds -= 0.1
            } else {
                timer.invalidate()
                // カウントダウンが終了した後、撮影を実行する
                DispatchQueue.main.async {
                    capturePhoto()
                }
            }
        }
        // タイマーをRunLoopに追加して実行する
        RunLoop.current.add(timer, forMode: .common)
    }
    
    // 写真を撮影
    func capturePhoto() {
        isCameraActive = true
        showCountdown = false
        isButtonEnabled = true
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    @Binding var isCameraActive: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        return cameraViewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if isCameraActive {
            uiViewController.capturePhoto()
            isCameraActive = false
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
        }
        .frame(width: 100, height: 100)
        .onAppear {
            if countdownSeconds <= 0 {
                onCountdownEnd()
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(isCameraActive: .constant(false))
    }
}
