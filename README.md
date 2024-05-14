# AnyObservableObject
Equivalents to SwiftUI's property wrappers but without compile-time type restrictions. The lack of compile-time restrictions means that you don't need generics if you defined type as a protocol.

You can find examples in the [MarkParker5/TwiTreads](https://github.com/MarkParker5/TwiTreads) project.

If you're considering using protocols in SwiftUI Views, there's an important consideration to keep in mind. Since View in SwiftUI is a structure, it requires explicit specification of its property types. This means you'll need to make it a generic structure and pass the type through all the call stack, resulting in a lot of boilerplate code.

However, there's an alternative approach offered by MarkParker5/AnyObservableObject. This library works similarly to native SwiftUI property wrappers but removes the compile-time type check in favor of a runtime one. This means you can use protocols in views without making the struct generic and without explicit type specification! While this approach may introduce some risks, they are easily mitigated by writing elementary Xcode tests that simply instantiate the views in the same way you do it at runtime.

By using this alternative, you can simplify your code and streamline the process of working with protocols in SwiftUI Views.
