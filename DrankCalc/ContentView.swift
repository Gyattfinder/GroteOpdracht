//
//  ContentView.swift
//  DrankCalc
//
//  Created by Brent Hoozee on 24/04/2025.
//

import SwiftUI

enum Geslacht: String, CaseIterable, Identifiable {
    case man, vrouw
    
    var id: String { self.rawValue }
}

enum DrankSoort: String, CaseIterable, Identifiable {
    case bier, wijn, whiskey, wodka, rum, gin
    
    var id: String { self.rawValue }

    var standaardAlcoholPercentage: Double {
        switch self {
        case .bier: return 5.0
        case .wijn: return 12.0
        case .whiskey, .wodka, .rum, .gin: return 40.0
        }
    }

    var standaardVolumeML: Double {
        switch self {
        case .bier: return 330.0
        case .wijn: return 100.0
        case .whiskey, .wodka, .rum, .gin: return 35.0
        }
    }
}

struct ContentView: View {
    @State private var gewicht: String = ""
    @State private var lengte: String = ""
    @State private var leeftijd: String = ""
    @State private var geslacht: Geslacht = .man
    @State private var dranksoort: DrankSoort = .bier
    @State private var aantalDrankjes: String = ""
    @State private var ingevoerdPercentage: String = ""
    @State private var tijdSindsLaatsteDrankje: String = ""

    @State private var berekendeBMI: Double?
    @State private var berekendeBAC: Double?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Jouw gegevens")) {
                    TextField("Gewicht (kg)", text: $gewicht)
                        .keyboardType(.decimalPad)
                    TextField("Lengte (cm)", text: $lengte)
                        .keyboardType(.decimalPad)
                    TextField("Leeftijd", text: $leeftijd)
                        .keyboardType(.numberPad)
                    Picker("Geslacht", selection: $geslacht) {
                        ForEach(Geslacht.allCases) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Drankgegevens")) {
                    Picker("Dranksoort", selection: $dranksoort) {
                        ForEach(DrankSoort.allCases) { d in
                            Text(d.rawValue).tag(d)
                        }
                    }
                    TextField("Aantal drankjes", text: $aantalDrankjes)
                        .keyboardType(.numberPad)
                    TextField("Alcoholpercentage (optioneel)", text: $ingevoerdPercentage)
                        .keyboardType(.decimalPad)
                    TextField("Tijd sinds laatste drankje (in uren)", text: $tijdSindsLaatsteDrankje)
                        .keyboardType(.decimalPad)
                }

                Button("Bereken") {
                    if let gewichtDouble = Double(gewicht),
                       let lengteDouble = Double(lengte),
                       let aantal = Int(aantalDrankjes),
                       let _ = Int(leeftijd),
                       let tijd = Double(tijdSindsLaatsteDrankje) {

                        berekendeBMI = berekenBMI(gewicht: gewichtDouble, lengte: lengteDouble)
                        berekendeBAC = berekenBAC(gewicht: gewichtDouble, geslacht: geslacht, aantalDrankjes: aantal, dranksoort: dranksoort, ingevoerdPercentage: ingevoerdPercentage, tijdSindsLaatsteDrankje: tijd)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)

                if let bmi = berekendeBMI {
                    Text("Je BMI is: \(String(format: "%.2f", bmi))")
                }

                if let bac = berekendeBAC {
                    Text("Je geschatte BAC is: \(String(format: "%.3f", bac)) ‰")
                        .foregroundColor(bac >= 0.5 ? .red : .primary)

                    if bac >= 0.5 {
                        Text("Je bent boven de wettelijke limiet om te rijden in België (0.5‰).")
                            .foregroundColor(.red)
                    }
                }

                NavigationLink(destination: WetgevingView()) {
                    Text("Bekijk Belgische wetgeving")
                        .foregroundColor(.blue)
                }
            }.navigationBarTitle("Hoeveel tot?", displayMode: .inline)
        }
    }

    func berekenBMI(gewicht: Double, lengte: Double) -> Double {
        let lengteMeters = lengte / 100
        return gewicht / (lengteMeters * lengteMeters)
    }

    func berekenBAC(gewicht: Double, geslacht: Geslacht, aantalDrankjes: Int, dranksoort: DrankSoort, ingevoerdPercentage: String, tijdSindsLaatsteDrankje: Double) -> Double {
        let percentage: Double
        if let custom = Double(ingevoerdPercentage), custom > 0 {
            percentage = custom
        } else {
            percentage = dranksoort.standaardAlcoholPercentage
        }

        let volumeML = dranksoort.standaardVolumeML
        let alcoholGramPerDrank = volumeML * (percentage / 100.0) * 0.789

        let totaalAlcoholGram = Double(aantalDrankjes) * alcoholGramPerDrank
        let r = geslacht == .man ? 0.68 : 0.55
        let gewichtLBS = gewicht * 2.20462

        var bac = (totaalAlcoholGram * 5.14) / (gewichtLBS * r)


        bac -= (0.015 * tijdSindsLaatsteDrankje)
        return max(bac, 0.0)
    }
}

struct WetgevingView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Belgische Wetgeving (2025)")
                    .font(.title2)
                    .bold()
                Text("• Voor bestuurders van motorvoertuigen geldt een wettelijke limiet van 0.5‰ (promille).")
                Text("• Voor professionele chauffeurs en beginnende bestuurders: 0.2‰.")
                Text("• Alcoholcontroles worden frequent uitgevoerd op de weg.")
                Text("• Strafmaatregelen variëren van boetes tot rijverbod en gevangenisstraffen.")
            }
            .padding()
        }
        .navigationTitle("Wetgeving")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
