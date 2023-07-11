//
//  AnyObservedObject.swift
//  MajorDom
//
//  Created by Mark Parker on 18/06/2023.
//

import SwiftUI
import Combine

/**.
 Property wrapper that is similar to SwiftUI's ObservedObject, but without compile-time type restrictions.
 The lack of compile-time restrictions means that `ObjectType` may be a protocol rather than a class.
 
 - Important: At runtime, the wrapped value must conform to ``AnyObservableObject``.
 */
@available(macOS 11.0, *)
@propertyWrapper
public struct AnyObservedObject<ObjectType>: DynamicProperty {
    
    /// The underlying object being stored.
    public let wrappedValue: ObjectType
    
    fileprivate var _observableObject: ObservedObject<ErasedObservableObject>
    
    @MainActor internal var observableObject: ErasedObservableObject {
        return _observableObject.wrappedValue
    }
    
    /// A projected value which has the same properties as the wrapped value, but presented as bindings.
    public var projectedValue: Wrapper {
        return Wrapper(self)
    }
    
    /// Create a stored value which publishes on the main thread.
    public init(wrappedValue: ObjectType) {
        self.wrappedValue = wrappedValue
        
        if let observable = wrappedValue as? AnyObservableObject {
            let objectWillChange = observable.objectWillChange
                .eraseToAnyPublisher()
            self._observableObject = ObservedObject(initialValue: ErasedObservableObject(objectWillChange: objectWillChange))
        } else {
            assertionFailure(
                "Only use the Presenter property wrapper with objects conforming to AnyObservableObject."
            )
            self._observableObject = ObservedObject(initialValue: .mock)
        }
    }
    
    /// An equivalent to SwiftUI's `ObservedObject.Wrapper`type.
    @dynamicMemberLookup
    public struct Wrapper {
        private var presenter: AnyObservedObject
        
        internal init(_ presenter: AnyObservedObject<ObjectType>) {
            self.presenter = presenter
        }
        
        /// Returns a binding to the resulting value of a given key path.
        public subscript<Subject>(
            dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Subject>
        ) -> Binding<Subject> {
            return Binding {
                self.presenter.wrappedValue[keyPath: keyPath]
            } set: {
                self.presenter.wrappedValue[keyPath: keyPath] = $0
            }
        }
    }
    
    internal class ErasedObservableObject: ObservableObject {
        
        let objectWillChange: AnyPublisher<Void, Never>
        
        init(objectWillChange: AnyPublisher<Void, Never>) {
            self.objectWillChange = objectWillChange
        }
        
        static var mock: ErasedObservableObject {
            ErasedObservableObject(objectWillChange: Empty().eraseToAnyPublisher())
        }
    }
    
    public nonisolated mutating func update() {
        _observableObject.update()
    }
}
