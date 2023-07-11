//
//  AnyStateObject.swift
//  MajorDom
//
//  Created by Mark Parker on 18/06/2023.
//

import SwiftUI
import Combine

/**.
 Property wrapper that is similar to SwiftUI's StateObject, but without compile-time type restrictions.
 The lack of compile-time restrictions means that `ObjectType` may be a protocol rather than a class.
 
 - Important: At runtime, the wrapped value must conform to ``AnyObservableObject``.
 */
@available(macOS 11.0, *)
@propertyWrapper
public struct AnyStateObject<ObjectType>: DynamicProperty {
    
    @StateObject private var stateObject: ErasedStateObject

    public var wrappedValue: ObjectType {
        stateObject.wrappedObject as! ObjectType
    }
    
    /// A projected value which has the same properties as the wrapped value, but presented as bindings.
    public var projectedValue: Wrapper {
        return Wrapper(self)
    }
    
    /// Create a stored value which publishes on the main thread.
    public init(wrappedValue: ObjectType) {
        
        if let observable = wrappedValue as? AnyObservableObject {
            
            let objectWillChange = observable.objectWillChange
                .eraseToAnyPublisher()
            
            self._stateObject = StateObject(wrappedValue: ErasedStateObject(wrappedObject: wrappedValue, objectWillChange: objectWillChange))
            
        } else {
            assertionFailure(
                "Only use the Presenter property wrapper with objects conforming to AnyObservableObject."
            )
            self._stateObject = StateObject(wrappedValue: .mock)
        }
    }
    
    /// An equivalent to SwiftUI's [`StateObject.Wrapper`] type
    @dynamicMemberLookup
    public struct Wrapper {
        private var presenter: AnyStateObject
        
        internal init(_ presenter: AnyStateObject<ObjectType>) {
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
    
    internal class ErasedStateObject: ObservableObject {
        
        let wrappedObject: Any
        let objectWillChange: AnyPublisher<Void, Never>
        
        init(wrappedObject: Any, objectWillChange: AnyPublisher<Void, Never>) {
            self.wrappedObject = wrappedObject
            self.objectWillChange = objectWillChange
        }
        
        static var mock: ErasedStateObject {
            .init(wrappedObject: AnyMock(), objectWillChange: Empty().eraseToAnyPublisher())
        }
        
        private class AnyMock {}
    }
}
