//
//  AnyObservableObject.swift
//  MajorDom
//
//  Created by Mark Parker on 18/06/2023.
//

import SwiftUI
import Combine

@available(macOS 11.0, *)
protocol AnyObservableObject: AnyObject {
    var objectWillChange: ObservableObjectPublisher { get }
}
