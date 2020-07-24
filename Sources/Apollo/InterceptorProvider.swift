import Foundation

// MARK: - Basic protocol

public protocol InterceptorProvider {
  
  /// Creates a new array of interceptors when called
  ///
  /// - Parameter operation: The operation to provide interceptors for
  func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor]
}

// MARK: - Default implementation for typescript codegen

public class LegacyInterceptorProvider: InterceptorProvider {
  
  private let client: URLSessionClient
  private let store: ApolloStore
  
  /// Designated initializer
  ///
  /// - Parameter client: The URLSession client to use. Defaults to the default setup.
  public init(client: URLSessionClient = URLSessionClient(),
              store: ApolloStore) {
    self.client = client
    self.store = store
  }

  public func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
      return [
        LegacyCacheReadInterceptor(store: self.store),
        NetworkFetchInterceptor(client: self.client),
        ResponseCodeInterceptor(),
        LegacyParsingInterceptor(),
        FinalizingInterceptor(),
    ]
  }
}

// MARK: - Default implementation for swift codegen

public class CodableInterceptorProvider<FlexDecoder: FlexibleDecoder>: InterceptorProvider {
  
  private let client: URLSessionClient
  private let store: ApolloStore
  
  private let decoder: FlexDecoder
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - client: The URLSessionClient to use. Defaults to the default setup.
  ///   - decoder: A `FlexibleDecoder` which can decode `Codable` objects.
  public init(client: URLSessionClient = URLSessionClient(),
              store: ApolloStore,
              decoder: FlexDecoder) {
    self.client = client
    self.store = store
    self.decoder = decoder
  }

  public func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
       return [
         NetworkFetchInterceptor(client: self.client),
         ResponseCodeInterceptor(),
         CodableParsingInterceptor(decoder: self.decoder),
         FinalizingInterceptor(),
     ]
   }
}
