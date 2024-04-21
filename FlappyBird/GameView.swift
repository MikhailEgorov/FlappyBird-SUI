//
//  GameView.swift
//  FlappyBird
//
//  Created by Егоров Михаил on 06.11.2023.
//

import SwiftUI

enum GameState {
    case ready, active, stopped
}

struct GameView: View {
    //сохраняем в userDefaults
    @AppStorage(wrappedValue: 0, "hightScore") private var hightScore: Int
    
    @State private var birdVelocity = CGVector(dx: 0, dy: 0)
    @State private var birdPosotion = CGPoint(x: 100, y: 300)

    @State private var pipeOffset: CGFloat = 0
    @State private var topPipeHeight = CGFloat.random(in: 100...500)
    
    @State private var pastPipe = false
    @State private var gameState: GameState = .ready
    @State private var lastUpdateTime = Date()
    @State private var scores = 0
    

    private let birdSize: CGFloat = 80
    private let birdRadius: CGFloat = 13

    private let pipeWidth: CGFloat = 100
    private let pipeSpacing: CGFloat = 100
    
    private let jumpVelocity = -400
    private let gravity: CGFloat = 1000
    private let groundHeight: CGFloat = 100

    private let timer = Timer.publish(
        every: 0.001,
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    Image(.flappyBirdBackground)
                        .resizable()
                        .ignoresSafeArea()
                        .padding(EdgeInsets(top: 0,
                                            leading: 0,
                                            bottom: -50,
                                            trailing: -30))
                    
                    BirdView(birdSize: birdSize)
                        .position(birdPosotion)
                    
                    PipeView(
                        topPipeHight: topPipeHeight,
                        pipeWidth: pipeWidth,
                        pipeSpacing: pipeSpacing
                    )
                    .offset(x: geometry.size.width + pipeOffset)
                    
                    if gameState == .ready {
                        Button(action: playButtonAction) {
                            Image(systemName: "play.fill")
                        }
                        .font(Font.system(size: 60))
                        .foregroundStyle(.white)
                    }
                    
                    if gameState == .stopped {
                        ResultView(score: scores, hightScore: hightScore) {
                            resetGame()
                        }
                    }
                }
                .onTapGesture {
                    // устанавливает вертикальную скорость вверх
                    birdVelocity = CGVector(dx: 0, dy: -400)
                }
                .onReceive(timer) { currentTime in
                    guard gameState == .active else { return }
                    let deltaTime = currentTime.timeIntervalSince(lastUpdateTime)
                    // применяем гравитацию:
                    applyGravity(deltaTime: deltaTime)
                    // обновляем позицию птицы:
                    updateBirdPosition(deltaTime: deltaTime)
                    checkBoundaries(geometry: geometry)
                    updatePipePosition(deltaTime: deltaTime)
                    resetPipePositionIfNeeded(geometry: geometry)
                    
                    // проверка на столкновение
                    if checkCollisions(geometry: geometry) {
                        gameState = .stopped
                    }
                    
                    updateScores(geometry: geometry)
                    
                    lastUpdateTime = currentTime
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text(scores.formatted())
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
            }
        }
    }
    
    private func playButtonAction() {
        gameState = .active
        lastUpdateTime = Date()
    }
        
        private func applyGravity(deltaTime: TimeInterval) {
            birdVelocity.dy += CGFloat(gravity * deltaTime)
        }
        
        private func updateBirdPosition(deltaTime: TimeInterval) {
            birdPosotion.y += birdVelocity.dy * CGFloat(deltaTime)
        }
    
    private func checkBoundaries(geometry: GeometryProxy) {
        // проверка не достигла ли птица верхней части экрана
        if birdPosotion.y <= 0 {
            birdPosotion.y = 0
            gameState = .stopped
        }
    }
        
        //проверка колизий
    private func checkCollisions(geometry: GeometryProxy) -> Bool {
        // создаем прямоугольник вокруг птицы
        let birdFrame = CGRect(
            x: birdPosotion.x - birdRadius / 2,
            y: birdPosotion.y - birdRadius / 2,
            width: birdRadius,
            height: birdRadius
        )
        
        // создаем прямоугольник вокруг верхнего столба
        let topPipeFrame = CGRect(
            x: geometry.size.width + pipeOffset,
            y: 0,
            width: pipeWidth,
            height: topPipeHeight
        )
        
        // создаем прямоугольник вокруг нижнего столба
        let bottomPipeFrame = CGRect(
            x: geometry.size.width + pipeOffset,
            y: topPipeHeight + pipeSpacing,
            width: pipeWidth,
            height: topPipeHeight
        )
        
        // проверка, не достигла ли птица грунта
        if birdPosotion.y > geometry.size.height - groundHeight {
            birdPosotion.y = geometry.size.height - groundHeight
            birdVelocity.dy = 0
            gameState = .stopped
        }
        
        // пересекается ли прямоугольник птицы с трубой
        return birdFrame.intersects(topPipeFrame) || birdFrame.intersects(bottomPipeFrame)
    }
    
    // обновление положения столбо
    private func updatePipePosition(deltaTime: TimeInterval) {
        pipeOffset -= CGFloat(300 * deltaTime)
    }
    
    // возврат труб к началу
    private func resetPipePositionIfNeeded(geometry: GeometryProxy) {
        if pipeOffset <= -geometry.size.width - pipeWidth {
            pipeOffset = 0
            topPipeHeight = CGFloat.random(in: 100...500)
        }
    }
    
    private func updateScores(geometry: GeometryProxy) {
        if pipeOffset + pipeWidth + geometry.size.width < birdPosotion.x && !pastPipe {
            scores += 1
            
            if scores > hightScore {
                hightScore = scores
            }
            
            pastPipe = true
        } else if pipeOffset + geometry.size.width > birdPosotion.x {
            pastPipe = false
        }
    }
    
    private func resetGame() {
        birdPosotion = CGPoint(x: 100, y: 300)
        birdVelocity = CGVector(dx: 0, dy: 0)
        pipeOffset = 0
        topPipeHeight = CGFloat.random(in: 100...500)
        scores = 0
        gameState = .ready
    }
}

#Preview {
    GameView()
}
