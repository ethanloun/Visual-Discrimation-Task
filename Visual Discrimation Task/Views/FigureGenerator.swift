//
//  FigureGenerator.swift
//  Visual Discrimation Task
//
//  Created by Ethan on 9/18/25.
//

import SwiftUI

// MARK: - Figure Generator
struct FigureGenerator {
    static func generateFigure(type: FigureType, rotationAngle: Double) -> some View {
        Group {
            switch type {
            case .simple:
                SimpleFigure()
            case .medium:
                MediumFigure()
            case .complex:
                ComplexFigure()
            case .veryComplex:
                VeryComplexFigure()
            }
        }
        .rotationEffect(.degrees(rotationAngle))
        .animation(.easeInOut(duration: 0.3), value: rotationAngle)
    }
}

// MARK: - Simple Figure
struct SimpleFigure: View {
    var body: some View {
        ZStack {
            // Basic geometric shape
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue)
                .frame(width: 80, height: 60)
            
            // Simple internal pattern
            VStack(spacing: 4) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 30, height: 8)
            }
        }
    }
}

// MARK: - Complex Figure
struct ComplexFigure: View {
    var body: some View {
        ZStack {
            // Complex geometric shape
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple)
                .frame(width: 100, height: 80)
            
            // Complex internal pattern
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 15, height: 15)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 20, height: 15)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 15, height: 15)
                }
                
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 12, height: 8)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 12, height: 8)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 12, height: 8)
                }
                
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 25, height: 6)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 25, height: 6)
                }
            }
        }
    }
}

// MARK: - Medium Figure
struct MediumFigure: View {
    var body: some View {
        ZStack {
            // Medium complexity geometric shape
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green)
                .frame(width: 90, height: 70)
            
            // Medium internal pattern
            VStack(spacing: 5) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 18, height: 18)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 25, height: 12)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 18, height: 18)
                }
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 35, height: 6)
                
                HStack(spacing: 3) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 15, height: 8)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                }
            }
        }
    }
}

// MARK: - Very Complex Figure
struct VeryComplexFigure: View {
    var body: some View {
        ZStack {
            // Very complex geometric shape
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.red)
                .frame(width: 110, height: 90)
            
            // Very complex internal pattern
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 18, height: 12)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 18, height: 12)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                }
                
                HStack(spacing: 3) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 10, height: 6)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 10, height: 6)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 10, height: 6)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 10, height: 6)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 15, height: 8)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 15, height: 8)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                }
                
                HStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 8, height: 4)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 8, height: 4)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 8, height: 4)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 8, height: 4)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 8, height: 4)
                }
            }
        }
    }
}

// MARK: - Figure Preview
struct FigurePreview: View {
    let figureType: FigureType
    let rotationAngle: Double
    
    var body: some View {
        FigureGenerator.generateFigure(type: figureType, rotationAngle: rotationAngle)
            .frame(width: 120, height: 120)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Figure Types Preview")
            .font(.title2)
            .fontWeight(.bold)
        
        HStack(spacing: 20) {
            VStack {
                Text("Simple")
                    .font(.caption)
                FigurePreview(figureType: .simple, rotationAngle: 0)
            }
            
            VStack {
                Text("Medium")
                    .font(.caption)
                FigurePreview(figureType: .medium, rotationAngle: 0)
            }
            
            VStack {
                Text("Complex")
                    .font(.caption)
                FigurePreview(figureType: .complex, rotationAngle: 0)
            }
            
            VStack {
                Text("Very Complex")
                    .font(.caption)
                FigurePreview(figureType: .veryComplex, rotationAngle: 0)
            }
        }
        
        Text("Rotated Examples")
            .font(.headline)
        
        HStack(spacing: 20) {
            FigurePreview(figureType: .simple, rotationAngle: 45)
            FigurePreview(figureType: .simple, rotationAngle: 90)
            FigurePreview(figureType: .complex, rotationAngle: 135)
            FigurePreview(figureType: .complex, rotationAngle: 180)
        }
    }
    .padding()
}
