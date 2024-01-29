import SwiftUI

struct PreviewView: View {
    let capturedImage: UIImage
    @Binding var isPreviewActive: Bool // 終了ボタンが押されたかどうかを追跡
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Image(uiImage: capturedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Button("終了") {
                    isPreviewActive = false // 終了ボタンが押されたらフラグを設定
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }

        }
    }
}
