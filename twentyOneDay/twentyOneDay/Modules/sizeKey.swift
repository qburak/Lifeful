//
//  sizeKey.swift
//  twentyOneDay
//
//  Created by Burak on 3.09.2023.
//

import SwiftUI

struct sizeKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


