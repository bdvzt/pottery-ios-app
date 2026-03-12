import Foundation

enum URLRequestBuilder {
    static func build(from endpoint: EndPoint) throws -> URLRequest {
        let safePath =
            endpoint.path.hasPrefix("/")
            ? String(endpoint.path.dropFirst())
            : endpoint.path

        let url = endpoint.baseURL.appendingPathComponent(safePath)

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        if request.value(forHTTPHeaderField: HTTPHeader.accept) == nil {
            request.setValue(HTTPHeaderValue.json, forHTTPHeaderField: HTTPHeader.accept)
        }

        switch endpoint.task {
        case .request:
            break

        case .requestBody(let data):
            do {
                request.httpBody = try JSONEncoder().encode(data)

                if request.value(forHTTPHeaderField: HTTPHeader.contentType) == nil {
                    request.setValue(
                        HTTPHeaderValue.json,
                        forHTTPHeaderField: HTTPHeader.contentType
                    )
                }

                if request.value(forHTTPHeaderField: HTTPHeader.accept) == nil {
                    request.setValue(HTTPHeaderValue.json, forHTTPHeaderField: HTTPHeader.accept)
                }
            }
            catch is EncodingError {
                throw NetworkError.encodingFailed
            }
            catch {
                throw NetworkError.transportError(underlying: error)
            }

        case .requestUrlParameters(let parameters):
            request.url = try addQuery(parameters, to: request.url)
        }

        return request
    }
}

// MARK: - Helpers
private extension URLRequestBuilder {
    static func addQuery(_ parameters: Parameters, to url: URL?) throws -> URL {
        guard let url else {
            throw NetworkError.invalidURL
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        var items = components.queryItems ?? []

        for (key, value) in parameters {
            let string = String(describing: value)
            items.append(URLQueryItem(name: key, value: string))
        }

        components.queryItems = items

        guard let newURL = components.url else {
            throw NetworkError.invalidURL
        }

        return newURL
    }
}
