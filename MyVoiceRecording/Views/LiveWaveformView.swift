import SwiftUI

struct LiveWaveformView: View {
    var powerLevels: [CGFloat]
    
    var body: some View {
        Canvas { context, size in
            var path = Path()
            let widthPerSegment = size.width / CGFloat(max(1, powerLevels.count - 1))
            
            // Start at bottom left
            path.move(to: CGPoint(x: 0, y: size.height))
            
            for (index, power) in powerLevels.enumerated() {
                // power is between -50 and 0. Normalize between 0.1 and 1.0
                let normalized = max(0.05, min(1, (power + 50) / 50))
                
                // Liquid fills up to 60% of the pill height based on power
                let liquidHeight = size.height * 0.6 * normalized
                let y = size.height - liquidHeight
                
                let x = CGFloat(index) * widthPerSegment
                
                if index == 0 {
                    path.addLine(to: CGPoint(x: x, y: y))
                } else {
                    let previousX = CGFloat(index - 1) * widthPerSegment
                    let previousNormalized = max(0.05, min(1, (powerLevels[index - 1] + 50) / 50))
                    let previousLiquidHeight = size.height * 0.6 * previousNormalized
                    let previousY = size.height - previousLiquidHeight
                    
                    let controlX = (previousX + x) / 2
                    
                    path.addCurve(to: CGPoint(x: x, y: y),
                                  control1: CGPoint(x: controlX, y: previousY),
                                  control2: CGPoint(x: controlX, y: y))
                }
            }
            
            // Draw to the bottom right corner to close the shape
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.closeSubpath()
            
            // Light blue liquid color matching Figma
            context.fill(path, with: .color(Color(red: 0.65, green: 0.78, blue: 0.95)))
        }
    }
}
