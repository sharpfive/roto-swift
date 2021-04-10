public struct PlayerKeeperPrice: FullNameHaving {
    public let name: String
    public let keeperPrice: Int

    public var fullName: String {
        return name
    }
}
