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
            case .complex:
                ComplexFigure()
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
        
        HStack(spacing: 30) {
            VStack {
                Text("Simple")
                    .font(.caption)
                FigurePreview(figureType: .simple, rotationAngle: 0)
            }
            
            VStack {
                Text("Complex")
                    .font(.caption)
                FigurePreview(figureType: .complex, rotationAngle: 0)
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
