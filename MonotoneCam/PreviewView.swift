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
                
                Button(action: {
                    isPreviewActive = false // 終了ボタンが押されたらフラグを設定
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("終了")
                        .fontWeight(.medium)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .foregroundColor(.gray)
                        .background(Color(.systemGray3))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 8, y: 8)
                        .shadow(color: Color.white.opacity(0.4), radius: 8, x: -3, y: -3)
                }
                .padding()
            }
        }
    }
}
