//
//  CardView.swift
//  Flashzilla
//
//  Created by Zaid Raza on 05/01/2021.
//  Copyright © 2021 Zaid Raza. All rights reserved.
//

import SwiftUI

struct CardView: View {
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    
    let card: Card
    
    var removal: (() -> Void)? = nil
    
    var firstRemoval: (() -> Void)? = nil
    
    @State private var isShowingAnswer = false
    
    @State private var offset = CGSize.zero
    
    @State private var feedback = UINotificationFeedbackGenerator()
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                        ? Color.white
                        : Color.white
                            .opacity(1 - Double(abs(offset.width / 50)))
                    
            )
                .background(
                    differentiateWithoutColor
                        ? nil
                        : RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(offset.width > 0 ? Color.green : Color.red)
            )
                .shadow(radius: 10)
            VStack{
                if accessibilityEnabled{
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                else{
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                    
                    if isShowingAnswer{
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .offset(x: offset.width * 5 ,y: 0)
        .opacity(2 - Double(abs(offset.width / 50)))
        .accessibility(addTraits: .isButton)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.offset = gesture.translation
                    self.feedback.prepare()
            }
            .onEnded { _ in
                if (self.offset.width) > 100 {
                    self.removal?()
                } else {
                    self.offset = .zero
                    self.firstRemoval?()
                }
                if self.offset.width > 0 {
                    // success haptic is making it feel boring.
                }
                else{
                    self.feedback.notificationOccurred(.error)
                }
            }
        )
            .onTapGesture {
                self.isShowingAnswer.toggle()
        }
        .animation(.spring())
    }
}
