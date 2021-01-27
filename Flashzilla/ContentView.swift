//
//  ContentView.swift
//  Flashzilla
//
//  Created by Zaid Raza on 01/01/2021.
//  Copyright © 2021 Zaid Raza. All rights reserved.
//

import SwiftUI
import CoreHaptics

struct ContentView: View {
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    @State private var isActive = true
    @State private var showingEditScreen = false
    @State private var timeEnded = false
    @State private var cardRetry : Bool = false
    @State private var shouldFirstRemove = true
    
    @State private var timeRemaining = 20
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    enum sheetCase {
        case editSheet, settingsSheet
    }
    
    @State private var activeSheet: sheetCase = .editSheet
    
    @State private var cards = [Card]()
    
    var body: some View {
        
        ZStack{
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack{
                
                Text(timeEnded ? "Think faster next time" : "Time Remaining: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.black)
                            .opacity(0.75)
                )
                
                ZStack{
                    ForEach(0..<cards.count, id: \.self) { index in
                        
                        CardView(card: self.cards[index], removal: {
                            withAnimation{
                                self.removeCard(at: index)
                            }
                            self.shouldFirstRemove = false
                        }){
                            if self.shouldFirstRemove && self.cardRetry{
                                withAnimation{
                                    self.swapCard(at: index)
                                }
                                self.shouldFirstRemove = false
                            }
                            else{
                                withAnimation{
                                    self.removeCard(at: index)
                                }
                            }
                        }
                        .stacked(at: index, in: self.cards.count)
                        .allowsHitTesting(index == self.cards.count - 1)
                        .accessibility(hidden: index < self.cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                
                if cards.isEmpty{
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
            }
            
            VStack{
                HStack{
                    Button(action:{
                        self.activeSheet = .settingsSheet
                        
                        self.showingEditScreen = true
                    }) {
                        Image(systemName: "arrow.clockwise.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action:{
                        self.activeSheet = .editSheet
                        
                        self.showingEditScreen = true
                    }) {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColor || accessibilityEnabled{
                HStack {
                    Button(action: {
                        if self.shouldFirstRemove && self.cardRetry{
                            withAnimation{
                                self.swapCard(at: self.cards.count - 1)
                            }
                            self.shouldFirstRemove = false
                            
                        }
                        else{
                            withAnimation{
                                self.removeCard(at: self.cards.count - 1)
                            }
                        }
                    }) {
                        Image(systemName: "xmark.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .accessibility(label: Text("Wrong"))
                    .accessibility(hint: Text("Mark your answer as being incorrect."))
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            self.removeCard(at: self.cards.count - 1)
                        }
                    }) {
                        Image(systemName: "checkmark.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .accessibility(label: Text("Correct"))
                    .accessibility(hint: Text("Mark your answer as being correct."))
                }
            }
        }
        .sheet(isPresented: $showingEditScreen){
            
            if self.activeSheet == .editSheet {
                EditCards()
                    .onDisappear(perform: self.resetCards)
            }
            else {
                SettingsView(settingsEnabled: self.$cardRetry)
            }
        }
        .onAppear(perform: resetCards)
        .onReceive(timer) { time in
            guard self.isActive else { return }
            if self.timeRemaining > 0{
                self.timeRemaining -= 1
            }
            else{
                self.timeEnded = true
                self.gameEnded()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)){_ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)){_ in
            if self.cards.isEmpty == false{
                self.isActive = true
            }
        }
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
    
    func resetCards() {
        timeRemaining = 20
        self.timeEnded = false
        isActive = true
        loadData()
    }
    
    func gameEnded(){
        withAnimation{
            cards = []
        }
    }
    
    func removeCard(at index: Int) {
        guard index >= 0 else { return }
        cards.remove(at: index)
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func swapCard(at index: Int){
        guard index >= 0 else { return }
        let abc = cards.remove(at: index)
        cards.insert(abc, at: 0)
    }
}


extension View{
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
