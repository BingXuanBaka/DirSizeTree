//
//  PieChart.swift
//  DirSizeTree
//
//  Created by 冰轩 on 2024/2/25.
//

import SwiftUI

func processChartData (data: [PieChartData]) -> [ProcessedChartData] {
    var result: [ProcessedChartData] = []
    var startAngle: Double = 0
    
    for _data in data {
        let endAngle = 360 * _data.percent + startAngle
        result.append(ProcessedChartData(hint: _data.hint, startAngle: startAngle, endAngle: endAngle))
        startAngle = endAngle
    }
    
    return result
}

func getCurrentElement (data: [ProcessedChartData], angle: Double) -> Int {
    for index in 0..<data.count {
        if(data[index].endAngle > angle) {
            return index
        }
    }
    
    return -1
}

func genColors(_count: Int) -> [Color] {
    var result: [Color] = []
    for _ in 0..<_count {
        result.append(Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)))
    }
    
    return result
}

func isInside(x: Double, y: Double, radius: Double) -> Bool{
    let radian = atan2(y, x)
    
    if(y / sin(radian) > radius){
        return false
    }
    
    return true
}

struct PieChartElement: InsettableShape {
    var startAngle: Double
    var endAngle: Double
    var inset: CGFloat = 0
    
    
    func path(in rect: CGRect) -> Path {
        var path = Path ()
        let width = rect.width
        let radius = min(rect.width, rect.height) / 2
        let height = rect.height
        
        path.move(to: CGPoint(x: width / 2, y: height / 2))
        path.addArc(center: CGPoint(x: width / 2, y: height / 2),
                    radius: radius - inset,
                    startAngle: Angle(degrees: startAngle),
                    endAngle: Angle(degrees: endAngle),
                    clockwise: false)
        
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var element = self
        element.inset += amount
        return element
    }
}

struct PieChart: View {
    var data: [PieChartData]
    private var processedData: [ProcessedChartData];
    
    @State var mouseX = 0.0
    @State var mouseY = 0.0
    @State var overlayShown = false
    @State var angle = 0.0
    
    let colors = genColors(_count: 10)
    
    init(data: [PieChartData]) {
        self.data = data
        self.processedData =  processChartData(data: data)
    }
    
    var body: some View {
        GeometryReader {geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let radius = min(width, height)
            let currentElementIndex = getCurrentElement(data: processedData, angle: angle)
            
            ZStack{
                ForEach(0..<processedData.count, id: \.self) { index in
                    let _data = processedData[index]
                    let active = index == currentElementIndex && overlayShown
                    
                    PieChartElement(startAngle: _data.startAngle,
                                    endAngle: _data.endAngle)
                    .fill(Color(hue: _data.startAngle / 365, saturation: 0.6, brightness: 0.8))
                    .zIndex(active ? 10 : 0)
                    .shadow(color: Color.black.opacity(active ? 0.4 : 0), radius: 6)
                }
            }.overlay(alignment:Alignment.topLeading){
                Text(currentElementIndex == -1 ? "" : data[currentElementIndex].hint)
                    .padding()
                    .background(Material.thick)
                    .foregroundColor(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .offset(x: mouseX, y: mouseY)
                    .opacity(overlayShown ? 1 : 0)
            }.onContinuousHover{phase in
                switch phase{
                case .active(let location) :
                    let widthOffset = (width - radius) / 2
                    let heightOffset = (height - radius) / 2
                    
                    mouseX = location.x
                    mouseY = location.y
                    
                    let centerX = mouseX - widthOffset - (radius / 2)
                    let centerY = 0 - (mouseY - heightOffset - (radius / 2))
                    
                    overlayShown = isInside(x: centerX,
                                            y: centerY,
                                            radius: radius / 2) && currentElementIndex != -1
                    
                    let _angle = 0 - (atan2(centerY, centerX) * 180 / Double.pi)
                    angle = _angle < 0 ? 180 + _angle + 180 : _angle
                    
                    break
                    
                case .ended:
                    overlayShown = false
                    break
                }
            }

        }
    }
}


#Preview {
    PieChart(data: [
        PieChartData(hint: "a\n4kb", percent: 0.4),
        PieChartData(hint: "b\n1kb", percent: 0.3),
        PieChartData(hint: "c\n1kb", percent: 0.1),
        PieChartData(hint: "d\n1kb", percent: 0.1),
        PieChartData(hint: "e\n1kb", percent: 0.1)])
}

