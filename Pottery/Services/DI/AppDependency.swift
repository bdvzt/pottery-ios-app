@MainActor enum DI {
    static var container: AppDependency = AppDependency.build()
}

@MainActor
struct AppDependency {

    static func build() -> AppDependency {

        return AppDependency(
        )
    }
}
