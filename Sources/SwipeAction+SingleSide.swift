//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// 
// Created by: Ryan Mckinney on 9/25/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation
import SwiftUI


public extension View {
    
    func withSingleSideSwipeAction<A: View>(sideIsLeft: Bool,
                                            actionCb: @escaping () -> Void,
                                            @ViewBuilder actionBuilder: @escaping () -> A) -> some View {
        
        self
            .modifier(SingleSideSwipeActionModifier(isLeft: sideIsLeft, 
                                                    actionCb: actionCb,
                                                    actionView: actionBuilder))
    }
    
}


//NOT FUNCTIONAL
public struct SingleSideSwipeActionModifier<T: View>: ViewModifier {
    
    let isLeft: Bool
    let actionBuilder: () -> T
    let actionCb: () -> Void
    
    // MARK: - Gesture state

    /// When you touch down with a second finger, the drag gesture freezes, but `currentlyDragging` will be accurate.
    @GestureState var currentlyDragging = false

    /// The gesture's current velocity.
    @GestureVelocity var velocity: CGVector

    /// The offset dragged in the current drag session.
    @State var currentOffset = Double(0)

    /// The offset dragged in previous drag sessions.
    @State var savedOffset = Double(0)
    
    
    
    
    public init(
        isLeft: Bool,
        actionCb: @escaping () -> Void,
        @ViewBuilder actionView: @escaping () -> T
    ) {
        self.isLeft = isLeft
        self.actionCb = actionCb
        self.actionBuilder = actionView
    }
    
    
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        let dragGesture = DragGesture(minimumDistance: 20)
            .updating($currentlyDragging) { value, state, _ in
                state = true
            }
            .onChanged { value in
                print("value.translation.width: \(value.translation.width)")
                self.currentOffset = Double(value.translation.width) + self.savedOffset
            }
            .onEnded { value in
                let offsetAbs = abs(self.currentOffset)
                if offsetAbs > 10 { // Threshold
                    self.actionCb()
                }
                // Reset state
                self.currentOffset = 0
                self.savedOffset = 0
            }
        
        HStack {
            content
        }
        .offset(x: isLeft ? max(CGFloat(currentOffset), 0) : min(CGFloat(currentOffset), 0))
//        .offset(x: isLeft ? min(CGFloat(currentOffset), 0) : max(CGFloat(currentOffset), 0))
            .highPriorityGesture(dragGesture,
                                 including: .all)
            .background {
                bgView
//                    .offset(x: CGFloat(currentOffset))
            }
    }
    
    
    var bgView: some View {
        
        HStack(alignment: .center, spacing: 0) {
            if !self.isLeft {
                Spacer()
            }
            actionView
            
            if self.isLeft {
               Spacer()
            }
        }
    }
    
    
    var actionView: some View {
        actionBuilder()
    }
    
    
}
