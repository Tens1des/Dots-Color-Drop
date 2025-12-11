//
//  PlinkoBoardView.swift
//  Dots Color Drop
//
//  Created by Рома Котов on 10.12.2025.
//

import SwiftUI
import Combine

class PhysicsSimulator: ObservableObject {
    @Published var balls: [Ball] = []
    @Published var ballsReachedBottom: [(ball: Ball, containerIndex: Int)] = []
    var onBallCollision: ((Ball, Ball) -> Void)?
    private var timer: Timer?
    private var lastUpdateTime = Date()
    private var localBalls: [Ball] = []
    private var processedBalls: Set<UUID> = []
    
    func start(pins: [CGPoint], boardWidth: CGFloat, boardHeight: CGFloat, gravity: CGFloat, bounceDamping: CGFloat, ballRadius: CGFloat, pinRadius: CGFloat, frameRate: TimeInterval, containerCount: Int, containerWeights: [ContainerWeight], onBallReachedBottom: @escaping (Ball, Int) -> Void) {
        localBalls = balls
        lastUpdateTime = Date()
        processedBalls = []
        ballsReachedBottom = []
        
        // Capture all parameters explicitly
        let capturedPins = pins
        let capturedBoardWidth = boardWidth
        let capturedBoardHeight = boardHeight
        let capturedGravity = gravity
        let capturedBounceDamping = bounceDamping
        let capturedBallRadius = ballRadius
        let capturedPinRadius = pinRadius
        let containerWidth = capturedBoardWidth / CGFloat(containerCount)
        let capturedContainerWeights = containerWeights
        
        timer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let currentTime = Date()
            let deltaTime = currentTime.timeIntervalSince(self.lastUpdateTime)
            self.lastUpdateTime = currentTime
            
            let dt = CGFloat(deltaTime)
            
            for i in self.localBalls.indices {
                var ball = self.localBalls[i]
                
                // Apply gravity
                ball.velocity.dy += capturedGravity * dt
                
                // Update position
                ball.position.x += ball.velocity.dx * dt
                ball.position.y += ball.velocity.dy * dt
                
                // Check pin collisions
                for pin in capturedPins {
                    let distance = sqrt(pow(ball.position.x - pin.x, 2) + pow(ball.position.y - pin.y, 2))
                    let collisionDistance = capturedBallRadius + capturedPinRadius
                    
                    if distance < collisionDistance {
                        // Collision detected - calculate bounce
                        let normalX = (ball.position.x - pin.x) / max(distance, 0.01)
                        let normalY = (ball.position.y - pin.y) / max(distance, 0.01)
                        
                        // Move ball outside pin
                        let overlap = collisionDistance - distance
                        ball.position.x += normalX * overlap
                        ball.position.y += normalY * overlap
                        
                        // Calculate bounce velocity
                        let dotProduct = ball.velocity.dx * normalX + ball.velocity.dy * normalY
                        ball.velocity.dx -= 2 * dotProduct * normalX * capturedBounceDamping
                        ball.velocity.dy -= 2 * dotProduct * normalY * capturedBounceDamping
                        
                        // Add more randomness for unpredictable bounces
                        ball.velocity.dx += CGFloat.random(in: -50...50)
                        ball.velocity.dy += CGFloat.random(in: -10...10)
                    }
                }
                
                // Check ball-to-ball collisions
                for j in (i + 1)..<self.localBalls.count {
                    var otherBall = self.localBalls[j]
                    let distance = sqrt(pow(ball.position.x - otherBall.position.x, 2) + pow(ball.position.y - otherBall.position.y, 2))
                    let collisionDistance = capturedBallRadius * 2
                    
                    if distance < collisionDistance && distance > 0.01 {
                        // Collision detected - calculate bounce between balls
                        let normalX = (ball.position.x - otherBall.position.x) / distance
                        let normalY = (ball.position.y - otherBall.position.y) / distance
                        
                        // Move balls apart
                        let overlap = collisionDistance - distance
                        let separationX = normalX * overlap * 0.5
                        let separationY = normalY * overlap * 0.5
                        ball.position.x += separationX
                        ball.position.y += separationY
                        otherBall.position.x -= separationX
                        otherBall.position.y -= separationY
                        
                        // Calculate relative velocity
                        let relativeVelX = ball.velocity.dx - otherBall.velocity.dx
                        let relativeVelY = ball.velocity.dy - otherBall.velocity.dy
                        let dotProduct = relativeVelX * normalX + relativeVelY * normalY
                        
                        // Only resolve if balls are moving towards each other
                        if dotProduct < 0 {
                            // Elastic collision with damping
                            let impulse = 2 * dotProduct * 0.5 * capturedBounceDamping
                            ball.velocity.dx -= impulse * normalX
                            ball.velocity.dy -= impulse * normalY
                            otherBall.velocity.dx += impulse * normalX
                            otherBall.velocity.dy += impulse * normalY
                            
                            // Trigger mix spark effect callback
                            DispatchQueue.main.async {
                                self.onBallCollision?(ball, otherBall)
                            }
                        }
                        
                        self.localBalls[j] = otherBall
                    }
                }
                
                // Check wall collisions
                if ball.position.x < capturedBallRadius {
                    ball.position.x = capturedBallRadius
                    ball.velocity.dx *= -capturedBounceDamping
                } else if ball.position.x > capturedBoardWidth - capturedBallRadius {
                    ball.position.x = capturedBoardWidth - capturedBallRadius
                    ball.velocity.dx *= -capturedBounceDamping
                }
                
                // Apply container weight attraction when ball is near bottom (subtle effect)
                if ball.position.y >= capturedBoardHeight - 80 {
                    let ballX = ball.position.x
                    
                    // Check all containers and apply subtle attraction
                    for (index, weight) in capturedContainerWeights.enumerated() {
                        let containerCenterX = CGFloat(index) * containerWidth + containerWidth / 2
                        let distanceX = containerCenterX - ball.position.x
                        let distance = abs(distanceX)
                        
                        // Only apply attraction if ball is relatively close to this container
                        if distance < containerWidth * 1.5 {
                            // Subtle attraction based on weight, with distance falloff
                            let distanceFactor = 1.0 - (distance / (containerWidth * 1.5))
                            let attractionForce = weight.multiplier * 15.0 * distanceFactor * distanceFactor // Quadratic falloff
                            
                            // Apply subtle attraction with randomness to prevent deterministic behavior
                            let randomFactor = CGFloat.random(in: 0.8...1.2)
                            ball.velocity.dx += distanceX * attractionForce * dt * 0.005 * randomFactor
                        }
                    }
                }
                
                // Stop ball at bottom (container level)
                if ball.position.y >= capturedBoardHeight - 20 {
                    ball.position.y = capturedBoardHeight - 20
                    ball.velocity.dy = 0
                    ball.velocity.dx *= 0.9 // Friction
                    
                    // Stop if velocity is very low
                    if abs(ball.velocity.dx) < 5 {
                        ball.velocity.dx = 0
                        
                        // Check if this ball hasn't been processed yet
                        if !self.processedBalls.contains(ball.id) {
                            self.processedBalls.insert(ball.id)
                            
                            // Determine which container the ball fell into
                            let ballX = ball.position.x
                            let containerIndex = min(max(Int((ballX - capturedBallRadius) / containerWidth), 0), containerCount - 1)
                            
                            // Call callback on main thread
                            DispatchQueue.main.async {
                                onBallReachedBottom(ball, containerIndex)
                            }
                        }
                    }
                }
                
                self.localBalls[i] = ball
            }
            
            // Update on main thread
            DispatchQueue.main.async {
                self.balls = self.localBalls
            }
            
            // Check if all balls stopped
            let allStopped = self.localBalls.allSatisfy { abs($0.velocity.dx) < 1 && abs($0.velocity.dy) < 1 && $0.position.y >= capturedBoardHeight - 25 }
            if allStopped && self.localBalls.count > 0 {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.balls = []
                }
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stop()
    }
    
}

struct PlinkoBoardView: View {
    @Binding var containers: [Container]
    @Binding var isDropping: Bool
    var gravityStyle: GravityStyle
    var ballColors: [AppColor] = []
    var physicsEnabled: Bool = true
    var onBallReachedBottom: ((Ball, Int) -> Void)?
    var onBallCollision: ((Ball, Ball) -> Void)?
    
    @State private var balls: [Ball] = []
    @State private var mixSparks: [MixSpark] = []
    @StateObject private var physicsSimulator = PhysicsSimulator()
    
    private let pinSpacing: CGFloat = 35
    private let pinRadius: CGFloat = 3
    private let rows = 6
    private let pinsPerRow = 8
    private let ballRadius: CGFloat = 12
    
    var body: some View {
        ZStack {
            // Board background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#1E1E3F"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "#6C5CE7").opacity(0.3), lineWidth: 1)
                )
            
            // Pins grid - dark purple dots
            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<(row % 2 == 0 ? pinsPerRow : pinsPerRow - 1), id: \.self) { col in
                            Circle()
                                .fill(Color(hex: "#6C5CE7").opacity(0.4))
                                .frame(width: pinRadius * 2, height: pinRadius * 2)
                                .padding(.horizontal, pinSpacing / 2)
                                .padding(.vertical, pinSpacing / 2)
                        }
                    }
                    .offset(x: row % 2 == 0 ? 0 : pinSpacing / 2)
                }
            }
            .padding(.top, 20)
            
            // Dropping balls with 3D effect
            ForEach(physicsEnabled ? physicsSimulator.balls : balls) { ball in
                Ball3DView(color: ball.color, position: ball.position)
            }
            
            // Mix spark effects
            ForEach(mixSparks) { spark in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                spark.mixedColor.color.opacity(0.9),
                                spark.mixedColor.color.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 40, height: 40)
                    .position(spark.position)
                    .opacity(spark.opacity)
            }
        }
        .onChange(of: isDropping) { newValue in
            if newValue {
                startDropping()
            }
        }
    }
    
    private func startDropping() {
        // Stop any existing timer
        physicsSimulator.stop()
        
        // Create balls based on container count or ball colors
        let ballCount = ballColors.isEmpty ? containers.count : ballColors.count
        let boardWidth: CGFloat = 300
        let boardHeight: CGFloat = 280
        let startY: CGFloat = 30
        
        // Calculate pin positions
        var pins: [CGPoint] = []
        let startX: CGFloat = 20
        for row in 0..<rows {
            let pinsInRow = row % 2 == 0 ? pinsPerRow : pinsPerRow - 1
            let rowY = startY + CGFloat(row) * pinSpacing + 30
            let offset = row % 2 == 0 ? 0.0 : pinSpacing / 2
            
            for col in 0..<pinsInRow {
                let pinX = startX + offset + CGFloat(col) * pinSpacing + pinSpacing / 2
                pins.append(CGPoint(x: pinX, y: rowY))
            }
        }
        
        // Create balls at top with colors
        let newBalls = (0..<ballCount).map { index in
            let color: AppColor
            if index < ballColors.count {
                color = ballColors[index]
            } else {
                let fallbackColors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#6C5CE7", "#FD79A8", "#FDCB6E", "#55E6C1"]
                color = AppColor(hex: fallbackColors[index % fallbackColors.count])
            }
            
            // Spread balls across the top with more randomness
            let baseX = boardWidth / 2
            let spreadOffset = CGFloat(index - ballCount / 2) * 50
            let randomOffset = CGFloat.random(in: -30...30)
            let startXPos = baseX + spreadOffset + randomOffset
            
            // Add more random initial velocity for more unpredictable paths
            let initialVelocity = physicsEnabled ? CGVector(
                dx: CGFloat.random(in: -40...40),
                dy: CGFloat.random(in: 20...40)
            ) : CGVector(dx: 0, dy: 0)
            
            return Ball(
                color: color,
                position: CGPoint(x: max(ballRadius, min(startXPos, boardWidth - ballRadius)), y: startY),
                velocity: initialVelocity
            )
        }
        
        if physicsEnabled {
            // Physics-based animation with pin collisions
            physicsSimulator.balls = newBalls
            let gravity: CGFloat = gravityStyle == .fast ? 1200 : gravityStyle == .bouncy ? 600 : 800
            let bounceDamping: CGFloat = gravityStyle == .bouncy ? 0.7 : gravityStyle == .smooth ? 0.5 : 0.3
            let frameRate: TimeInterval = 1.0 / 60.0 // 60 FPS
            physicsSimulator.onBallCollision = { [onBallCollision] ball1, ball2 in
                onBallCollision?(ball1, ball2)
                
                // Create mix spark effect
                let mixedColor = mixColors(ball1.color, ball2.color)
                let sparkPosition = CGPoint(
                    x: (ball1.position.x + ball2.position.x) / 2,
                    y: (ball1.position.y + ball2.position.y) / 2
                )
                
                let spark = MixSpark(mixedColor: mixedColor, position: sparkPosition, opacity: 1.0)
                
                DispatchQueue.main.async {
                    self.mixSparks.append(spark)
                    
                    // Animate spark fade out
                    withAnimation(.easeOut(duration: 0.4)) {
                        if let index = self.mixSparks.firstIndex(where: { $0.id == spark.id }) {
                            self.mixSparks[index].opacity = 0.0
                        }
                    }
                    
                    // Remove spark after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.mixSparks.removeAll { $0.id == spark.id }
                    }
                }
            }
            
            let containerWeights = containers.map { $0.weight }
            physicsSimulator.start(
                pins: pins,
                boardWidth: boardWidth,
                boardHeight: boardHeight,
                gravity: gravity,
                bounceDamping: bounceDamping,
                ballRadius: ballRadius,
                pinRadius: pinRadius,
                frameRate: frameRate,
                containerCount: containers.count,
                containerWeights: containerWeights,
                onBallReachedBottom: { [onBallReachedBottom] ball, containerIndex in
                    onBallReachedBottom?(ball, containerIndex)
                }
            )
        } else {
            // Simple linear animation
            balls = newBalls
            let duration = gravityStyle == .fast ? 1.5 : gravityStyle == .bouncy ? 2.5 : 2.0
            
            withAnimation(.easeIn(duration: duration)) {
                for index in balls.indices {
                    let containerWidth = boardWidth / CGFloat(containers.count)
                    let endX = CGFloat(ballRadius) + (CGFloat(index % containers.count) * containerWidth) + (containerWidth / 2)
                    balls[index].position = CGPoint(x: max(ballRadius, min(endX, boardWidth - ballRadius)), y: boardHeight)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                balls = []
            }
        }
    }
}

// Helper function for mixing colors
private func mixColors(_ color1: AppColor, _ color2: AppColor) -> AppColor {
    // Simple color mixing - average RGB values
    let uiColor1 = color1.uiColor
    let uiColor2 = color2.uiColor
    
    var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
    var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
    
    uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
    
    let mixedR = (r1 + r2) / 2
    let mixedG = (g1 + g2) / 2
    let mixedB = (b1 + b2) / 2
    
    let mixedUIColor = UIColor(red: mixedR, green: mixedG, blue: mixedB, alpha: 1.0)
    let hex = mixedUIColor.toHex()
    
    return AppColor(hex: hex)
}

#Preview {
    PlinkoBoardView(
        containers: .constant([]),
        isDropping: .constant(false),
        gravityStyle: .smooth,
        ballColors: []
    )
}

