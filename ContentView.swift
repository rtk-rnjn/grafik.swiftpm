import SwiftUI

struct ContentView: View {
    @State private var zoomScale: CGFloat = 1.0
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    
    let unit: CGFloat = 50

    func evaluateFunction(x: CGFloat, zoomScale: CGFloat) -> CGFloat {
        let xValue = Double(x) / (unit * zoomScale)
        return CGFloat(exp(xValue)) * unit * zoomScale
    }

    func drawGridLines(in context: GraphicsContext, size: CGSize, midX: CGFloat, midY: CGFloat, unit: CGFloat) {
        let tickLength: CGFloat = 5
        
        for x in stride(from: midX, through: size.width, by: unit) {
            context.stroke(Path { path in
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }, with: .color(.gray.opacity(0.3)), lineWidth: 1)
        }
        for x in stride(from: midX, through: 0, by: -unit) {
            context.stroke(Path { path in
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }, with: .color(.gray.opacity(0.3)), lineWidth: 1)
        }
        
        for y in stride(from: midY, through: size.height, by: unit) {
            context.stroke(Path { path in
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }, with: .color(.gray.opacity(0.3)), lineWidth: 1)
        }
        for y in stride(from: midY, through: 0, by: -unit) {
            context.stroke(Path { path in
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }, with: .color(.gray.opacity(0.3)), lineWidth: 1)
        }

        for x in stride(from: midX, through: size.width, by: unit) {
            context.stroke(Path { path in
                path.move(to: CGPoint(x: x, y: midY - tickLength))
                path.addLine(to: CGPoint(x: x, y: midY + tickLength))
            }, with: .color(.gray), lineWidth: 1)
        }
        for x in stride(from: midX, through: 0, by: -unit) {
            context.stroke(Path { path in
                path.move(to: CGPoint(x: x, y: midY - tickLength))
                path.addLine(to: CGPoint(x: x, y: midY + tickLength))
            }, with: .color(.gray), lineWidth: 1)
        }
        for y in stride(from: midY, through: size.height, by: unit) {
            context.stroke(Path { path in
                path.move(to: CGPoint(x: midX - tickLength, y: y))
                path.addLine(to: CGPoint(x: midX + tickLength, y: y))
            }, with: .color(.gray), lineWidth: 1)
        }
        for y in stride(from: midY, through: 0, by: -unit) {
            context.stroke(Path { path in
                path.move(to: CGPoint(x: midX - tickLength, y: y))
                path.addLine(to: CGPoint(x: midX + tickLength, y: y))
            }, with: .color(.gray), lineWidth: 1)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Canvas { context, size in
                    let midX = size.width / 2 + offsetX
                    let midY = size.height / 2 + offsetY
                    
                    let scaledUnit = unit * zoomScale
                    
                    drawGridLines(in: context, size: size, midX: midX, midY: midY, unit: scaledUnit)
                    
                    context.stroke(Path { path in
                        path.move(to: CGPoint(x: 0, y: midY))
                        path.addLine(to: CGPoint(x: size.width, y: midY))
                        path.move(to: CGPoint(x: midX, y: 0))
                        path.addLine(to: CGPoint(x: midX, y: size.height))
                    }, with: .color(.gray), lineWidth: 1)
                    
                    var path = Path()
                    for x in stride(from: -midX, to: midX, by: 1) {
                        let graphX = x + midX
                        let graphY = midY - evaluateFunction(x: x, zoomScale: zoomScale)
                        if x == -midX {
                            path.move(to: CGPoint(x: graphX, y: graphY))
                        } else {
                            path.addLine(to: CGPoint(x: graphX, y: graphY))
                        }
                    }
                    context.stroke(path, with: .color(.blue), lineWidth: 2)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                
                ZStack {
                    let labelSpacing: CGFloat = unit * zoomScale
                    let labelOffset: CGFloat = 20
                    
                    let maxXLabels = Int(geometry.size.width / (2 * labelSpacing))
                    let maxYLabels = Int(geometry.size.height / (2 * labelSpacing))
                    
                    ForEach(-maxXLabels...maxXLabels, id: \.self) { i in
                        if i != 0 {
                            Text("\(i)")
                                .font(.caption)
                                .position(x: geometry.size.width / 2 + CGFloat(i) * labelSpacing + offsetX, y: geometry.size.height / 2 + 15 + offsetY)
                        }
                    }
                    
                    ForEach(-maxYLabels...maxYLabels, id: \.self) { i in
                        if i != 0 {
                            Text("\(i)")
                                .font(.caption)
                                .position(x: geometry.size.width / 2 - labelOffset + offsetX, y: geometry.size.height / 2 - CGFloat(i) * labelSpacing + offsetY)
                        }
                    }
                }
            }
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        zoomScale = value
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offsetX = value.translation.width
                        offsetY = value.translation.height
                    }
            )
        }
        .edgesIgnoringSafeArea(.horizontal)
        .border(.gray)
    }
}
