//
//  SideButtons.swift
//  WalkTracker
//
//  Created by Ole on 09.10.26.
//

import SwiftUI

struct SideButtons: View {
    @Binding var isHistoryPresented: Bool
    @Binding var isQuestLogPresent: Bool
    @Binding var visualizeHeatMap: Bool
    @State var creatingQuest = false
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Button {
                    visualizeHeatMap.toggle()
                } label: {
                    Image(systemName: visualizeHeatMap ? "shield" : "shield.slash")
                        .font(.system(size: 18))
                        .frame(width: 30, height: 20)
                }
                .buttonStyle(.glass)
                
                Button {
                    isQuestLogPresent = true
                } label: {
                    Image(systemName: "flag.2.crossed")
                        .font(.system(size: 18))
                        .frame(width: 30, height: 20)
                }
                .buttonStyle(.glass)
                
                Button {
                    isHistoryPresented = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 18))
                        .frame(width: 30, height: 20)
                }
                .buttonStyle(.glass)
            }
        }
    }
}

