//
//  AnyObservableObject.swift
//  MajorDom
//
//  Created by Mark Parker on 18/06/2023.
//

import SwiftUI
import Combine

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public protocol AnyObservableObject: AnyObject {
    var objectWillChange: ObservableObjectPublisher { get }
}
