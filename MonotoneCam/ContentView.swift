import SwiftUI

struct ContentView: View {
    @State private var isCameraActive = false

    var body: some View {
        VStack {
            CameraView(isCameraActive: $isCameraActive)

            Spacer()

            Button(action: {
                self.isCameraActive = true
            }) {
                Image(systemName: "camera.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                    .padding(.bottom, 50)
            }
        }
    }
}


#Preview {
    ContentView()
}
