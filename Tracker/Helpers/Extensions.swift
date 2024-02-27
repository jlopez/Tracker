//
//  Extensions.swift
//  Tracker
//
//  Created by Jesus Lopez on 2/23/24.
//

import SwiftUI


// https://stackoverflow.com/questions/59272801/swiftui-datepicker-binding-optional-date-valid-nil
public func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
