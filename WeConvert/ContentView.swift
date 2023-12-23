//
//  ContentView.swift
//  WeConvert
//
//  Created by ramsayleung on 2023-12-22.
//

import SwiftUI

protocol ConversionUnit: Hashable {
    func convertToBaseUnit(value: Double) -> Double
    func convertFromBaseUnit(value: Double) -> Double
}

enum ConversionType: String, CaseIterable {
    case Temperature
    case Length
    case Time
    case Volume
}

enum TemperatureUnit: String, CaseIterable, ConversionUnit {
    case Celsius
    case Fahrenheit
    case Kelvin
    
    static var allCasesString: [String] {
        TemperatureUnit.allCases.map { "\($0)" }
    }

    func convertToBaseUnit(value: Double) -> Double {
        switch self {
        case .Celsius:
            return value
        case .Fahrenheit:
            return (value - 32.0) * (5.0 / 9.0)
        case .Kelvin:
            return value - 273.15
        }
    }
    
    func convertFromBaseUnit(value: Double) -> Double {
        switch self {
        case .Celsius:
            return value
        case .Fahrenheit:
            return (value * (9.0 / 5.0)) + 32.0
        case .Kelvin:
            return value + 273.15
        }
    }
}

enum LengthUnit: String, CaseIterable, ConversionUnit {
    case Meter
    case KiloMeter
    case Feet
    case Yard
    case Mile
    
    static var allCasesString: [String] {
        LengthUnit.allCases.map { "\($0)" }
    }
    
    func convertToBaseUnit(value: Double) -> Double {
        switch self {
        case .Meter:
            return value
        case .KiloMeter:
            return value * 1000.0
        case .Feet:
            return value * 0.3048
        case .Yard:
            return value * 0.9144
        case .Mile:
            return value * 1609.34
        }
    }
    
    func convertFromBaseUnit(value: Double) -> Double {
        switch self {
        case .Meter:
            return value
        case .KiloMeter:
            return value / 1000.0
        case .Feet:
            return value / 0.3048
        case .Yard:
            return value / 0.9144
        case .Mile:
            return value / 1609.34
        }
    }
}

enum TimeUnit: String, CaseIterable, ConversionUnit {
    case Second
    case Minute
    case Hour
    case Day
    
    static var allCasesString: [String] {
        TimeUnit.allCases.map { "\($0)" }
    }
    
    func convertToBaseUnit(value: Double) -> Double {
        switch self {
        case .Second:
            return value
        case .Minute:
            return value * 60.0
        case .Hour:
            return value * 3600.0
        case .Day:
            return value * 86400.0
        }
    }
    
    func convertFromBaseUnit(value: Double) -> Double {
        switch self {
        case .Second:
            return value
        case .Minute:
            return value / 60.0
        case .Hour:
            return value / 3600.0
        case .Day:
            return value / 86400.0
        }
    }
}

enum VolumeUnit: String, CaseIterable, ConversionUnit {
    case Milliliter
    case Liter
    case Cup
    case Pint
    case Gallon
    
    static var allCasesString: [String] {
        VolumeUnit.allCases.map { "\($0)" }
    }
    
    func convertToBaseUnit(value: Double) -> Double {
        switch self {
        case .Milliliter:
            return value
        case .Liter:
            return value * 1000.0
        case .Cup:
            return value * 236.588
        case .Pint:
            return value * 473.176
        case .Gallon:
            return value * 3785.41
        }
    }
    
    func convertFromBaseUnit(value: Double) -> Double {
        switch self {
        case .Milliliter:
            return value
        case .Liter:
            return value / 1000.0
        case .Cup:
            return value / 236.588
        case .Pint:
            return value / 473.176
        case .Gallon:
            return value / 3785.41
        }
    }
}

func convert(value: Double, fromUnit: any ConversionUnit, toUnit: any ConversionUnit) -> Double {
    return toUnit.convertFromBaseUnit(value: fromUnit.convertToBaseUnit(value: value))
}

struct ContentView: View {
    @State private var selectType: ConversionType = .Temperature
    @State private var inputUnit: String = TemperatureUnit.Celsius.rawValue
    @State private var outputUnit: String = TemperatureUnit.Fahrenheit.rawValue
    @State private var inputValue = 0.0
    @FocusState private var amountIsFocused: Bool
    
    var outputUnits: [String] {
        var outputUnits = inputUnits
        outputUnits.removeAll{$0 == inputUnit}
        return outputUnits
    }
    
    var inputUnits: [String]{
        return typeUnitMap[selectType] ?? TemperatureUnit.allCasesString
    }
    
    var convertedValue: Double {
        var fromUnit: (any ConversionUnit)?
        var toUnit: (any ConversionUnit)?
        print("inputUnit: \(inputUnit), output: \(outputUnit)")
        switch selectType {
        case .Temperature:
            fromUnit = TemperatureUnit(rawValue: inputUnit)
            toUnit = TemperatureUnit(rawValue: outputUnit)
        case .Length:
            fromUnit = LengthUnit(rawValue: inputUnit)
            toUnit = LengthUnit(rawValue: outputUnit)
        case .Time:
            fromUnit = TimeUnit(rawValue: inputUnit)
            toUnit = TimeUnit(rawValue: outputUnit)
        case .Volume:
            fromUnit = VolumeUnit(rawValue: inputUnit)
            toUnit = VolumeUnit(rawValue: outputUnit)
        }
        if let fromUnit = fromUnit{
            if let toUnit = toUnit{
                return convert(value: inputValue, fromUnit: fromUnit, toUnit: toUnit)
            }
        }
        return inputValue
    }
    let typeUnitMap: [ConversionType: [String]] = [ConversionType.Temperature: TemperatureUnit.allCasesString, ConversionType.Length: LengthUnit.allCasesString, ConversionType.Time: TimeUnit.allCasesString, ConversionType.Volume: VolumeUnit.allCasesString]
    var body: some View {
        NavigationStack{
            Form{
                Section("Select your conversion type"){
                    Picker("Conversion type", selection: $selectType){
                        ForEach(ConversionType.allCases, id: \.self){ type in
                            Text(type.rawValue)
                        }
                    }.pickerStyle(.segmented)
                }
                Section("Select your unit"){
                    Picker("Input Unit", selection: $inputUnit){
                        ForEach(inputUnits, id: \.self){
                            Text($0)
                        }
                    }.pickerStyle(.segmented)
                    
                    Picker("Output Unit", selection: $outputUnit){
                        ForEach(outputUnits, id: \.self){
                            Text($0)
                        }
                    }.pickerStyle(.segmented)
                }
                Section("The number you want to convert"){
                    TextField("Amount", value: $inputValue, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($amountIsFocused)
                }
                Section("The Result of conversion:"){
                    Text(convertedValue, format: .number)
                }
            }.navigationTitle("WeConvert")
                .toolbar{
                    if amountIsFocused{
                        Button("Done"){
                            amountIsFocused.toggle()
                        }
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
