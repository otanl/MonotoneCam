import SwiftUI

struct ContentView: View {
    @State private var isCameraActive = false

    var body: some View {
        VStack {
            CameraView(isCameraActive: $isCameraActive)

            Spacer()


        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
