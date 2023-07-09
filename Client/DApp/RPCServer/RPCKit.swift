//
//  RPCKit.swift
//  dApp
//
//  Created by Ashok on 09/07/23.
//
import Foundation
import Dispatch
import Result

 protocol Request {
    associatedtype Response
    
    var method: String { get }
    var parameters: Any? { get }
    var extendedFields: [String: Any]? { get }
    var isNotification: Bool { get }
    
    func response(from resultObject: Any) throws -> Response
}

 extension Request {
    var parameters: Any? {
        return nil
    }

     var extendedFields: [String: Any]? {
        return nil
    }

     var isNotification: Bool {
        return false
    }
}

 extension Request where Response == Void {
     var isNotification: Bool {
        return true
    }

     func response(from resultObject: Any) throws -> Response {
        return ()
    }
}

protocol Batch {
    associatedtype Responses
    associatedtype Results

    var requestObject: Any { get }

    func responses(from object: Any) throws -> Responses
    func results(from object: Any) -> Results

    static func responses(from results: Results) throws -> Responses
}

 struct Batch1<Request1: Request>: Batch {
     typealias Responses = Request1.Response
      typealias Results = Result<Request1.Response, JSONRPCError>

      let batchElement: BatchElement<Request1>
    
      var requestObject: Any {
        return batchElement.body
    }

      func responses(from object: Any) throws -> Responses {
        return try batchElement.response(from: object)
    }

      func results(from object: Any) -> Results {
        return batchElement.result(from: object)
    }

      static func responses(from results: Results) throws -> Responses {
        return try results.dematerialize()
    }
}

 struct Batch2<Request1: Request, Request2: Request>: Batch {
      typealias Responses = (Request1.Response, Request2.Response)
      typealias Results = (Result<Request1.Response, JSONRPCError>, Result<Request2.Response, JSONRPCError>)

      let batchElement1: BatchElement<Request1>
      let batchElement2: BatchElement<Request2>

      var requestObject: Any {
        return [
            batchElement1.body,
            batchElement2.body,
        ]
    }

      func responses(from object: Any) throws -> Responses {
        guard let batchObjects = object as? [Any] else {
            throw JSONRPCError.nonArrayResponse(object)
        }

        return (
            try batchElement1.response(from: batchObjects),
            try batchElement2.response(from: batchObjects)
        )
    }

      func results(from object: Any) -> Results {
        guard let batchObjects = object as? [Any] else {
            return (
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object))
            )
        }

        return (
            batchElement1.result(from: batchObjects),
            batchElement2.result(from: batchObjects)
        )
    }

      static func responses(from results: Results) throws -> Responses {
        return (
            try results.0.dematerialize(),
            try results.1.dematerialize()
        )
    }
}

struct Batch3<Request1: Request, Request2: Request, Request3: Request>: Batch {
      typealias Responses = (Request1.Response, Request2.Response, Request3.Response)
      typealias Results = (Result<Request1.Response, JSONRPCError>, Result<Request2.Response, JSONRPCError>, Result<Request3.Response, JSONRPCError>)

      let batchElement1: BatchElement<Request1>
      let batchElement2: BatchElement<Request2>
      let batchElement3: BatchElement<Request3>

      var requestObject: Any {
        return [
            batchElement1.body,
            batchElement2.body,
            batchElement3.body,
        ]
    }

      func responses(from object: Any) throws -> Responses {
        guard let batchObjects = object as? [Any] else {
            throw JSONRPCError.nonArrayResponse(object)
        }

        return (
            try batchElement1.response(from: batchObjects),
            try batchElement2.response(from: batchObjects),
            try batchElement3.response(from: batchObjects)
        )
    }

      func results(from object: Any) -> Results {
        guard let batchObjects = object as? [Any] else {
            return (
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object))
            )
        }

        return (
            batchElement1.result(from: batchObjects),
            batchElement2.result(from: batchObjects),
            batchElement3.result(from: batchObjects)
        )
    }

      static func responses(from results: Results) throws -> Responses {
        return (
            try results.0.dematerialize(),
            try results.1.dematerialize(),
            try results.2.dematerialize()
        )
    }
}

 struct Batch4<Request1: Request, Request2: Request, Request3: Request, Request4: Request>: Batch {
      typealias Responses = (Request1.Response, Request2.Response, Request3.Response, Request4.Response)
      typealias Results = (Result<Request1.Response, JSONRPCError>, Result<Request2.Response, JSONRPCError>, Result<Request3.Response, JSONRPCError>, Result<Request4.Response, JSONRPCError>)

      let batchElement1: BatchElement<Request1>
      let batchElement2: BatchElement<Request2>
      let batchElement3: BatchElement<Request3>
      let batchElement4: BatchElement<Request4>

      var requestObject: Any {
        return [
            batchElement1.body,
            batchElement2.body,
            batchElement3.body,
            batchElement4.body,
        ]
    }

      func responses(from object: Any) throws -> Responses {
        guard let batchObjects = object as? [Any] else {
            throw JSONRPCError.nonArrayResponse(object)
        }

        return (
            try batchElement1.response(from: batchObjects),
            try batchElement2.response(from: batchObjects),
            try batchElement3.response(from: batchObjects),
            try batchElement4.response(from: batchObjects)
        )
    }

      func results(from object: Any) -> Results {
        guard let batchObjects = object as? [Any] else {
            return (
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object))
            )
        }

        return (
            batchElement1.result(from: batchObjects),
            batchElement2.result(from: batchObjects),
            batchElement3.result(from: batchObjects),
            batchElement4.result(from: batchObjects)
        )
    }

      static func responses(from results: Results) throws -> Responses {
        return (
            try results.0.dematerialize(),
            try results.1.dematerialize(),
            try results.2.dematerialize(),
            try results.3.dematerialize()
        )
    }
}

  struct Batch5<Request1: Request, Request2: Request, Request3: Request, Request4: Request, Request5: Request>: Batch {
      typealias Responses = (Request1.Response, Request2.Response, Request3.Response, Request4.Response, Request5.Response)
      typealias Results = (Result<Request1.Response, JSONRPCError>, Result<Request2.Response, JSONRPCError>, Result<Request3.Response, JSONRPCError>, Result<Request4.Response, JSONRPCError>, Result<Request5.Response, JSONRPCError>)

      let batchElement1: BatchElement<Request1>
      let batchElement2: BatchElement<Request2>
      let batchElement3: BatchElement<Request3>
      let batchElement4: BatchElement<Request4>
      let batchElement5: BatchElement<Request5>

      var requestObject: Any {
        return [
            batchElement1.body,
            batchElement2.body,
            batchElement3.body,
            batchElement4.body,
            batchElement5.body,
        ]
    }

      func responses(from object: Any) throws -> Responses {
        guard let batchObjects = object as? [Any] else {
            throw JSONRPCError.nonArrayResponse(object)
        }

        return (
            try batchElement1.response(from: batchObjects),
            try batchElement2.response(from: batchObjects),
            try batchElement3.response(from: batchObjects),
            try batchElement4.response(from: batchObjects),
            try batchElement5.response(from: batchObjects)
        )
    }

      func results(from object: Any) -> Results {
        guard let batchObjects = object as? [Any] else {
            return (
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object))
            )
        }

        return (
            batchElement1.result(from: batchObjects),
            batchElement2.result(from: batchObjects),
            batchElement3.result(from: batchObjects),
            batchElement4.result(from: batchObjects),
            batchElement5.result(from: batchObjects)
        )
    }

      static func responses(from results: Results) throws -> Responses {
        return (
            try results.0.dematerialize(),
            try results.1.dematerialize(),
            try results.2.dematerialize(),
            try results.3.dematerialize(),
            try results.4.dematerialize()
        )
    }
}

  struct Batch6<Request1: Request, Request2: Request, Request3: Request, Request4: Request, Request5: Request, Request6: Request>: Batch {
      typealias Responses = (Request1.Response, Request2.Response, Request3.Response, Request4.Response, Request5.Response, Request6.Response)
      typealias Results = (Result<Request1.Response, JSONRPCError>, Result<Request2.Response, JSONRPCError>, Result<Request3.Response, JSONRPCError>, Result<Request4.Response, JSONRPCError>, Result<Request5.Response, JSONRPCError>, Result<Request6.Response, JSONRPCError>)

      let batchElement1: BatchElement<Request1>
      let batchElement2: BatchElement<Request2>
      let batchElement3: BatchElement<Request3>
      let batchElement4: BatchElement<Request4>
      let batchElement5: BatchElement<Request5>
      let batchElement6: BatchElement<Request6>

      var requestObject: Any {
        return [
            batchElement1.body,
            batchElement2.body,
            batchElement3.body,
            batchElement4.body,
            batchElement5.body,
            batchElement6.body,
        ]
    }

      func responses(from object: Any) throws -> Responses {
        guard let batchObjects = object as? [Any] else {
            throw JSONRPCError.nonArrayResponse(object)
        }

        return (
            try batchElement1.response(from: batchObjects),
            try batchElement2.response(from: batchObjects),
            try batchElement3.response(from: batchObjects),
            try batchElement4.response(from: batchObjects),
            try batchElement5.response(from: batchObjects),
            try batchElement6.response(from: batchObjects)
        )
    }

      func results(from object: Any) -> Results {
        guard let batchObjects = object as? [Any] else {
            return (
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object)),
                .failure(.nonArrayResponse(object))
            )
        }

        return (
            batchElement1.result(from: batchObjects),
            batchElement2.result(from: batchObjects),
            batchElement3.result(from: batchObjects),
            batchElement4.result(from: batchObjects),
            batchElement5.result(from: batchObjects),
            batchElement6.result(from: batchObjects)
        )
    }

      static func responses(from results: Results) throws -> Responses {
        return (
            try results.0.dematerialize(),
            try results.1.dematerialize(),
            try results.2.dematerialize(),
            try results.3.dematerialize(),
            try results.4.dematerialize(),
            try results.5.dematerialize()
        )
    }
}

protocol BatchElementProcotol {
    associatedtype Request1: Request

    var request: Request1{ get }
    var version: String { get }
    var id: Id? { get }
    var body: Any { get }

    func response(from: Any) throws -> Request1.Response
    func response(from: [Any]) throws -> Request1.Response

    func result(from: Any) -> Result<Request1.Response, JSONRPCError>
    func result(from: [Any]) -> Result<Request1.Response, JSONRPCError>
}

 extension BatchElementProcotol {
    /// - Throws: JSONRPCError
      func response(from object: Any) throws -> Request1.Response {
        switch result(from: object) {
        case .success(let response):
            return response

        case .failure(let error):
            throw error
        }
    }

    /// - Throws: JSONRPCError
      func response(from objects: [Any]) throws -> Request1.Response {
        switch result(from: objects) {
        case .success(let response):
            return response

        case .failure(let error):
            throw error
        }
    }

      func result(from object: Any) -> Result<Request1.Response, JSONRPCError> {
        guard let dictionary = object as? [String: Any] else {
            return .failure(.unexpectedTypeObject(object))
        }
        
        let receivedVersion = dictionary["jsonrpc"] as? String
        guard version == receivedVersion else {
            return .failure(.unsupportedVersion(receivedVersion))
        }

        guard id == dictionary["id"].flatMap(Id.init) else {
            return .failure(.responseNotFound(requestId: id, object: dictionary))
        }

        let resultObject = dictionary["result"]
        let errorObject = dictionary["error"]

        switch (resultObject, errorObject) {
        case (nil, let errorObject?):
            return .failure(JSONRPCError(errorObject: errorObject))

        case (let resultObject?, nil):
            do {
                return .success(try request.response(from: resultObject))
            } catch {
                return .failure(.resultObjectParseError(error))
            }

        default:
            return .failure(.missingBothResultAndError(dictionary))
        }
    }

      func result(from objects: [Any]) -> Result<Request1.Response, JSONRPCError> {
        let matchedObject = objects
              .compactMap { $0 as? [String: Any] }
            .filter { $0["id"].flatMap(Id.init) == id }
            .first

        guard let object = matchedObject else {
            return .failure(.responseNotFound(requestId: id, object: objects))
        }

        return result(from: object)
    }
}

 extension BatchElementProcotol where Request1.Response == Void {
      func response(_ object: Any) throws -> Request1.Response {
        return ()
    }

      func response(_ objects: [Any]) throws -> Request1.Response {
        return ()
    }

      func result(_ object: Any) -> Result<Request1.Response, JSONRPCError> {
        return .success(())
    }

      func result(_ objects: [Any]) -> Result<Request1.Response, JSONRPCError> {
        return .success(())
    }
}

  struct BatchElement<Request1: Request>: BatchElementProcotol {
      let request: Request1
      let version: String
      let id: Id?
      let body: Any

      init(request: Request1, version: String, id: Id) {
        let id: Id? = request.isNotification ? nil : id
        
        var body: [String: Any] = [
            "jsonrpc": version,
            "method": request.method,
        ]
        
        body["id"] = id?.value
        body["params"] = request.parameters
        
        request.extendedFields?.forEach { (key, value) in
            body[key] = value
        }

        self.request = request
        self.version = version
        self.id = id
        self.body = body
    }
}

public enum JSONRPCError: Error {
    case responseError(code: Int, message: String, data: Any?)
    case responseNotFound(requestId: Id?, object: Any)
    case resultObjectParseError(Error)
    case errorObjectParseError(Error)
    case unsupportedVersion(String?)
    case unexpectedTypeObject(Any)
    case missingBothResultAndError(Any)
    case nonArrayResponse(Any)

    public init(errorObject: Any) {
        enum ParseError: Error {
            case nonDictionaryObject(object: Any)
            case missingKey(key: String, errorObject: Any)
        }

        do {
            guard let dictionary = errorObject as? [String: Any] else {
                throw ParseError.nonDictionaryObject(object: errorObject)
            }
            
            guard let code = dictionary["code"] as? Int else {
                throw ParseError.missingKey(key: "code", errorObject: errorObject)
            }

            guard let message = dictionary["message"] as? String else {
                throw ParseError.missingKey(key: "message", errorObject: errorObject)
            }

            self = .responseError(code: code, message: message, data: dictionary["data"])
        } catch {
            self = .errorObjectParseError(error)
        }
    }
}

public protocol IdGenerator {

    mutating func next() -> Id
}

public enum Id {
    case number(Int)
    case string(Swift.String)
}

extension Id {
    
    public init?(value: Any) {
        switch value {
        case let number as Int:
            self = .number(number)
        case let string as Swift.String:
            self = .string(string)
        default:
            return nil
        }
    }
    
    public var value: Any {
        switch self {
        case .number(let number):
            return number as Any
        case .string(let string):
            return string as Any
        }
    }
}

extension Id: Hashable {
    
    public var hashValue: Int {
        switch self {
        case .number(let number):
            return number
        case .string(let string):
            return string.hashValue
        }
    }
}

public func ==(lhs: Id, rhs: Id) -> Bool {
    if case let (.number(left), .number(right)) = (lhs, rhs) {
        return left == right
    }
    
    if case let (.string(left), .string(right)) = (lhs, rhs) {
        return left == right
    }
    
    return false
}

  class BatchFactory {
     let version: String
     var idGenerator: IdGenerator

     let semaphore = DispatchSemaphore(value: 1)

     init(version: String = "2.0", idGenerator: IdGenerator = NumberIdGenerator()) {
        self.version = version
        self.idGenerator = idGenerator
    }

     func create<Request1: Request>(_ request: Request1) -> Batch1<Request1> {
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        let batchElement = BatchElement(request: request, version: version, id: idGenerator.next())
        semaphore.signal()

        return Batch1(batchElement: batchElement)
    }

     func create<Request1: Request, Request2: Request>(_ request1: Request1, _ request2: Request2) -> Batch2<Request1, Request2> {
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        let batchElement1 = BatchElement(request: request1, version: version, id: idGenerator.next())
        let batchElement2 = BatchElement(request: request2, version: version, id: idGenerator.next())
        semaphore.signal()

        return Batch2(batchElement1: batchElement1, batchElement2: batchElement2)
    }

     func create<Request1: Request, Request2: Request, Request3: Request>(_ request1: Request1, _ request2: Request2, _ request3: Request3) -> Batch3<Request1, Request2, Request3> {
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        let batchElement1 = BatchElement(request: request1, version: version, id: idGenerator.next())
        let batchElement2 = BatchElement(request: request2, version: version, id: idGenerator.next())
        let batchElement3 = BatchElement(request: request3, version: version, id: idGenerator.next())
        semaphore.signal()

        return Batch3(batchElement1: batchElement1, batchElement2: batchElement2, batchElement3: batchElement3)
    }
    
     func create<Request1: Request, Request2: Request, Request3: Request, Request4: Request>(_ request1: Request1, _ request2: Request2, _ request3: Request3, _ request4: Request4) -> Batch4<Request1, Request2, Request3, Request4> {
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        let batchElement1 = BatchElement(request: request1, version: version, id: idGenerator.next())
        let batchElement2 = BatchElement(request: request2, version: version, id: idGenerator.next())
        let batchElement3 = BatchElement(request: request3, version: version, id: idGenerator.next())
        let batchElement4 = BatchElement(request: request4, version: version, id: idGenerator.next())
        semaphore.signal()

        return Batch4(batchElement1: batchElement1, batchElement2: batchElement2, batchElement3: batchElement3, batchElement4: batchElement4)
    }
    
     func create<Request1: Request, Request2: Request, Request3: Request, Request4: Request, Request5: Request>(_ request1: Request1, _ request2: Request2, _ request3: Request3, _ request4: Request4, _ request5: Request5) -> Batch5<Request1, Request2, Request3, Request4, Request5> {
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        let batchElement1 = BatchElement(request: request1, version: version, id: idGenerator.next())
        let batchElement2 = BatchElement(request: request2, version: version, id: idGenerator.next())
        let batchElement3 = BatchElement(request: request3, version: version, id: idGenerator.next())
        let batchElement4 = BatchElement(request: request4, version: version, id: idGenerator.next())
        let batchElement5 = BatchElement(request: request5, version: version, id: idGenerator.next())
        semaphore.signal()

        return Batch5(batchElement1: batchElement1, batchElement2: batchElement2, batchElement3: batchElement3, batchElement4: batchElement4, batchElement5: batchElement5)
    }
    
     func create<Request1: Request, Request2: Request, Request3: Request, Request4: Request, Request5: Request, Request6: Request>(request1: Request1, _ request2: Request2, _ request3: Request3, _ request4: Request4, _ request5: Request5, _ request6: Request6) -> Batch6<Request1, Request2, Request3, Request4, Request5, Request6> {
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        let batchElement1 = BatchElement(request: request1, version: version, id: idGenerator.next())
        let batchElement2 = BatchElement(request: request2, version: version, id: idGenerator.next())
        let batchElement3 = BatchElement(request: request3, version: version, id: idGenerator.next())
        let batchElement4 = BatchElement(request: request4, version: version, id: idGenerator.next())
        let batchElement5 = BatchElement(request: request5, version: version, id: idGenerator.next())
        let batchElement6 = BatchElement(request: request6, version: version, id: idGenerator.next())
        semaphore.signal()

        return Batch6(batchElement1: batchElement1, batchElement2: batchElement2, batchElement3: batchElement3, batchElement4: batchElement4, batchElement5: batchElement5, batchElement6: batchElement6)
    }
}
 struct NumberIdGenerator: IdGenerator {
    
    private var currentId = 1

    public init() {}

    public mutating func next() -> Id {
        defer {
            currentId += 1
        }
        
        return .number(currentId)
    }
}
