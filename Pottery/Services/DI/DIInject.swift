import Foundation

@propertyWrapper public struct DIInject<Service, Container> {
    public let wrappedValue: Service

    public init(_ keyPath: KeyPath<Container, Service>, container: Container) {
        self.wrappedValue = container[keyPath: keyPath]
    }
}
