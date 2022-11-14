//
//  ContentView.swift
//  LoopCaregiver
//
//  Created by Bill Gestrich on 11/12/22.
//

import SwiftUI
import NightscoutClient
import Charts

struct ContentView: View {
    
    @State var currentEGV: NightscoutEGV?

    
    //TODO: Move these to some kind of credential structure - maybe save to secure preferences.
    static let nightscoutURL = URL(string: "")!
    static let nightscoutSecret = ""
//    static let nowDate: () -> Date = {Date().addingTimeInterval(-60*60*16)}
    static let nowDate: () -> Date = {Date()}
    
    let nightscoutService = NightscoutService(baseURL: Self.nightscoutURL, secret: Self.nightscoutSecret, referenceDate: Self.nowDate())
    
    var body: some View {
        VStack {
            HStack {
                Text(formattedEGVValue())
                    .font(.largeTitle)
                    .foregroundColor(egvValueColor())
                    .padding()
                Spacer()
            }
            Spacer()
            TreatmentGraph(nightscoutClient: nightscoutService, nowDate: Self.nowDate)
            Spacer()
            ActionsView(nightscoutService: nightscoutService)
        }
        .onAppear(perform: {
            Task {
                try await updateData()
            }
        })
    }
    
    func egvValueColor() -> Color {
        if let currentEGV = currentEGV {
            return ColorType(egvValue: currentEGV.value).color
        } else {
            return .black
        }
    }
    
    func formattedEGVValue() -> String {
        if let currentEGV {
            return String(currentEGV.value)
        } else {
            return "--"
        }
    }
    
    func updateData() async throws {
        if let egv = try await fetchLatestEGV() {
            currentEGV = egv
        }
    }
    
    func fetchLatestEGV() async throws -> NightscoutEGV? {
        let minutesLookback = -30.0
        let startDate = Self.nowDate().addingTimeInterval(60 * minutesLookback)
        return try await nightscoutService.getEGVs(startDate:  startDate, endDate:nil)
            .sorted(by: {$0.displayTime < $1.displayTime})
            .last
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
