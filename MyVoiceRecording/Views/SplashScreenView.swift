import SwiftUI

struct SplashScreenView: View {
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Image("AppIconImage") // Assuming we use AppIconImage from xcassets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .cornerRadius(24)
                    .shadow(color: .purple.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Text("My Voices")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.0)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
