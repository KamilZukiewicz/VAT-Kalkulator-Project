//
//  CalcViewModel.swift
//  VAT Kalkulator
//
//  Created by Kamil Żukiewicz on 26/08/2025.
//

import SwiftUI

class CalcViewModel: ObservableObject {
    
    @Published private var netto: Double?
    @Published private var brutto: Double?
    @Published private var vat: Double?
    
    
    
    func calculateNetto(brutto: Double, vat: Double) -> Double {
        return brutto / (1 + vat)
    }
    func calculateBrutto(netto: Double, vat: Double) -> Double {
        return netto * (1 + vat)
    }
    func calculateVat(netto: Double, brutto: Double) -> Double {
        return (brutto - netto) / netto
    }
}
