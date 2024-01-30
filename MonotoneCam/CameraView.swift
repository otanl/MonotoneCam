import SwiftUI
import AVFoundation

struct CameraView: View {
    @Binding var isCameraActive: Bool
    @State private var countdownSeconds = 3.0
    @State private var showCountdown = false
    @State private var isButtonEnabled = true
    @State private var flashEnabled = false
    @State private var autoFocusEnabled = true
    @State private var showFlashMenu = false
    @State private var showFocusMenu = false
    
    var body: some View {
        GeometryReader { geometry in 
            ZStack {
                // カメラプレビュー
                CameraPreview(isCameraActive: $isCameraActive, flashEnabled: $flashEnabled, autoFocusEnabled: $autoFocusEnabled)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        Spacer()

                        // フラッシュメニュー
                        Menu {
                            Button("オフ") {
                                flashEnabled = false
                            }
                            Button("オン") {
                                flashEnabled = true
                            }
                        } label: {
                            Label("フラッシュ", systemImage: "bolt.fill")
                                .font(.system(size: 14))
                                .foregroundColor(flashEnabled ? .white : .gray)
                        }
                        .padding()

                        // オートフォーカスメニュー
                        Menu {
                            Button("オン") {
                                autoFocusEnabled = true
                            }
                            Button("オフ") {
                                autoFocusEnabled = false
                            }
                        } label: {
                            Label("AF", systemImage: "camera.metering.center.weighted")
                                .font(.system(size: 14))
                                .foregroundColor(autoFocusEnabled ? .white : .gray)
                        }
                        .padding()

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
                        CountdownView(countdownSeconds: $countdownSeconds) {
                            // カウントダウン終了後に撮影
                            capturePhoto()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                    }

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
                            .padding(20)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                    }
                    .padding(.bottom)
                    .disabled(!isButtonEnabled)
                }
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
    @Binding var flashEnabled: Bool
    @Binding var autoFocusEnabled: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.setFlashMode(flashEnabled ? .on : .off)
        cameraViewController.setAutoFocusEnabled(autoFocusEnabled)
        return cameraViewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.setFlashMode(flashEnabled ? .on : .off)
        uiViewController.setAutoFocusEnabled(autoFocusEnabled)
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
