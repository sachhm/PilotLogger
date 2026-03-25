import Foundation

protocol NetworkServiceProtocol: Sendable {
    func fetch<T: Decodable & Sendable>(from url: URL) async throws -> T
}
