//
//  ContentView.swift
//  VAT Kalkulator
//
//  Created by Kamil Żukiewicz on 26/08/2025.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var calcViewModel = CalcViewModel()
    
    @FocusState private var isFocused: Bool
    
    @State private var bruttoShow: String = ""
    @State private var nettoShow: String = ""
    @State private var vatShow: String = ""
    @State private var choiseVat: VatRate = .twentyThree
    
    @State private var activeField: ShowTextfield = .bruttoShow
    
    enum ShowTextfield: String, CaseIterable, Identifiable {
        case bruttoShow, nettoShow, vatShow
        var id: String { rawValue }
        var title: String {
            switch self {
            case .bruttoShow: return "Brutto"
            case .nettoShow: return "Netto"
            case .vatShow: return "VAT (kwota)"
            }
        }
    }
    
    enum VatRate: Double, CaseIterable, Identifiable {
        case zero = 0
        case five = 0.05
        case eight = 0.08
        case twentyThree = 0.23
        var id: Self { self }
        var label: String {
            switch self {
            case .zero: return "0%"
            case .five: return "5%"
            case .eight: return "8%"
            case .twentyThree: return "23%"
            }
        }
    }
    
    private enum KeyStyle {
        case `default`
        case accent
        case destructive
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 10/255, green: 37/255, blue: 64/255),
                    Color(red: 13/255, green: 71/255, blue: 161/255),
                    Color(red: 66/255, green: 165/255, blue: 245/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                fieldView(title: "Brutto", text: $bruttoShow, field: .bruttoShow)
                fieldView(title: "Netto", text: $nettoShow, field: .nettoShow)
                fieldView(title: "VAT (kwota)", text: $vatShow, field: .vatShow)
                
                vatRatePicker
                
                keypad
            }
            .padding()
        }
        .onAppear {
            activeField = .bruttoShow
        }
    }
    
    private func fieldView(title: String, text: Binding<String>, field: ShowTextfield) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
            TextField(title, text: text)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .disabled(true)
                .overlay {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            activeField = field
                        }
                }
                .overlay(alignment: .trailing) {
                    if activeField == field {
                        Circle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .padding(.trailing, 8)
                    }
                }
        }
    }
    
    private var vatRatePicker: some View {
        HStack(spacing: 12) {
            ForEach(VatRate.allCases) { rate in
                Button(rate.label) {
                    choiseVat = rate
                    recomputeBasedOnActiveField()
                }
                .buttonStyle(.bordered)
                .tint(choiseVat == rate ? .white : .white.opacity(0.35))
                .foregroundStyle(choiseVat == rate ? .black : .white)
            }
        }
    }
    
    private var keypad: some View {
        VStack(spacing: 10) {
           
            HStack(spacing: 10) {
                key("1"); key("2"); key("3");
            }
            HStack(spacing: 10) {
                key("4"); key("5"); key("6");
            }
            HStack(spacing: 10) {
                key("7"); key("8"); key("9");
            }
            HStack(spacing: 10) {
                key(",", action: { append(",") }); key("0"); key("⌫", style: .destructive, action: backspace);
            }
        }
    }
    
    @ViewBuilder
    private func key(_ label: String, wide: Bool = false, style: KeyStyle = .default, action: (() -> Void)? = nil) -> some View {
        Button {
            if let action {
                action()
            } else {
                append(label)
            }
        } label: {
            Text(label)
                .font(.title2)
                .frame(maxWidth: wide ? .infinity : 64, minHeight: 48)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 10))
        .tint(tintColor(for: style))
        .foregroundStyle(style == .destructive ? .black : .black)
        .frame(maxWidth: wide ? .infinity : nil)
    }
    
    private func tintColor(for style: KeyStyle) -> Color {
        switch style {
        case .destructive: return .white.opacity(0.8)
        case .accent: return .white
        case .default: return .white.opacity(0.65)
        }
    }
    
    
    private func append(_ symbol: String) {
        switch symbol {
        case "0"..."9":
            writeToActiveField(symbol)
        case ",":
            let current = getActiveFieldText()
            if !current.contains(",") {
                writeToActiveField(current.isEmpty ? "0," : ",")
            }
        default:
            break
        }
        recomputeBasedOnActiveField()
    }
    
    private func backspace() {
        var current = getActiveFieldText()
        if !current.isEmpty {
            current.removeLast()
            setActiveFieldText(current)
            recomputeBasedOnActiveField()
        }
    }
    
    private func clearActiveField() {
        setActiveFieldText("")
        switch activeField {
        case .bruttoShow:
            nettoShow = ""
            vatShow = ""
        case .nettoShow:
            bruttoShow = ""
            vatShow = ""
        case .vatShow:
            bruttoShow = ""
            nettoShow = ""
        }
    }
    
    private func writeToActiveField(_ addition: String) {
        var current = getActiveFieldText()
        current.append(addition)
        setActiveFieldText(current)
    }
    
    private func getActiveFieldText() -> String {
        switch activeField {
        case .bruttoShow: return bruttoShow
        case .nettoShow: return nettoShow
        case .vatShow: return vatShow
        }
    }
    
    private func setActiveFieldText(_ text: String) {
        switch activeField {
        case .bruttoShow: bruttoShow = text
        case .nettoShow: nettoShow = text
        case .vatShow: vatShow = text
        }
    }
    
    private func normalize(_ text: String) -> String {
        text.replacingOccurrences(of: ",", with: ".")
    }
    
    private func recomputeBasedOnActiveField() {
        switch activeField {
        case .bruttoShow:
            computeFromBrutto()
        case .nettoShow:
            computeFromNetto()
        case .vatShow:
            computeFromVatAmount()
        }
    }
    
    private func computeFromBrutto() {
        let normalized = normalize(bruttoShow)
        guard let brutto = Double(normalized), brutto >= 0 else {
            nettoShow = ""
            vatShow = ""
            return
        }
        let netto = calcViewModel.calculateNetto(brutto: brutto, vat: choiseVat.rawValue)
        let vatAmount = brutto - netto
        nettoShow = String(format: "%.2f", netto)
        vatShow = String(format: "%.2f", vatAmount)
    }
    
    private func computeFromNetto() {
        let normalized = normalize(nettoShow)
        guard let netto = Double(normalized), netto >= 0 else {
            bruttoShow = ""
            vatShow = ""
            return
        }
        let brutto = calcViewModel.calculateBrutto(netto: netto, vat: choiseVat.rawValue)
        let vatAmount = brutto - netto
        bruttoShow = String(format: "%.2f", brutto)
        vatShow = String(format: "%.2f", vatAmount)
    }
    
    private func computeFromVatAmount() {
        let normalized = normalize(vatShow)
        guard let vatAmount = Double(normalized), vatAmount >= 0 else {
            bruttoShow = ""
            nettoShow = ""
            return
        }
        let rate = choiseVat.rawValue
        if rate > 0 {
            let netto = vatAmount / rate
            let brutto = netto * (1 + rate)
            nettoShow = String(format: "%.2f", netto)
            bruttoShow = String(format: "%.2f", brutto)
        } else {
            bruttoShow = ""
            nettoShow = ""
        }
    }
}

#Preview {
    ContentView()
}
