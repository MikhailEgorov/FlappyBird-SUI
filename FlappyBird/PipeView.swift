//
//  PipeView.swift
//  FlappyBird
//
//  Created by Егоров Михаил on 06.11.2023.
//

import SwiftUI

struct PipeView: View {
    let topPipeHight: CGFloat
    let pipeWidth: CGFloat
    let pipeSpacing: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let availableHeight = geometry.size.height - pipeSpacing
            let bottomPipeHeight = availableHeight - topPipeHight
            
            VStack {
                // top pipe
                Image(.flappeBirdPipe)
                    .resizable()
                    .rotationEffect(.degrees(180))
                    .frame(width: pipeWidth, height: topPipeHight)
                
                Spacer()
                    .frame(height: pipeSpacing)
                
                Image(.flappeBirdPipe)
                    .resizable()
                    .frame(width: pipeWidth, height: bottomPipeHeight)
            }
        }
    }
}

#Preview {
    PipeView(topPipeHight: 300, pipeWidth: 100, pipeSpacing: 100)
}
