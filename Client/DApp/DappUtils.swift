// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit
import APIKit
import Combine
import BigInt
import CryptoSwift
import secp256k1
import PromiseKit

public enum RpcNodeRetryableRequestError: Error {
    //TODO move those that aren't retryable to a not-retryable version
    case possibleBinanceTestnetTimeout
    //TODO rate limited means we should retry after delay. Or maybe all retries should have a delay
    case rateLimited(server: RPCServer, domainName: String)
    case networkConnectionWasLost
    case invalidCertificate
    case requestTimedOut
    case invalidApiKey(server: RPCServer, domainName: String)
}


struct EtherServiceRequest<Batch1: Batch>: APIKit.Request {
   private let rpcURL: URL
   private let rpcHeaders: [String: String]
   private let batch: Batch1
   
    init(server: RPCServer, batch: Batch1) {
       self.batch = batch
       self.rpcURL = server.rpcURL
       self.rpcHeaders = server.rpcHeaders
   }
   
   init(rpcURL: URL, rpcHeaders: [String: String], batch: Batch1) {
       self.batch = batch
       self.rpcHeaders = rpcHeaders
       self.rpcURL = rpcURL
   }
   
   public typealias Response = Batch1.Responses
   
   public var baseURL: URL {
       return rpcURL
   }
   
   public var method: APIKit.HTTPMethod {
       return .post
   }
   
   public var path: String {
       return ""
   }
   
   public var parameters: Any? {
       return batch.requestObject
   }
   
   public var headerFields: [String: String] {
       return rpcHeaders
   }
   
   public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
       return try batch.responses(from: object)
   }
}

struct EthCallRequest: Request {
   public typealias Response = String

   let from: String?
   let to: String?
   let value: String?
   let data: String

   public init(from: String?, to: String?, value: String?, data: String) {
       self.from = from
       self.to = to
       self.value = value
       self.data = data
   }

   public var method: String {
       return "eth_call"
   }

   public var parameters: Any? {
       //Explicit type declaration to speed up build time. 160msec -> <100ms, as of Xcode 11.7
       var payload: [String: Any] = [
           "data": data
       ]
       if let to = to {
           payload["to"] = to
       }
       if let from = from {
           payload["from"] = from
       }
       if let value = value {
           payload["value"] = value
       }
       let results: [Any] = [
           payload,
           "latest",
       ]
       return results
   }

   public func response(from resultObject: Any) throws -> Response {
       if let response = resultObject as? Response {
           return response
       } else {
           throw CastError(actualValue: resultObject, expectedType: Response.self)
       }
   }
}

public struct CastError<ExpectedType>: LocalizedError {
   let actualValue: Any
   let expectedType: ExpectedType.Type

   public init(actualValue: Any, expectedType: ExpectedType.Type) {
       self.actualValue = actualValue
       self.expectedType = expectedType
   }

   public var errorDescription: String? {
       return "Decode failure: Unable to decode value of \(actualValue) to expected type \(String(describing: expectedType))"
   }
}
extension RPCServer {
   public var rpcHeaders: RPCNodeHTTPHeaders {
       return .init()
   }
   
   func makeMaximumToBlockForEvents(fromBlockNumber: UInt64) -> EventFilter.Block {
       if let maxRange = maximumBlockRangeForEvents {
           return .blockNumber(fromBlockNumber + maxRange)
       } else {
           return .latest
       }
   }
   
   var web3SwiftRpcNodeBatchSupportPolicy: JSONRPCrequestDispatcher.DispatchPolicy {
       switch rpcNodeBatchSupport {
       case .noBatching:
           return .NoBatching
       case .batch(let size):
           return .Batch(size)
       }
   }
   
}
public struct EventFilter {
   public enum Block {
       case latest
       case pending
       case blockNumber(UInt64)
       
       var encoded: String {
           switch self {
           case .latest:
               return "latest"
           case .pending:
               return "pending"
           case .blockNumber(let number):
               return String(number, radix: 16).addHexPrefix()
           }
       }
   }
   
   public init() {
       
   }
   
   public init(fromBlock: Block?, toBlock: Block?, addresses: [EthereumAddress]? = nil, parameterFilters: [[EventFilterable]?]? = nil) {
       self.fromBlock = fromBlock
       self.toBlock = toBlock
       self.addresses = addresses
       self.parameterFilters = parameterFilters
   }
   
   public var fromBlock: Block?
   public var toBlock: Block?
   public var addresses: [EthereumAddress]?
   public var parameterFilters: [[EventFilterable]?]?
   
   public func rpcPreEncode() -> EventFilterParameters {
       var encoding = EventFilterParameters()
       if let fromBlock = fromBlock {
           encoding.fromBlock = fromBlock.encoded
       }
       if let toBlock = toBlock {
           encoding.toBlock = toBlock.encoded
       }
       if let addresses = addresses {
           encoding.address = addresses.map { $0.address }
       }
       return encoding
   }
}
public protocol EventFilterComparable {
   func isEqualTo(_ other: AnyObject) -> Bool
}

public protocol EventFilterEncodable {
   func eventFilterEncoded() -> String?
}

public protocol EventFilterable: EventFilterComparable, EventFilterEncodable {
   
}

   
   public enum Web3Error: Error {
       case connectionError(Error)
       case responseError(Error)
       case inputError(String)
       case nodeError(String)
       case generalError(Error)
       case rateLimited
   }

   public typealias RPCNodeHTTPHeaders = [String: String]

   public class Web3: Web3OptionsInheritable {
       public let options: Web3Options = Web3Options.defaultOptions()
       public let queue: DispatchQueue
       public let chainID: BigUInt
       private let provider: Web3RequestProvider
       private let requestDispatcher: JSONRPCrequestDispatcher

       public func dispatch(_ request: JSONRPCrequest) -> Promise<JSONRPCresponse> {
           return requestDispatcher.addToQueue(request: request)
       }

       public init(provider: Web3RequestProvider, chainID: BigUInt, queue: OperationQueue? = nil, requestDispatcher: JSONRPCrequestDispatcher? = nil) {
           self.provider = provider
           self.chainID = chainID
           let operationQueue: OperationQueue
           if queue == nil {
               operationQueue = OperationQueue.init()
               operationQueue.maxConcurrentOperationCount = 32
               operationQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
           } else {
               operationQueue = queue!
           }
           self.queue = operationQueue.underlyingQueue!
           if requestDispatcher == nil {
               self.requestDispatcher = JSONRPCrequestDispatcher(provider: provider, queue: self.queue, policy: .Batch(32))
           } else {
               self.requestDispatcher = requestDispatcher!
           }
       }

       public class Eth: Web3OptionsInheritable {
           public let web3: Web3
           public var options: Web3Options {
               return self.web3.options
           }

           public init(web3: Web3) {
               self.web3 = web3
           }
       }

       public class Personal: Web3OptionsInheritable {
           public let web3: Web3
           public var options: Web3Options {
               return web3.options
           }

           public init(web3: Web3) {
               self.web3 = web3
           }
       }
   }
public protocol Web3OptionsInheritable {
   var options: Web3Options { get }
}

public struct Web3Options {
   public var to: EthereumAddress?
   public var from: EthereumAddress?
   public var gasLimit: BigUInt?
   public var gasPrice: BigUInt?
   public var value: BigUInt?
   public var excludeZeroGasPrice: Bool = false

   public init() {
   }

   public static func defaultOptions() -> Web3Options {
       var options = Web3Options()
//        options.gasLimit = BigUInt("90000", radix: 10)!
//        options.gasPrice = BigUInt("5000000000", radix:10)!
       options.gasLimit = BigUInt(0)
       options.gasPrice = BigUInt(0)
       options.value = BigUInt(0)
       return options
   }

   public static func fromJSON(_ json: [String: Any]) -> Web3Options? {
       var options = Web3Options()
       if let gas = json["gas"] as? String, let gasBiguint = BigUInt(gas.stripHexPrefix().lowercased(), radix: 16) {
           options.gasLimit = gasBiguint
       }
       if let gasPrice = json["gasPrice"] as? String, let gasPriceBiguint = BigUInt(gasPrice.stripHexPrefix().lowercased(), radix: 16) {
           options.gasPrice = gasPriceBiguint
       }
       if let value = json["value"] as? String, let valueBiguint = BigUInt(value.stripHexPrefix().lowercased(), radix: 16) {
           options.value = valueBiguint
       }
       if let fromString = json["from"] as? String {
           guard let addressFrom = EthereumAddress(fromString) else { return nil }
           options.from = addressFrom
       }
       return options
   }

   public static func merge(_ options: Web3Options?, with other: Web3Options?) -> Web3Options {
       if other == nil && options == nil {
           return Web3Options.defaultOptions()
       }
       var newOptions = Web3Options.defaultOptions()
       if other?.to != nil {
           newOptions.to = other?.to
       } else {
           newOptions.to = options?.to
       }
       if other?.from != nil {
           newOptions.from = other?.from
       } else {
           newOptions.from = options?.from
       }
       if other?.gasLimit != nil {
           newOptions.gasLimit = other?.gasLimit
       } else {
           newOptions.gasLimit = options?.gasLimit
       }
       if other?.gasPrice != nil {
           newOptions.gasPrice = other?.gasPrice
       } else {
           newOptions.gasPrice = options?.gasPrice
       }
       if let other = other {
           newOptions.excludeZeroGasPrice = other.excludeZeroGasPrice
       }
       if other?.value != nil {
           newOptions.value = other?.value
       } else {
           newOptions.value = options?.value
       }
       return newOptions
   }

   public static func smartMergeGasLimit(originalOptions: Web3Options?, extraOptions: Web3Options?, gasEstimage: BigUInt) -> BigUInt? {
       let mergedOptions = Web3Options.merge(originalOptions, with: extraOptions)
       if mergedOptions.gasLimit == nil {
           return gasEstimage // for user's convenience we just use an estimate
//            return nil // there is no opinion from user, so we can not proceed
       } else {
           if originalOptions != nil, originalOptions!.gasLimit != nil, originalOptions!.gasLimit! < gasEstimage { // original gas estimate was less than what's required, so we check extra options
               if extraOptions != nil, extraOptions!.gasLimit != nil, extraOptions!.gasLimit! >= gasEstimage {
                   return extraOptions!.gasLimit!
               } else {
                   return gasEstimage // for user's convenience we just use an estimate
//                    return nil // estimate is lower than allowed
               }
           } else {
               return gasEstimage
           }
       }
   }
}
extension String {
   var fullRange: Range<Index> {
       return startIndex..<endIndex
   }

   var fullNSRange: NSRange {
       return NSRange(fullRange, in: self)
   }

   func lastIndex(of char: Character) -> Index? {
       guard let range = range(of: String(char), options: .backwards) else {
           return nil
       }
       return range.lowerBound
   }

   func index(of char: Character) -> Index? {
       guard let range = range(of: String(char)) else {
           return nil
       }
       return range.lowerBound
   }

   func split(intoChunksOf chunkSize: Int) -> [String] {
       var output = [String]()
       let splittedString = self
           .map { $0 }
           .split(intoChunksOf: chunkSize)
       splittedString.forEach {
           output.append($0.map { String($0) }.joined(separator: ""))
       }
       return output
   }

   subscript (bounds: CountableClosedRange<Int>) -> String {
       let start = index(self.startIndex, offsetBy: bounds.lowerBound)
       let end = index(self.startIndex, offsetBy: bounds.upperBound)
       return String(self[start...end])
   }

   subscript (bounds: CountableRange<Int>) -> String {
       let start = index(self.startIndex, offsetBy: bounds.lowerBound)
       let end = index(self.startIndex, offsetBy: bounds.upperBound)
       return String(self[start..<end])
   }

   subscript (bounds: CountablePartialRangeFrom<Int>) -> String {
       let start = index(self.startIndex, offsetBy: bounds.lowerBound)
       let end = self.endIndex
       return String(self[start..<end])
   }

   func leftPadding(toLength: Int, withPad character: Character) -> String {
       let stringLength = self.count
       if stringLength < toLength {
           return String(repeatElement(character, count: toLength - stringLength)) + self
       } else {
           return String(self.suffix(toLength))
       }
   }

   var hasHexPrefix: Bool {
       return self.hasPrefix("0x")
   }

   func stripHexPrefix() -> String {
       if self.hasPrefix("0x") {
           let indexStart = self.index(self.startIndex, offsetBy: 2)
           return String(self[indexStart...])
       }
       return self
   }

   func addHexPrefix() -> String {
       if !self.hasPrefix("0x") {
           return "0x" + self
       }
       return self
   }

   func stripLeadingZeroes() -> String? {
       let hex = self.addHexPrefix()
       guard let matcher = try? NSRegularExpression(pattern: "^(?<prefix>0x)0*(?<end>[0-9a-fA-F]*)$", options: NSRegularExpression.Options.dotMatchesLineSeparators) else { return nil }
       let match = matcher.captureGroups(string: hex, options: NSRegularExpression.MatchingOptions.anchored)
       guard let prefix = match["prefix"] else { return nil }
       guard let end = match["end"] else { return nil }
       if !end.isEmpty {
           return prefix + end
       }
       return "0x0"
   }

   func matchingStrings(regex: String) -> [[String]] {
       guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
       let nsString = self as NSString
       let results = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
       return results.map { result in
           (0..<result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
               ? nsString.substring(with: result.range(at: $0))
               : ""
           }
       }
   }

   func range(from nsRange: NSRange) -> Range<String.Index>? {
       guard
           let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
           let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
           let from = from16.samePosition(in: self),
           let to = to16.samePosition(in: self)
           else { return nil }
       return from ..< to
   }

   var asciiValue: Int {
       let s = self.unicodeScalars
       return Int(s[s.startIndex].value)
   }
}

extension Character {
   var asciiValue: Int {
       let s = String(self).unicodeScalars
       return Int(s[s.startIndex].value)
   }
}

public struct EthereumAddress: Equatable {
   public enum AddressType {
       case normal
       case contractDeployment
   }
   
   public var isValid: Bool {
       switch self.type {
       case .normal:
           return self.addressData.count == 20
       case .contractDeployment:
           return true
       }
   }
   var _address: String
   public var type: AddressType = .normal
   public static func == (lhs: EthereumAddress, rhs: EthereumAddress) -> Bool {
       return lhs.addressData == rhs.addressData && lhs.type == rhs.type
   }
   
   public var addressData: Data {
       switch self.type {
       case .normal:
           return Data.fromHex(_address) ?? Data()
       case .contractDeployment:
           return Data()
       }
   }
   public var address: String {
       switch self.type {
       case .normal:
           return EthereumAddress.toChecksumAddress(_address)!
       case .contractDeployment:
           return "0x"
       }
   }
   
   public static func toChecksumAddress(_ addr: String) -> String? {
       let address = addr.lowercased().stripHexPrefix()
       guard let hash = address.data(using: .ascii)?.sha3(.keccak256).toHexString().stripHexPrefix() else { return nil }
       var ret = "0x"
       
       for (i, char) in address.enumerated() {
           let startIdx = hash.index(hash.startIndex, offsetBy: i)
           let endIdx = hash.index(hash.startIndex, offsetBy: i+1)
           let hashChar = String(hash[startIdx..<endIdx])
           let c = String(char)
           guard let int = Int(hashChar, radix: 16) else { return nil }
           if int >= 8 {
               ret += c.uppercased()
           } else {
               ret += c
           }
       }
       return ret
   }
   
   public init?(_ addressString: String, type: AddressType = .normal, ignoreChecksum: Bool = false) {
       switch type {
       case .normal:
           guard let data = Data.fromHex(addressString) else { return nil }
           guard data.count == 20 else { return nil }
           if !addressString.hasHexPrefix {
               return nil
           }
           if !ignoreChecksum {
               // check for checksum
               if data.toHexString() == addressString.stripHexPrefix() {
                   self._address = data.toHexString().addHexPrefix()
                   self.type = .normal
                   return
               } else if data.toHexString().uppercased() == addressString.stripHexPrefix() {
                   self._address = data.toHexString().addHexPrefix()
                   self.type = .normal
                   return
               } else {
                   let checksummedAddress = EthereumAddress.toChecksumAddress(data.toHexString().addHexPrefix())
                   guard checksummedAddress == addressString else { return nil }
                   self._address = data.toHexString().addHexPrefix()
                   self.type = .normal
                   return
               }
           } else {
               self._address = data.toHexString().addHexPrefix()
               self.type = .normal
               return
           }
       case .contractDeployment:
           self._address = "0x"
           self.type = .contractDeployment
       }
   }
   
   public init?(_ addressData: Data, type: AddressType = .normal) {
       guard addressData.count == 20 else { return nil }
       self._address = addressData.toHexString().addHexPrefix()
       self.type = type
   }
   
   public static func contractDeploymentAddress() -> EthereumAddress {
       return EthereumAddress("0x", type: .contractDeployment)!
   }
}

extension NSRegularExpression {
   typealias GroupNamesSearchResult = (NSTextCheckingResult, NSTextCheckingResult, Int)
   private static let gregRegex = try? NSRegularExpression(pattern: "^\\(\\?<([\\w\\a_-]*)>$", options: .dotMatchesLineSeparators)
   private static let regRegex = try? NSRegularExpression(pattern: "\\(.*?>", options: .dotMatchesLineSeparators)
   
   private func textCheckingResultsOfNamedCaptureGroups() -> [String: GroupNamesSearchResult] {
       var groupnames = [String: GroupNamesSearchResult]()
       
       guard let greg = NSRegularExpression.gregRegex else {
           // This never happens but the alternative is to make this method throwing
           return groupnames
       }
       guard let reg = NSRegularExpression.regRegex else {
           // This never happens but the alternative is to make this method throwing
           return groupnames
       }
       let m = reg.matches(in: self.pattern, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: NSRange(location: 0, length: self.pattern.utf16.count))
       for (n, g) in m.enumerated() {
           let r = self.pattern.range(from: g.range(at: 0))
           let gstring = String(self.pattern[r!])
           let gmatch = greg.matches(in: gstring, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange(location: 0, length: gstring.utf16.count))
           if !gmatch.isEmpty {
               let r2 = gstring.range(from: gmatch[0].range(at: 1))!
               groupnames[String(gstring[r2])] = (g, gmatch[0], n)
           }
           
       }
       return groupnames
   }
   
   func indexOfNamedCaptureGroups() throws -> [String: Int] {
       var groupnames = [String: Int]()
       for (name, (_, _, n)) in self.textCheckingResultsOfNamedCaptureGroups() {
           groupnames[name] = n + 1
       }
       return groupnames
   }
   
   func rangesOfNamedCaptureGroups(match: NSTextCheckingResult) throws -> [String: Range<Int>] {
       var ranges: [String: Range<Int>] = [:]
       for (name, (_, _, n)) in self.textCheckingResultsOfNamedCaptureGroups() {
           ranges[name] = Range(match.range(at: n + 1))
       }
       return ranges
   }
   
   private func nameForIndex(_ index: Int, from: [String: GroupNamesSearchResult]) -> String? {
       for (name, (_, _, n)) in from where n + 1 == index {
           return name
       }
       return nil
   }
   
   func captureGroups(string: String, options: NSRegularExpression.MatchingOptions = []) -> [String: String] {
       return captureGroups(string: string, options: options, range: NSRange(location: 0, length: string.utf16.count))
   }
   
   func captureGroups(string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange) -> [String: String] {
       var dict: [String: String] = [:]
       let matchResult = matches(in: string, options: options, range: range)
       let names = self.textCheckingResultsOfNamedCaptureGroups()
       for m in matchResult {
           for i in (0..<m.numberOfRanges) {
               guard let r2 = string.range(from: m.range(at: i)) else { continue }
               let g = String(string[r2])
               if let name = nameForIndex(i, from: names) {
                   dict[name] = g
               }
           }
       }
       return dict
   }
}
public extension Data {
   
   init<T>(fromArray values: [T]) {
       var values = values
       self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
   }
   
   func toArray<T>(type: T.Type) -> [T] {
       return self.withUnsafeBytes {
           [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.stride))
       }
   }
   
    func constantTimeComparisonTo(_ other: Data?) -> Bool {
       guard let rhs = other else { return false }
       guard self.count == rhs.count else { return false }
       var difference = UInt8(0x00)
       for i in 0..<self.count { // compare full length
           difference |= self[i] ^ rhs[i] //constant time
       }
       return difference == UInt8(0x00)
   }

   public static func randomBytes(length: Int) -> Data? {
       for _ in 0...1024 {
           var data = Data(repeating: 0, count: length)
           let result = data.withUnsafeMutableBytes { mutableBytes -> Int32 in
               SecRandomCopyBytes(kSecRandomDefault, 32, mutableBytes)
           }
           if result == errSecSuccess {
               return data
           }
       }
       return nil
   }
   
   public static func fromHex(_ hex: String) -> Data? {
       let string = hex.lowercased().stripHexPrefix()
       let array = Array(hex: string)
       if array.isEmpty {
           if hex == "0x" || hex == "" {
               return Data()
           } else {
               return nil
           }
       }

       return Data(array)
   }
   
   func bitsInRange(_ startingBit: Int, _ length: Int) -> UInt64? { //return max of 8 bytes for simplicity, non-public
       if startingBit + length / 8 > self.count, length > 64, startingBit > 0, length >= 1 { return nil }
       let bytes = self[(startingBit/8) ..< (startingBit+length+7)/8]
       let padding = Data(repeating: 0, count: 8 - bytes.count)
       let padded = bytes + padding
       guard padded.count == 8 else { return nil }
       var uintRepresentation = UInt64(bigEndian: padded.withUnsafeBytes { $0.pointee })
       uintRepresentation = uintRepresentation << (startingBit % 8)
       uintRepresentation = uintRepresentation >> UInt64(64 - length)
       return uintRepresentation
   }
}
extension Array {
   public func split(intoChunksOf chunkSize: Int) -> [[Element]] {
       return stride(from: 0, to: self.count, by: chunkSize).map {
           let endIndex = ($0.advanced(by: chunkSize) > self.count) ? self.count - $0 : chunkSize
           return Array(self[$0..<$0.advanced(by: endIndex)])
       }
   }
}

public protocol Web3RequestProvider {
   func sendAsync(_ request: JSONRPCrequest, queue: DispatchQueue) -> Promise<JSONRPCresponse>
   func sendAsync(_ requests: JSONRPCrequestBatch, queue: DispatchQueue) -> Promise<JSONRPCresponseBatch>
}

public class Web3HttpProvider: Web3RequestProvider {
   public let headers: RPCNodeHTTPHeaders
   public let url: URL
   public var session: URLSession = {
       let config = URLSessionConfiguration.default
       let urlSession = URLSession(configuration: config)
       return urlSession
   }()

   public init?(_ url: URL, headers: RPCNodeHTTPHeaders) {
       guard url.scheme == "http" || url.scheme == "https" else { return nil }
       self.headers = headers
       self.url = url
   }

   private static func generateBasicAuthCredentialsHeaderValue(fromURL url: URL) -> String? {
       guard let username = url.user, let password = url.password  else { return nil }
       return "\(username):\(password)".data(using: .utf8)?.base64EncodedString()
   }

   private static func urlRequest<T: Encodable>(for request: T, providerURL: URL, headers: RPCNodeHTTPHeaders, using decoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
       let encoder = JSONEncoder()
       let requestData = try encoder.encode(request)
       var urlRequest = URLRequest(url: providerURL)
       urlRequest.httpMethod = "POST"
       urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
       urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
       if let basicAuth = generateBasicAuthCredentialsHeaderValue(fromURL: providerURL) {
           urlRequest.setValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
       }
       for (key, value) in headers {
           urlRequest.setValue(value, forHTTPHeaderField: key)
       }
       urlRequest.httpBody = requestData

       return urlRequest
   }

   private static func dataTask<T: Encodable>(for request: T, providerURL: URL, headers: RPCNodeHTTPHeaders, using decoder: JSONEncoder = JSONEncoder(), queue: DispatchQueue = .main, session: URLSession) -> Promise<Swift.Result<Data, Web3Error>> {
       let promise = Promise<Swift.Result<Data, Web3Error>>.pending()
       var task: URLSessionTask?
       queue.async {
           do {
               let urlRequest = try Web3HttpProvider.urlRequest(for: request, providerURL: providerURL, headers: headers)
               task = session.dataTask(with: urlRequest) { (data, response, error) in
                   let result: Swift.Result<Data, Web3Error>

                   switch (data, response, error) {
                   case (_, _, let error?):
                       result = .failure(.connectionError(error))
                   case (let data?, let urlResponse as HTTPURLResponse, _):
                       if urlResponse.statusCode == 429 {
                           result = .failure(.rateLimited)
                       } else {
                           if data.isEmpty {
                               result = .failure(Web3Error.responseError(URLError(.zeroByteResource)))
                           } else {
                               result = .success(data)
                           }
                       }
                   default:
                       result = .failure(.responseError(URLError(.unknown)))
                   }

                   promise.resolver.fulfill(result)
               }
               task?.resume()
           } catch {
               promise.resolver.reject(error)
           }
       }

       return promise.promise.ensure(on: queue) { task = nil }
   }

   static func post(_ request: JSONRPCrequest, providerURL: URL, headers: RPCNodeHTTPHeaders, queue: DispatchQueue = .main, session: URLSession) -> Promise<JSONRPCresponse> {
       return Web3HttpProvider.dataTask(for: request, providerURL: providerURL, headers: headers, queue: queue, session: session)
           .map(on: queue) { result throws -> JSONRPCresponse in
               switch result {
               case .success(let data):
                   do {
                       let parsedResponse = try JSONDecoder().decode(JSONRPCresponse.self, from: data)
                       if let message = parsedResponse.error {
                           throw Web3Error.nodeError("Received an error message from node\n" + String(describing: message))
                       }
                       return parsedResponse
                   } catch {
                       throw Web3Error.responseError(error)
                   }
               case .failure(let error):
                   throw error
               }
           }
   }

   static func post(_ request: JSONRPCrequestBatch, providerURL: URL, headers: RPCNodeHTTPHeaders, queue: DispatchQueue = .main, session: URLSession) -> Promise<JSONRPCresponseBatch> {
       return Web3HttpProvider.dataTask(for: request, providerURL: providerURL, headers: headers, queue: queue, session: session)
           .map(on: queue) { result throws -> JSONRPCresponseBatch in
               switch result {
               case .success(let data):
                   do {
                       let response = try JSONDecoder().decode(JSONRPCresponseBatch.self, from: data)
                       return response
                   } catch {
                       do {
                           let parsedResponse = try JSONDecoder().decode(JSONRPCresponse.self, from: data)
                           if let message = parsedResponse.error {
                               throw Web3Error.nodeError(message.message)
                           }
                           return JSONRPCresponseBatch(responses: [parsedResponse])
                       } catch {
                           throw Web3Error.responseError(error)
                       }
                   }
               case .failure(let error):
                   throw error
               }
           }
   }

   public func sendAsync(_ request: JSONRPCrequest, queue: DispatchQueue = .main) -> Promise<JSONRPCresponse> {
       return Web3HttpProvider.post(request, providerURL: url, headers: headers, queue: queue, session: session)
   }

   public func sendAsync(_ requests: JSONRPCrequestBatch, queue: DispatchQueue = .main) -> Promise<JSONRPCresponseBatch> {
       return Web3HttpProvider.post(requests, providerURL: url, headers: headers, queue: queue, session: session)
   }
}

public struct Counter {
   public static var counter = UInt64(1)
   public static var lockQueue = DispatchQueue(label: "counterQueue")
   public static func increment() -> UInt64 {
       var counter: UInt64 = 0
       lockQueue.sync {
           counter = Counter.counter
           Counter.counter += 1
       }
       return counter
   }
}

public struct JSONRPCrequest: Encodable {
   var jsonrpc: String = "2.0"
   var method: JSONRPCmethod
   var params: JSONRPCparams
   var id: UInt64 = Counter.increment()

   public init(jsonrpc: String = "2.0", id: UInt64 = Counter.increment(), method: JSONRPCmethod, params: JSONRPCparams) {
       self.jsonrpc = jsonrpc
       self.id = id
       self.method = method
       self.params = params
   }
   
   enum CodingKeys: String, CodingKey {
       case jsonrpc
       case method
       case params
       case id
   }
   
   public func encode(to encoder: Encoder) throws {
       var container = encoder.container(keyedBy: CodingKeys.self)
       try container.encode(jsonrpc, forKey: .jsonrpc)
       try container.encode(method.rawValue, forKey: .method)
       try container.encode(params, forKey: .params)
       try container.encode(id, forKey: .id)
   }
   
   public var isValid: Bool {
       return method.requiredNumOfParameters == self.params.params.count
   }
}

public struct JSONRPCrequestBatch: Encodable {
   var requests: [JSONRPCrequest]

   public func encode(to encoder: Encoder) throws {
       var container = encoder.singleValueContainer()
       try container.encode(self.requests)
   }
}

public enum DecodeError: Error {
   case typeMismatch
   case initFailure
}

public struct JSONRPCresponse: Decodable {
   public var id: Int?
   public var jsonrpc = "2.0"
   public var result: Any?
   public var error: ErrorMessage?
   public var message: String?
   
   enum JSONRPCresponseKeys: String, CodingKey {
       case id
       case jsonrpc
       case result
       case error
   }
   
   public init(id: Int?, jsonrpc: String, result: Any?, error: ErrorMessage?) {
       self.id = id
       self.jsonrpc = jsonrpc
       self.result = result
       self.error = error
   }
   
   public struct ErrorMessage: Decodable {
       enum Keys: String, CodingKey {
           case code
           case message
           case data
       }

       public var code: Int
       public var message: String
       public var data: String?

       public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: Keys.self)
           do {
               self.code = try container.decode(Int.self, forKey: .code)
           } catch {
               guard let codeString: String = try? container.decode(String.self, forKey: .code), let code = Int(codeString) else { throw DecodeError.typeMismatch }
               self.code = code
           }
           data = try container.decodeIfPresent(String.self, forKey: .data)
           message = try container.decode(String.self, forKey: .message)
       }
   }
   
   public init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: JSONRPCresponseKeys.self)
       let id = try container.decodeIfPresent(Int.self, forKey: .id)
       let jsonrpc: String = try container.decode(String.self, forKey: .jsonrpc)

       if let errorMessage = try? container.decode(ErrorMessage.self, forKey: .error) {
           self.init(id: id, jsonrpc: jsonrpc, result: nil, error: errorMessage)
       } else {
           var result: Any?
           if let rawValue = try? container.decodeIfPresent(String.self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent(Int.self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent(Bool.self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent(EventLog.self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent(Block.self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent(TransactionReceipt.self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent(TransactionDetails.self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent([EventLog].self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent([Block].self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent([TransactionReceipt].self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent([TransactionDetails].self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent([Bool].self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent([Int].self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent([String].self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent([String: String].self, forKey: .result) {
               result = rawValue
           } else if let rawValue = try? container.decodeIfPresent([String: Int].self, forKey: .result) {
               result = rawValue
           }
           self.init(id: id, jsonrpc: jsonrpc, result: result, error: nil)
       }
   }
   
   public func getValue<T>() -> T? {
       let slf = T.self
       if slf == BigUInt.self {
           guard let string = self.result as? String else { return nil }
           guard let value = BigUInt(string.stripHexPrefix(), radix: 16) else { return nil }
           return value as? T
       } else if slf == BigInt.self {
           guard let string = self.result as? String else { return nil }
           guard let value = BigInt(string.stripHexPrefix(), radix: 16) else { return nil }
           return value as? T
       } else if slf == Data.self {
           guard let string = self.result as? String else { return nil }
           guard let value = Data.fromHex(string) else { return nil }
           return value as? T
       } else if slf == EthereumAddress.self {
           guard let string = self.result as? String else { return nil }
           guard let value = EthereumAddress(string, ignoreChecksum: true) else { return nil }
           return value as? T
       }
//        else if slf == String.self {
//            guard let value = self.result as? T else { return nil }
//            return value
//        } else if slf == Int.self {
//            guard let value = self.result as? T else { return nil }
//            return value
//        }
       else if slf == [BigUInt].self {
           guard let string = self.result as? [String] else { return nil }
           let values = string.compactMap { (str) -> BigUInt? in
               return BigUInt(str.stripHexPrefix(), radix: 16)
           }
           return values as? T
       } else if slf == [BigInt].self {
           guard let string = self.result as? [String] else { return nil }
           let values = string.compactMap { (str) -> BigInt? in
               return BigInt(str.stripHexPrefix(), radix: 16)
           }
           return values as? T
       } else if slf == [Data].self {
           guard let string = self.result as? [String] else { return nil }
           let values = string.compactMap { (str) -> Data? in
               return Data.fromHex(str)
           }
           return values as? T
       } else if slf == [EthereumAddress].self {
           guard let string = self.result as? [String] else { return nil }
           let values = string.compactMap { (str) -> EthereumAddress? in
               return EthereumAddress(str, ignoreChecksum: true)
           }
           return values as? T
       }
//        else if slf == [String].self {
//            guard let value = self.result as? T else { return nil }
//            return value
//        } else if slf == [Int].self {
//            guard let value = self.result as? T else { return nil }
//            return value
//        } else if slf == [String: String].self{
//            guard let value = self.result as? T else { return nil }
//            return value
//        }
//        else if slf == [String: AnyObject].self{
//            guard let value = self.result as? T else { return nil }
//            return value
//        } else if slf == [String: Any].self{
//            guard let value = self.result as? T else { return nil }
//            return value
//        }
       guard let value = self.result as? T else { return nil }
       return value
   }
}

public struct JSONRPCresponseBatch {
   var responses: [JSONRPCresponse]
}

extension JSONRPCresponseBatch: Decodable {
   public init(from decoder: Decoder) throws {
       let container = try decoder.singleValueContainer()
       let responses = try container.decode([JSONRPCresponse].self)
       self.responses = responses
   }
}

public struct TransactionParameters: Codable {
   public var data: String?
   public var from: String?
   public var gas: String?
   public var gasPrice: String?
   public var to: String?
   public var value: String? = "0x0"
   
   public init(from: String?, to: String?) {
       self.from = from
       self.to = to
   }
}

public struct EventFilterParameters: Codable {
   public var fromBlock: String?
   public var toBlock: String?
   public var topics: [[String?]?]?
   public var address: [String?]?
}

public struct JSONRPCparams: Encodable {
   public let params: [Any]

   public init(params: [Any]) {
       self.params = params
   }
   
   public func encode(to encoder: Encoder) throws {
       var container = encoder.unkeyedContainer()
       for par in params {
           if let p = par as? TransactionParameters {
               try container.encode(p)
           } else if let p = par as? String {
               try container.encode(p)
           } else if let p = par as? Bool {
               try container.encode(p)
           } else if let p = par as? EventFilterParameters {
               try container.encode(p)
           }
       }
   }
}
public enum JSONRPCmethod: Encodable {
   case gasPrice
   case blockNumber
   case getNetwork
   case sendRawTransaction
   case sendTransaction
   case estimateGas
   case call
   case getTransactionCount
   case getBalance
   case getCode
   case getStorageAt
   case getTransactionByHash
   case getTransactionReceipt
   case getAccounts
   case getBlockByHash
   case getBlockByNumber
   case personalSign
   case unlockAccount
   case getLogs
   case custom(String, params: Int)
   
   public var requiredNumOfParameters: Int {
       switch self {
       case .call:
           return 2
       case .getTransactionCount:
           return 2
       case .getBalance:
           return 2
       case .getStorageAt:
           return 2
       case .getCode:
           return 2
       case .getBlockByHash:
           return 2
       case .getBlockByNumber:
           return 2
       case .gasPrice:
           return 0
       case .blockNumber:
           return 0
       case .getNetwork:
           return 0
       case .getAccounts:
           return 0
       case .custom(_, let params):
           return params
       default:
           return 1
       }
   }

   public var rawValue: String {
       switch self {
       case .gasPrice: return "eth_gasPrice"
       case .blockNumber: return "eth_blockNumber"
       case .getNetwork: return "net_version"
       case .sendRawTransaction: return "eth_sendRawTransaction"
       case .sendTransaction: return "eth_sendTransaction"
       case .estimateGas: return "eth_estimateGas"
       case .call: return "eth_call"
       case .getTransactionCount: return "eth_getTransactionCount"
       case .getBalance: return "eth_getBalance"
       case .getCode: return "eth_getCode"
       case .getStorageAt: return "eth_getStorageAt"
       case .getTransactionByHash: return "eth_getTransactionByHash"
       case .getTransactionReceipt: return "eth_getTransactionReceipt"
       case .getAccounts: return "eth_accounts"
       case .getBlockByHash: return "eth_getBlockByHash"
       case .getBlockByNumber: return "eth_getBlockByNumber"
       case .personalSign: return "eth_sign"
       case .unlockAccount: return "personal_unlockAccount"
       case .getLogs: return "eth_getLogs"
       case .custom(let value, _): return value
       }
   }
}

extension JSONRPCmethod: Equatable {
   public static func == (lhs: JSONRPCmethod, rhs: JSONRPCmethod) -> Bool {
       return lhs.rawValue == rhs.rawValue && lhs.requiredNumOfParameters == rhs.requiredNumOfParameters
   }
}
fileprivate func decodeHexToData<T>(_ container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key, allowOptional: Bool = false) throws -> Data? {
   if allowOptional {
       let string = try? container.decode(String.self, forKey: key)
       if string != nil {
           guard let data = Data.fromHex(string!) else { throw DecodeError.initFailure }
           return data
       }
       return nil
   } else {
       let string = try container.decode(String.self, forKey: key)
       guard let data = Data.fromHex(string) else { throw DecodeError.initFailure }
       return data
   }
}

fileprivate func decodeHexToBigUInt<T>(_ container: KeyedDecodingContainer<T>, key: KeyedDecodingContainer<T>.Key, allowOptional: Bool = false) throws -> BigUInt? {
   if allowOptional {
       if let string = try? container.decode(String.self, forKey: key) {
           guard let number = BigUInt(string.stripHexPrefix(), radix: 16) else { throw DecodeError.typeMismatch }
           return number
       }
       return nil
   } else {
       guard let number = BigUInt(try container.decode(String.self, forKey: key).stripHexPrefix(), radix: 16) else { throw DecodeError.typeMismatch }
       return number
   }
}

extension Web3Options: Decodable {
   enum CodingKeys: String, CodingKey {
       case from
       case to
       case gasPrice
       case gas
       case value
   }
   
   public init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       self.gasLimit = try decodeHexToBigUInt(container, key: .gas)
       self.gasPrice = try decodeHexToBigUInt(container, key: .gasPrice)
       
       let toString = try container.decode(String.self, forKey: .to)
       var to: EthereumAddress?
       if toString == "0x" || toString == "0x0" {
           to = EthereumAddress.contractDeploymentAddress()
       } else {
           guard let ethAddr = EthereumAddress(toString) else { throw DecodeError.typeMismatch }
           to = ethAddr
       }
       self.to = to
       self.from = try container.decodeIfPresent(EthereumAddress.self, forKey: .to)
       self.value = try decodeHexToBigUInt(container, key: .value)
   }
}

extension EthereumTransaction: Decodable {
   enum CodingKeys: String, CodingKey {
       case to
       case data
       case input
       case nonce
       case v
       case r
       case s
       case value
   }
   
   public init(from decoder: Decoder) throws {
       let options = try Web3Options(from: decoder)
       let container = try decoder.container(keyedBy: CodingKeys.self)
       
       var data = try decodeHexToData(container, key: .data, allowOptional: true)
       if data != nil {
           self.data = data!
       } else {
           data = try decodeHexToData(container, key: .input, allowOptional: true)
           if data != nil {
               self.data = data!
           } else {
               throw DecodeError.initFailure
           }
       }
       
       guard let nonce = try decodeHexToBigUInt(container, key: .nonce) else { throw DecodeError.initFailure }
       self.nonce = nonce

       guard let v = try decodeHexToBigUInt(container, key: .v) else { throw DecodeError.initFailure }
       self.v = v
       
       guard let r = try decodeHexToBigUInt(container, key: .r) else { throw DecodeError.initFailure }
       self.r = r
       
       guard let s = try decodeHexToBigUInt(container, key: .s) else { throw DecodeError.initFailure }
       self.s = s
       
       if options.value == nil || options.to == nil || options.gasLimit == nil || options.gasPrice == nil {
           throw DecodeError.initFailure
       }
       self.value = options.value!
       self.to = options.to!
       self.gasPrice = options.gasPrice!
       self.gasLimit = options.gasLimit!
       
       let inferedChainID = self.inferedChainID
       if self.inferedChainID != nil && self.v >= BigUInt(37) {
           self.chainID = inferedChainID
       }
   }
}

public struct TransactionDetails: Decodable {
   public var blockHash: Data?
   public var blockNumber: BigUInt?
   public var transactionIndex: BigUInt?
   public var transaction: EthereumTransaction
   
   enum CodingKeys: String, CodingKey {
       case blockHash
       case blockNumber
       case transactionIndex
   }
   
   public init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       let blockNumber = try decodeHexToBigUInt(container, key: .blockNumber, allowOptional: true)
       self.blockNumber = blockNumber
       
       let blockHash = try decodeHexToData(container, key: .blockHash, allowOptional: true)
       self.blockHash = blockHash
       
       let transactionIndex = try decodeHexToBigUInt(container, key: .blockNumber, allowOptional: true)
       self.transactionIndex = transactionIndex
       
       let transaction = try EthereumTransaction(from: decoder)
       self.transaction = transaction
   }
   
   public init? (_ json: [String: AnyObject]) {
       let bh = json["blockHash"] as? String
       if bh != nil {
           guard let blockHash = Data.fromHex(bh!) else { return nil }
           self.blockHash = blockHash
       }
       let bn = json["blockNumber"] as? String
       let ti = json["transactionIndex"] as? String
       
       guard let transaction = EthereumTransaction.fromJSON(json) else { return nil }
       self.transaction = transaction
       if bn != nil {
           blockNumber = BigUInt(bn!.stripHexPrefix(), radix: 16)
       }
       if ti != nil {
           transactionIndex = BigUInt(ti!.stripHexPrefix(), radix: 16)
       }
   }
}

public struct TransactionReceipt: Decodable {
   public var transactionHash: Data
   public var blockHash: Data
   public var blockNumber: BigUInt
   public var transactionIndex: BigUInt
   public var contractAddress: EthereumAddress?
   public var cumulativeGasUsed: BigUInt
   public var gasUsed: BigUInt
   public var logs: [EventLog]
   public var status: TXStatus
   public var logsBloom: EthereumBloomFilter?
   
   public enum TXStatus {
       case ok
       case failed
       case notYetProcessed
   }
   
   enum CodingKeys: String, CodingKey {
       case blockHash
       case blockNumber
       case transactionHash
       case transactionIndex
       case contractAddress
       case cumulativeGasUsed
       case gasUsed
       case logs
       case logsBloom
       case status
   }
   
   public init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       guard let blockNumber = try decodeHexToBigUInt(container, key: .blockNumber) else { throw DecodeError.typeMismatch }
       self.blockNumber = blockNumber
       
       guard let blockHash = try decodeHexToData(container, key: .blockHash) else { throw DecodeError.typeMismatch }
       self.blockHash = blockHash
       
       guard let transactionIndex = try decodeHexToBigUInt(container, key: .transactionIndex) else { throw DecodeError.typeMismatch }
       self.transactionIndex = transactionIndex
       
       guard let transactionHash = try decodeHexToData(container, key: .transactionHash) else { throw DecodeError.typeMismatch }
       self.transactionHash = transactionHash
       
       let contractAddress = try container.decodeIfPresent(EthereumAddress.self, forKey: .contractAddress)
       if contractAddress != nil {
           self.contractAddress = contractAddress
       }
       
       guard let cumulativeGasUsed = try decodeHexToBigUInt(container, key: .cumulativeGasUsed) else { throw DecodeError.typeMismatch }
       self.cumulativeGasUsed = cumulativeGasUsed
       
       guard let gasUsed = try decodeHexToBigUInt(container, key: .gasUsed) else { throw DecodeError.typeMismatch }
       self.gasUsed = gasUsed

       let status = try decodeHexToBigUInt(container, key: .status, allowOptional: true)
       if status == nil {
           self.status = TXStatus.notYetProcessed
       } else if status == 1 {
           self.status = TXStatus.ok
       } else {
           self.status = TXStatus.failed
       }
       
       if let logsData = try decodeHexToData(container, key: .logsBloom, allowOptional: true), !logsData.isEmpty {
           self.logsBloom = EthereumBloomFilter(logsData)
       }

       let logs = try container.decode([EventLog].self, forKey: .logs)
       self.logs = logs
   }

   public init(transactionHash: Data, blockHash: Data, blockNumber: BigUInt, transactionIndex: BigUInt, contractAddress: EthereumAddress?, cumulativeGasUsed: BigUInt, gasUsed: BigUInt, logs: [EventLog], status: TXStatus, logsBloom: EthereumBloomFilter?) {
       self.transactionHash = transactionHash
       self.blockHash = blockHash
       self.blockNumber = blockNumber
       self.transactionIndex = transactionIndex
       self.contractAddress = contractAddress
       self.cumulativeGasUsed = cumulativeGasUsed
       self.gasUsed = gasUsed
       self.logs = logs
       self.status = status
       self.logsBloom = logsBloom
   }
   
   public init?(_ json: [String: AnyObject]) {
       guard let th = json["transactionHash"] as? String else { return nil }
       guard let transactionHash = Data.fromHex(th) else { return nil }
       self.transactionHash = transactionHash
       guard let bh = json["blockHash"] as? String else { return nil }
       guard let blockHash = Data.fromHex(bh) else { return nil }
       self.blockHash = blockHash
       guard let bn = json["blockNumber"] as? String else { return nil }
       guard let ti = json["transactionIndex"] as? String else { return nil }
       let ca = json["contractAddress"] as? String
       guard let cgu = json["cumulativeGasUsed"] as? String else { return nil }
       guard let gu = json["gasUsed"] as? String else { return nil }
       guard let ls = json["logs"] as? [[String: AnyObject]] else { return nil }
       let lbl = json["logsBloom"] as? String
       let st = json["status"] as? String
   
       guard let bnUnwrapped = BigUInt(bn.stripHexPrefix(), radix: 16) else { return nil }
       blockNumber = bnUnwrapped
       guard let tiUnwrapped = BigUInt(ti.stripHexPrefix(), radix: 16) else { return nil }
       transactionIndex = tiUnwrapped
       if ca != nil {
           contractAddress = EthereumAddress(ca!.addHexPrefix())
       }
       guard let cguUnwrapped = BigUInt(cgu.stripHexPrefix(), radix: 16) else { return nil }
       cumulativeGasUsed = cguUnwrapped
       guard let guUnwrapped = BigUInt(gu.stripHexPrefix(), radix: 16) else { return nil }
       gasUsed = guUnwrapped
       var allLogs = [EventLog]()
       for l in ls {
           guard let log = EventLog(l) else { return nil }
           allLogs.append(log)
       }
       logs = allLogs
       if st == nil {
           status = TXStatus.notYetProcessed
       } else if st == "0x1" {
           status = TXStatus.ok
       } else {
           status = TXStatus.failed
       }

       if let logsData = lbl.flatMap({ Data.fromHex($0) }), !logsData.isEmpty {
           logsBloom = EthereumBloomFilter(logsData)
       }
   }
   
   static func notProcessed(transactionHash: Data) -> TransactionReceipt {
       let receipt = TransactionReceipt.init(transactionHash: transactionHash, blockHash: Data(), blockNumber: BigUInt(0), transactionIndex: BigUInt(0), contractAddress: nil, cumulativeGasUsed: BigUInt(0), gasUsed: BigUInt(0), logs: [EventLog](), status: .notYetProcessed, logsBloom: nil)
       return receipt
   }
}

extension EthereumAddress: Decodable, Encodable {
   public init(from decoder: Decoder) throws {
       let container = try decoder.singleValueContainer()
       let stringValue = try container.decode(String.self)
       self.init(stringValue)!
   }
   public func encode(to encoder: Encoder) throws {
       let value = self.address.lowercased()
       var signleValuedCont = encoder.singleValueContainer()
       try signleValuedCont.encode(value)
   }
}

public struct EventLog: Codable {
   public var address: EthereumAddress
   public var blockHash: Data
   public var blockNumber: BigUInt
   public var data: Data
   public var logIndex: BigUInt
   public var removed: Bool
   public var topics: [Data]
   public var transactionHash: Data
   public var transactionIndex: BigUInt

   enum CodingKeys: String, CodingKey {
       case address
       case blockHash
       case blockNumber
       case data
       case logIndex
       case removed
       case topics
       case transactionHash
       case transactionIndex
   }
   
   public init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       
       let address = try container.decode(EthereumAddress.self, forKey: .address)
       self.address = address
       
       guard let blockNumber = try decodeHexToBigUInt(container, key: .blockNumber) else { throw DecodeError.typeMismatch }
       self.blockNumber = blockNumber
       
       guard let blockHash = try decodeHexToData(container, key: .blockHash) else { throw DecodeError.typeMismatch }
       self.blockHash = blockHash
       
       guard let transactionIndex = try decodeHexToBigUInt(container, key: .transactionIndex) else { throw DecodeError.typeMismatch }
       self.transactionIndex = transactionIndex
       
       guard let transactionHash = try decodeHexToData(container, key: .transactionHash) else { throw DecodeError.typeMismatch }
       self.transactionHash = transactionHash
   
       guard let data = try decodeHexToData(container, key: .data) else { throw DecodeError.typeMismatch }
       self.data = data
       
       guard let logIndex = try decodeHexToBigUInt(container, key: .logIndex) else { throw DecodeError.typeMismatch }
       self.logIndex = logIndex
       
       let removed = try decodeHexToBigUInt(container, key: .removed, allowOptional: true)
       if removed == 1 {
           self.removed = true
       } else {
           self.removed = false
       }
   
       let topicsStrings = try container.decode([String].self, forKey: .topics)
       var allTopics = [Data]()
       for top in topicsStrings {
           guard let topic = Data.fromHex(top) else { throw DecodeError.typeMismatch }
           allTopics.append(topic)
       }
       self.topics = allTopics
   }

   public init? (_ json: [String: AnyObject]) {
       guard let ad = json["address"] as? String else { return nil }
       guard let d = json["data"] as? String else { return nil }
       guard let li = json["logIndex"] as? String else { return nil }
       let rm = json["removed"] as? Int ?? 0
       guard let tpc = json["topics"] as? [String] else { return nil }
       guard let addr = EthereumAddress(ad) else { return nil }
       address = addr
       guard let txhash = json["transactionHash"] as? String else { return nil }
       let hash = Data.fromHex(txhash)
       if hash != nil {
           transactionHash = hash!
       } else {
           transactionHash = Data()
       }
       data = Data.fromHex(d)!
       guard let liUnwrapped = BigUInt(li.stripHexPrefix(), radix: 16) else { return nil }
       logIndex = liUnwrapped
       removed = rm == 1 ? true : false
       var tops = [Data]()
       for t in tpc {
           guard let topic = Data.fromHex(t) else { return nil }
           tops.append(topic)
       }
       topics = tops
       // TODO
       blockNumber = 0
       blockHash = Data()
       transactionIndex = 0
   }
}

public enum TransactionInBlock: Decodable {
   case hash(Data)
   case transaction(EthereumTransaction)
   case null
   
   public init(from decoder: Decoder) throws {
       let value = try decoder.singleValueContainer()
       if let string = try? value.decode(String.self) {
           guard let d = Data.fromHex(string) else { throw DecodeError.typeMismatch }
           self = .hash(d)
       } else if let dict = try? value.decode([String: String].self) {
//            guard let t = try? EthereumTransaction(from: decoder) else {throw Web3Error.dataError}
           guard let t = EthereumTransaction.fromJSON(dict) else { throw DecodeError.typeMismatch }
           self = .transaction(t)
       } else {
           self = .null
       }
   }

   public init?(_ data: AnyObject) {
       if let string = data as? String {
           guard let d = Data.fromHex(string) else { return nil }
           self = .hash(d)
       } else if let dict = data as? [String: AnyObject] {
           guard let t = EthereumTransaction.fromJSON(dict) else { return nil }
           self = .transaction(t)
       } else {
           return nil
       }
   }
}

public struct Block: Decodable {
   public var number: BigUInt
   public var hash: Data
   public var parentHash: Data
   public var nonce: Data?
   public var sha3Uncles: Data
   public var logsBloom: EthereumBloomFilter?
   public var transactionsRoot: Data
   public var stateRoot: Data
   public var receiptsRoot: Data
   public var miner: EthereumAddress?
   public var difficulty: BigUInt
   public var totalDifficulty: BigUInt
   public var extraData: Data
   public var size: BigUInt
   public var gasLimit: BigUInt
   public var gasUsed: BigUInt
   public var timestamp: Date
   public var transactions: [TransactionInBlock]
   public var uncles: [Data]
   
   enum CodingKeys: String, CodingKey {
       case number
       case hash
       case parentHash
       case nonce
       case sha3Uncles
       case logsBloom
       case transactionsRoot
       case stateRoot
       case receiptsRoot
       case miner
       case difficulty
       case totalDifficulty
       case extraData
       case size
       case gasLimit
       case gasUsed
       case timestamp
       case transactions
       case uncles
   }
   
   public init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       guard let number = try decodeHexToBigUInt(container, key: .number) else { throw DecodeError.typeMismatch }
       self.number = number
       
       guard let hash = try decodeHexToData(container, key: .hash) else { throw DecodeError.typeMismatch }
       self.hash = hash
       
       guard let parentHash = try decodeHexToData(container, key: .parentHash) else { throw DecodeError.typeMismatch }
       self.parentHash = parentHash
       
       let nonce = try decodeHexToData(container, key: .nonce, allowOptional: true)
       self.nonce = nonce
       
       guard let sha3Uncles = try decodeHexToData(container, key: .sha3Uncles) else { throw DecodeError.typeMismatch }
       self.sha3Uncles = sha3Uncles
       
       let logsBloomData = try decodeHexToData(container, key: .logsBloom, allowOptional: true)
       var bloom: EthereumBloomFilter?
       if logsBloomData != nil {
           bloom = EthereumBloomFilter(logsBloomData!)
       }
       self.logsBloom = bloom
       
       guard let transactionsRoot = try decodeHexToData(container, key: .transactionsRoot) else { throw DecodeError.typeMismatch }
       self.transactionsRoot = transactionsRoot
       
       guard let stateRoot = try decodeHexToData(container, key: .stateRoot) else { throw DecodeError.typeMismatch }
       self.stateRoot = stateRoot
       
       guard let receiptsRoot = try decodeHexToData(container, key: .receiptsRoot) else { throw DecodeError.typeMismatch }
       self.receiptsRoot = receiptsRoot
       
       let minerAddress = try? container.decode(String.self, forKey: .miner)
       var miner: EthereumAddress?
       if minerAddress != nil {
           guard let minr = EthereumAddress(minerAddress!) else { throw DecodeError.typeMismatch }
           miner = minr
       }
       self.miner = miner
       
       guard let difficulty = try decodeHexToBigUInt(container, key: .difficulty) else { throw DecodeError.typeMismatch }
       self.difficulty = difficulty
       
       guard let totalDifficulty = try decodeHexToBigUInt(container, key: .totalDifficulty) else { throw DecodeError.typeMismatch }
       self.totalDifficulty = totalDifficulty
       
       guard let extraData = try decodeHexToData(container, key: .extraData) else { throw DecodeError.typeMismatch }
       self.extraData = extraData
       
       guard let size = try decodeHexToBigUInt(container, key: .size) else { throw DecodeError.typeMismatch }
       self.size = size
       
       guard let gasLimit = try decodeHexToBigUInt(container, key: .gasLimit) else { throw DecodeError.typeMismatch }
       self.gasLimit = gasLimit
       
       guard let gasUsed = try decodeHexToBigUInt(container, key: .gasUsed) else { throw DecodeError.typeMismatch }
       self.gasUsed = gasUsed
       
       let timestampString = try container.decode(String.self, forKey: .timestamp).stripHexPrefix()
       guard let timestampInt = UInt64(timestampString, radix: 16) else { throw DecodeError.typeMismatch }
       let timestamp = Date(timeIntervalSince1970: TimeInterval(timestampInt))
       self.timestamp = timestamp
       
       let transactions = try container.decode([TransactionInBlock].self, forKey: .transactions)
       self.transactions = transactions
       
       let unclesStrings = try container.decode([String].self, forKey: .uncles)
       var uncles = [Data]()
       for str in unclesStrings {
           guard let d = Data.fromHex(str) else { throw DecodeError.typeMismatch }
           uncles.append(d)
       }
       self.uncles = uncles
   }
}

public struct EventParserResult: EventParserResultProtocol {
   public var eventName: String
   public var transactionReceipt: TransactionReceipt?
   public var contractAddress: EthereumAddress
   public var decodedResult: [String: Any]
   public var eventLog: EventLog?
   
   public init (eventName: String, transactionReceipt: TransactionReceipt?, contractAddress: EthereumAddress, decodedResult: [String: Any]) {
       self.eventName = eventName
       self.transactionReceipt = transactionReceipt
       self.contractAddress = contractAddress
       self.decodedResult = decodedResult
       self.eventLog = nil
   }
}

public struct TransactionSendingResult {
   public var transaction: EthereumTransaction
   public var hash: String
}

public struct EthereumTransaction: CustomStringConvertible {
   public var nonce: BigUInt
   public var gasPrice: BigUInt = BigUInt(0)
   public var gasLimit: BigUInt = BigUInt(0)
   public var to: EthereumAddress
   public var value: BigUInt
   public var data: Data
   public var v: BigUInt = BigUInt(1)
   public var r: BigUInt = BigUInt(0)
   public var s: BigUInt = BigUInt(0)
   var chainID: BigUInt?

   public var inferedChainID: BigUInt? {
       if self.r == BigUInt(0) && self.s == BigUInt(0) {
           return self.v
       } else if self.v == BigUInt(27) || self.v == BigUInt(28) {
           return nil
       } else {
           return ((self.v - BigUInt(1)) / BigUInt(2)) - BigUInt(17)
       }
   }

   public var intrinsicChainID: BigUInt? {
       return self.chainID
   }

   public mutating func UNSAFE_setChainID(_ chainID: BigUInt?) {
       self.chainID = chainID
   }

   public var hash: Data? {
       var encoded: Data
       if inferedChainID != nil {
           guard let enc = encode(forSignature: false, chainID: inferedChainID) else { return nil }
           encoded = enc
       } else {
           guard let enc = encode(forSignature: false, chainID: chainID) else { return nil }
           encoded = enc
       }
       return encoded.sha3(.keccak256)
   }

   public init(gasPrice: BigUInt, gasLimit: BigUInt, to: EthereumAddress, value: BigUInt, data: Data) {
       self.nonce = BigUInt(0)
       self.gasPrice = gasPrice
       self.gasLimit = gasLimit
       self.value = value
       self.data = data
       self.to = to
   }

   public init(to: EthereumAddress, data: Data, options: Web3Options) {
       let defaults = Web3Options.defaultOptions()
       let merged = Web3Options.merge(defaults, with: options)
       self.nonce = BigUInt(0)
       self.gasLimit = merged.gasLimit!
       self.gasPrice = merged.gasPrice!
       self.value = merged.value!
       self.to = to
       self.data = data
   }

   public init (nonce: BigUInt, gasPrice: BigUInt, gasLimit: BigUInt, to: EthereumAddress, value: BigUInt, data: Data, v: BigUInt, r: BigUInt, s: BigUInt) {
       self.nonce = nonce
       self.gasPrice = gasPrice
       self.gasLimit = gasLimit
       self.to = to
       self.value = value
       self.data = data
       self.v = v
       self.r = r
       self.s = s
   }

   public func mergedWithOptions(_ options: Web3Options) -> EthereumTransaction {
       var tx = self
       if let gasPrice = options.gasPrice {
           tx.gasPrice = gasPrice
       }
       if let gasLimit = options.gasLimit {
           tx.gasLimit = gasLimit
       }
       if let value = options.value {
           tx.value = value
       }
       if let to = options.to {
           tx.to = to
       }
       return tx
   }

   public var description: String {
       var toReturn = ""
       toReturn += "Transaction" + "\n"
       toReturn += "Nonce: " + String(self.nonce) + "\n"
       toReturn += "Gas price: " + String(self.gasPrice) + "\n"
       toReturn += "Gas limit: " + String(describing: self.gasLimit) + "\n"
       toReturn += "To: " + self.to.address  + "\n"
       toReturn += "Value: " + String(self.value) + "\n"
       toReturn += "Data: " + self.data.toHexString().addHexPrefix().lowercased() + "\n"
       toReturn += "v: " + String(self.v) + "\n"
       toReturn += "r: " + String(self.r) + "\n"
       toReturn += "s: " + String(self.s) + "\n"
       toReturn += "Intrinsic chainID: " + String(describing: self.chainID) + "\n"
       toReturn += "Infered chainID: " + String(describing: self.inferedChainID) + "\n"
       toReturn += "sender: " + String(describing: self.sender?.address)  + "\n"
       toReturn += "hash: " + String(describing: self.hash?.toHexString().addHexPrefix()) + "\n"

       return toReturn
   }
   public var sender: EthereumAddress? {
       guard let publicKey = self.recoverPublicKey() else { return nil }
       return Web3.Utils.publicToAddress(publicKey)
   }

   public func recoverPublicKey() -> Data? {
       if self.r == BigUInt(0) && self.s == BigUInt(0) {
           return nil
       }
       var normalizedV: BigUInt = BigUInt(0)
       let inferedChainID = self.inferedChainID
       if self.chainID != nil && self.chainID != BigUInt(0) {
           normalizedV = self.v - BigUInt(35) - self.chainID! - self.chainID!
       } else if inferedChainID != nil {
           normalizedV = self.v - BigUInt(35) - inferedChainID! - inferedChainID!
       } else {
           normalizedV = self.v - BigUInt(27)
       }
       guard let vData = normalizedV.serialize().setLengthLeft(1) else { return nil }
       guard let rData = r.serialize().setLengthLeft(32) else { return nil }
       guard let sData = s.serialize().setLengthLeft(32) else { return nil }
       guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else { return nil }
       var hash: Data
       if inferedChainID != nil {
           guard let h = self.hashForSignature(chainID: inferedChainID) else { return nil }
           hash = h
       } else {
           guard let h = self.hashForSignature(chainID: self.chainID) else { return nil }
           hash = h
       }
       return SECP256K1.recoverPublicKey(hash: hash, signature: signatureData)
   }

   public var txhash: String? {
       guard self.sender != nil else { return nil }
       guard let hash = self.hash else { return nil }

       return hash.toHexString().addHexPrefix().lowercased()
   }

   public var txid: String? {
       return self.txhash
   }

   public func encode(forSignature: Bool = false, chainID: BigUInt? = nil) -> Data? {
       if forSignature {
           if chainID != nil {
               let fields = [self.nonce, self.gasPrice, self.gasLimit, self.to.addressData, self.value, self.data, chainID!, BigUInt(0), BigUInt(0)] as [Any]
               return RLP.encode(fields)
           } else if self.chainID != nil {
               let fields = [self.nonce, self.gasPrice, self.gasLimit, self.to.addressData, self.value, self.data, self.chainID!, BigUInt(0), BigUInt(0)] as [Any]
               return RLP.encode(fields)
           } else {
               let fields = [self.nonce, self.gasPrice, self.gasLimit, self.to.addressData, self.value, self.data] as [AnyObject]
               return RLP.encode(fields)
           }
       } else {
           let fields = [self.nonce, self.gasPrice, self.gasLimit, self.to.addressData, self.value, self.data, self.v, self.r, self.s] as [AnyObject]
           return RLP.encode(fields)
       }
   }

   public func encodeAsDictionary(from: EthereumAddress? = nil) -> TransactionParameters {
       var toString: String?
       switch self.to.type {
       case .normal:
           toString = self.to.address.lowercased()
       case .contractDeployment:
           break
       }
       var params = TransactionParameters(from: from?.address.lowercased(), to: toString)
       let gasEncoding = self.gasLimit.abiEncode(bits: 256)
       params.gas = gasEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
       let gasPriceEncoding = self.gasPrice.abiEncode(bits: 256)
       params.gasPrice = gasPriceEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
       let valueEncoding = self.value.abiEncode(bits: 256)
       params.value = valueEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
       if self.data != Data() {
           params.data = self.data.toHexString().addHexPrefix()
       } else {
           params.data = "0x"
       }
       return params
   }

   public func hashForSignature(chainID: BigUInt? = nil) -> Data? {
       guard let encoded = self.encode(forSignature: true, chainID: chainID) else { return nil }
       return encoded.sha3(.keccak256)
   }

   static func fromJSON(_ json: [String: Any]) -> EthereumTransaction? {
       guard let options = Web3Options.fromJSON(json) else { return nil }
       guard let toString = json["to"] as? String else { return nil }
       var to: EthereumAddress
       if toString == "0x" || toString == "0x0" {
           to = EthereumAddress.contractDeploymentAddress()
       } else {
           guard let ethAddr = EthereumAddress(toString) else { return nil }
           to = ethAddr
       }
//        if (!to.isValid) {
//            return nil
//        }
       var dataString = json["data"] as? String
       if dataString == nil {
           dataString = json["input"] as? String
       }
       guard dataString != nil, let data = Data.fromHex(dataString!) else { return nil }
       var transaction = EthereumTransaction(to: to, data: data, options: options)
       if let nonceString = json["nonce"] as? String {
           guard let nonce = BigUInt(nonceString.stripHexPrefix(), radix: 16) else { return nil }
           transaction.nonce = nonce
       }
       if let vString = json["v"] as? String {
           guard let v = BigUInt(vString.stripHexPrefix(), radix: 16) else { return nil }
           transaction.v = v
       }
       if let rString = json["r"] as? String {
           guard let r = BigUInt(rString.stripHexPrefix(), radix: 16) else { return nil }
           transaction.r = r
       }
       if let sString = json["s"] as? String {
           guard let s = BigUInt(sString.stripHexPrefix(), radix: 16) else { return nil }
           transaction.s = s
       }
       if let valueString = json["value"] as? String {
           guard let value = BigUInt(valueString.stripHexPrefix(), radix: 16) else { return nil }
           transaction.value = value
       }
       let inferedChainID = transaction.inferedChainID
       if transaction.inferedChainID != nil && transaction.v >= BigUInt(37) {
           transaction.chainID = inferedChainID
       }
//        let hash = json["hash"] as? String
//        if hash != nil {
//            let calculatedHash = transaction.hash
//            let receivedHash = Data.fromHex(hash!)
//            if (receivedHash != calculatedHash) {
//                print("hash mismatch, dat")
//                print(String(describing: transaction))
//                print(json)
//                return nil
//            }
//        }
       return transaction
   }

   static func fromRaw(_ raw: Data) -> EthereumTransaction? {
       guard let totalItem = RLP.decode(raw) else { return nil }
       guard let rlpItem = totalItem[0] else { return nil }
       switch rlpItem.count {
       case 9?:
           guard let nonceData = rlpItem[0]!.data else { return nil }
           let nonce = BigUInt(nonceData)
           guard let gasPriceData = rlpItem[1]!.data else { return nil }
           let gasPrice = BigUInt(gasPriceData)
           guard let gasLimitData = rlpItem[2]!.data else { return nil }
           let gasLimit = BigUInt(gasLimitData)
           var to: EthereumAddress
           switch rlpItem[3]!.content {
           case .noItem:
               to = EthereumAddress.contractDeploymentAddress()
           case .data(let addressData):
               if addressData.isEmpty {
                   to = EthereumAddress.contractDeploymentAddress()
               } else if addressData.count == 20 {
                   guard let addr = EthereumAddress(addressData) else { return nil }
                   to = addr
               } else {
                   return nil
               }
           case .list:
               return nil
           }
           guard let valueData = rlpItem[4]!.data else { return nil }
           let value = BigUInt(valueData)
           guard let transactionData = rlpItem[5]!.data else { return nil }
           guard let vData = rlpItem[6]!.data else { return nil }
           let v = BigUInt(vData)
           guard let rData = rlpItem[7]!.data else { return nil }
           let r = BigUInt(rData)
           guard let sData = rlpItem[8]!.data else { return nil }
           let s = BigUInt(sData)
           return EthereumTransaction.init(nonce: nonce, gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: transactionData, v: v, r: r, s: s)
       case 6?:
           return nil
       default:
           return nil
       }
   }

   static func createRequest(method: JSONRPCmethod, transaction: EthereumTransaction, onBlock: String? = nil, options: Web3Options?) -> JSONRPCrequest? {
       var txParams = transaction.encodeAsDictionary(from: options?.from)
       if method == .estimateGas || options?.gasLimit == nil {
           txParams.gas = nil
       }
       if let excludeZeroGasPrice = options?.excludeZeroGasPrice, excludeZeroGasPrice && txParams.gasPrice == "0x0" {
           txParams.gasPrice = nil
       }
       var params = [txParams] as [Encodable]
       if method.requiredNumOfParameters == 2 && onBlock != nil {
           params.append(onBlock as Encodable)
       }
       let request = JSONRPCrequest(method: method, params: JSONRPCparams(params: params))
       if !request.isValid { return nil }

       return request
   }

   static func createRawTransaction(transaction: EthereumTransaction) -> JSONRPCrequest? {
       guard transaction.sender != nil else { return nil }
       guard let encodedData = transaction.encode() else { return nil }
       let hex = encodedData.toHexString().addHexPrefix().lowercased()
       let request = JSONRPCrequest(method: JSONRPCmethod.sendRawTransaction, params: JSONRPCparams(params: [hex]))
       if !request.isValid { return nil }
       return request
   }
}
protocol ArrayType {}
extension Array: ArrayType {}

struct RLP {
   static var length56 = BigUInt(UInt(56))
   static var lengthMax = (BigUInt(UInt(1)) << 256)

   static func encode(_ element: AnyObject) -> Data? {
       if let string = element as? String {
           return encode(string)

       } else if let data = element as? Data {
           return encode(data)
       } else if let biguint = element as? BigUInt {
           return encode(biguint)
       }
       return nil
   }

   internal static func encode(_ string: String) -> Data? {
       if let hexData = Data.fromHex(string) {
           return encode(hexData)
       }
       guard let data = string.data(using: .utf8) else { return nil }
       return encode(data)
   }

   internal static func encode(_ number: Int) -> Data? {
       guard number >= 0 else { return nil }
       let uint = UInt(number)
       return encode(uint)
   }

   internal static func encode(_ number: UInt) -> Data? {
       let biguint = BigUInt(number)
       return encode(biguint)
   }

   internal static func encode(_ number: BigUInt) -> Data? {
       let encoded = number.serialize()
       return encode(encoded)
   }

//    internal static func encode(_ unstrippedData: Data) -> Data? {
//        var startIndex = 0;
//        for i in 0..<unstrippedData.count{
//            if unstrippedData[i] != 0x00 {
//                startIndex = i
//                break
//            }
//        }
//        let data = unstrippedData[startIndex ..< unstrippedData.count]
   internal static func encode(_ data: Data) -> Data? {
       if data.count == 1 && data.bytes[0] < UInt8(0x80) {
           return data
       } else {
           guard let length = encodeLength(data.count, offset: UInt8(0x80)) else { return nil }
           var encoded = Data()
           encoded.append(length)
           encoded.append(data)
           return encoded
       }
   }

   internal static func encodeLength(_ length: Int, offset: UInt8) -> Data? {
       if length < 0 {
           return nil
       }
       let bigintLength = BigUInt(UInt(length))
       return encodeLength(bigintLength, offset: offset)
   }

   internal static func encodeLength(_ length: BigUInt, offset: UInt8) -> Data? {
       if length < length56 {
           let encodedLength = length + BigUInt(UInt(offset))
           guard encodedLength.bitWidth <= 8 else { return nil }
           return encodedLength.serialize()
       } else if length < lengthMax {
           let encodedLength = length.serialize()
           let len = BigUInt(UInt(encodedLength.count))
           guard let prefix = lengthToBinary(len) else { return nil }
           let lengthPrefix = prefix + offset + UInt8(55)
           var encoded = Data([lengthPrefix])
           encoded.append(encodedLength)
           return encoded
       }
       return nil
   }

   internal static func lengthToBinary(_ length: BigUInt) -> UInt8? {
       if length == 0 {
           return UInt8(0)
       }
       let divisor = BigUInt(256)
       var encoded = Data()
       guard let prefix = lengthToBinary(length/divisor) else { return nil }
       let suffix = length % divisor

       var prefixData = Data([prefix])
       if prefix == UInt8(0) {
           prefixData = Data()
       }
       let suffixData = suffix.serialize()

       encoded.append(prefixData)
       encoded.append(suffixData)
       guard encoded.count == 1 else { return nil }
       return encoded.bytes[0]
   }

   static func encode(_ elements: [AnyObject]) -> Data? {
       var encodedData = Data()
       for e in elements {
           guard let encoded = encode(e) else { return nil }
           encodedData.append(encoded)
       }
       guard var encodedLength = encodeLength(encodedData.count, offset: UInt8(0xc0)) else { return nil }
       if encodedLength != Data() {
           encodedLength.append(encodedData)
       }
       return encodedLength
   }

   static func encode(_ elements: [Any]) -> Data? {
       var encodedData = Data()
       for el in elements {
           let e = el as AnyObject
           guard let encoded = encode(e) else { return nil }
           encodedData.append(encoded)
       }
       guard var encodedLength = encodeLength(encodedData.count, offset: UInt8(0xc0)) else { return nil }
       if encodedLength != Data() {
           encodedLength.append(encodedData)
       }
       return encodedLength
   }

   static func decode(_ raw: String) -> RLPItem? {
       guard let rawData = Data.fromHex(raw) else { return nil }
       return decode(rawData)
   }

   static func decode(_ raw: Data) -> RLPItem? {
       if raw.isEmpty {
           return RLPItem.noItem
       }
       var outputArray = [RLPItem]()
       var bytesToParse = raw
       while !bytesToParse.isEmpty {
           let (of, dl, t) = decodeLength(bytesToParse)
           guard let offset = of, let dataLength = dl, let type = t else { return nil }
           switch type {
           case .empty:
               break
           case .data:
               guard let slice = try? slice(data: bytesToParse, offset: offset, length: dataLength) else { return nil }
               let data = Data(slice)
               let rlpItem = RLPItem.init(content: .data(data))
               outputArray.append(rlpItem)
           case .list:
               guard let slice = try? slice(data: bytesToParse, offset: offset, length: dataLength) else { return nil }
               guard let inside = decode(Data(slice)) else { return nil }
               switch inside.content {
               case .data:
                   return nil
               default:
                   outputArray.append(inside)
               }
           }
           guard let tail = try? slice(data: bytesToParse, start: offset + dataLength) else { return nil }
           bytesToParse = tail
       }
       return RLPItem.init(content: .list(outputArray, 0))
   }

   enum UnderlyingType {
       case empty
       case data
       case list
   }

   struct RLPItem {

       enum RLPContent {
           case noItem
           case data(Data)
           indirect case list([RLPItem], Int)
       }

       var content: RLPContent

       var isData: Bool {
           switch self.content {
           case .noItem:
               return false
           case .data:
               return true
           case .list:
               return false
           }
       }

       var isList: Bool {
           switch self.content {
           case .noItem:
               return false
           case .data:
               return false
           case .list:
               return true
           }
       }
       var count: Int? {
           switch self.content {
           case .noItem:
               return nil
           case .data:
               return nil
           case .list(let list, _):
               return list.count
           }
       }
       var hasNext: Bool {
           switch self.content {
           case .noItem:
               return false
           case .data:
               return false
           case .list(let list, let counter):
               return list.count > counter
           }
       }

       subscript(index: Int) -> RLPItem? {
           guard self.hasNext else { return nil }
           guard case .list(let list, _) = self.content else { return nil }
           return list[index]
       }

       var data: Data? {
           return self.getData()
       }

       func getData() -> Data? {
           if self.isList {
               return nil
           }
           guard case .data(let data) = self.content else { return nil }
           return data
       }

       static var noItem: RLPItem {
           return RLPItem.init(content: .noItem)
       }
   }

   internal static func decodeLength(_ input: Data) -> (offset: BigUInt?, length: BigUInt?, type: UnderlyingType?) {
       do {
           let length = BigUInt(input.count)
           if length == BigUInt(0) {
               return (0, 0, .empty)
           }
           let prefixByte = input[0]
           if prefixByte <= 0x7f {
               return (BigUInt(0), BigUInt(1), .data)
           } else if prefixByte <= 0xb7 && length > BigUInt(prefixByte - 0x80) {
               let dataLength = BigUInt(prefixByte - 0x80)
               return (BigUInt(1), dataLength, .data)
           } else if try prefixByte <= 0xbf && length > BigUInt(prefixByte - 0xb7) && length >  BigUInt(prefixByte - 0xb7) + toBigUInt(slice(data: input, offset: BigUInt(1), length: BigUInt(prefixByte - 0xb7))) {
               let lengthOfLength = BigUInt(prefixByte - 0xb7)
               let dataLength = try toBigUInt(slice(data: input, offset: BigUInt(1), length: BigUInt(prefixByte - 0xb7)))
               return (1 + lengthOfLength, dataLength, .data)
           } else if prefixByte <= 0xf7 && length > BigUInt(prefixByte - 0xc0) {
               let listLen = BigUInt(prefixByte - 0xc0)
               return (1, listLen, .list)
           } else if try prefixByte <= 0xff && length > BigUInt(prefixByte - 0xf7) && length > BigUInt(prefixByte - 0xf7) + toBigUInt(slice(data: input, offset: BigUInt(1), length: BigUInt(prefixByte - 0xf7))) {
               let lengthOfListLength = BigUInt(prefixByte - 0xf7)
               let listLength = try toBigUInt(slice(data: input, offset: BigUInt(1), length: BigUInt(prefixByte - 0xf7)))
               return (1 + lengthOfListLength, listLength, .list)
           } else {
               return (nil, nil, nil)
           }
       } catch {
           return (nil, nil, nil)
       }
   }

   internal static func slice(data: Data, offset: BigUInt, length: BigUInt) throws -> Data {
       if BigUInt(data.count) < offset + length { throw DecodeError.initFailure }
       let slice = data[UInt64(offset) ..< UInt64(offset + length)]
       return Data(slice)
   }

   internal static func slice(data: Data, start: BigUInt) throws -> Data {
       if BigUInt(data.count) < start { throw DecodeError.initFailure }
       let slice = data[UInt64(start) ..< UInt64(data.count)]
       return Data(slice)
   }

   internal static func toBigUInt(_ raw: Data) throws -> BigUInt {
       if raw.isEmpty {
           throw DecodeError.initFailure
       } else if raw.count == 1 {
           return BigUInt.init(raw)
       } else {
           let slice = raw[0 ..< raw.count - 1]
           return try BigUInt(raw[raw.count-1]) + toBigUInt(slice)*256
       }
   }
}
extension BigUInt {
   func abiEncode(bits: UInt64) -> Data? {
       let data = self.serialize()
       let paddedLength = UInt64(ceil((Double(bits)/8.0)))
       let padded = data.setLengthLeft(paddedLength)
       return padded
   }
}

extension BigInt {
   func abiEncode(bits: UInt64) -> Data? {
       let isNegative = self < (BigInt(0))
       let data = self.toTwosComplement()
       let paddedLength = UInt64(ceil((Double(bits)/8.0)))
       let padded = data.setLengthLeft(paddedLength, isNegative: isNegative)
       return padded
   }
}
extension Data {
   func setLengthLeft(_ toBytes: UInt64, isNegative: Bool = false ) -> Data? {
       let existingLength = UInt64(self.count)
       if existingLength == toBytes {
           return Data(self)
       } else if existingLength > toBytes {
           return nil
       }
       var data: Data
       if isNegative {
           data = Data(repeating: UInt8(255), count: Int(toBytes - existingLength))
       } else {
           data = Data(repeating: UInt8(0), count: Int(toBytes - existingLength))
       }
       data.append(self)

       return data
   }
   
   func setLengthRight(_ toBytes: UInt64, isNegative: Bool = false ) -> Data? {
       let existingLength = UInt64(self.count)
       if existingLength == toBytes {
           return Data(self)
       } else if existingLength > toBytes {
           return nil
       }
       var data = Data()
       data.append(self)
       if isNegative {
           data.append(Data(repeating: UInt8(255), count: Int(toBytes - existingLength)))
       } else {
           data.append(Data(repeating: UInt8(0), count: Int(toBytes - existingLength)))
       }

       return data
   }
}
extension BigInt {
   func toTwosComplement() -> Data {
       if self.sign == BigInt.Sign.plus {
           return self.magnitude.serialize()
       } else {
           let serializedLength = self.magnitude.serialize().count
           let MAX = BigUInt(1) << (serializedLength*8)
           let twoComplement = MAX - self.magnitude
           return twoComplement.serialize()
       }
   }
}
public struct SECP256K1 {
   public struct UnmarshaledSignature {
       var v: UInt8
       var r = [UInt8](repeating: 0, count: 32)
       var s = [UInt8](repeating: 0, count: 32)
   }

   static var secp256k1_N  = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
   static var secp256k1_halfN = secp256k1_N >> 2
}

extension SECP256K1 {
   static var context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY))

   static func signForRecovery(hash: Data, privateKey: Data, useExtraEntropy: Bool = true) -> (serializedSignature: Data?, rawSignature: Data?) {
       if hash.count != 32 || privateKey.count != 32 { return (nil, nil) }
       if !SECP256K1.verifyPrivateKey(privateKey: privateKey) {
           return (nil, nil)
       }
       for _ in 0...1024 {
           guard var recoverableSignature = SECP256K1.recoverableSign(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy) else {
               continue
           }
           guard let truePublicKey = SECP256K1.privateKeyToPublicKey(privateKey: privateKey) else { continue }
           guard let recoveredPublicKey = SECP256K1.recoverPublicKey(hash: hash, recoverableSignature: &recoverableSignature) else { continue }
           if Data(toByteArray(truePublicKey.data)) != Data(toByteArray(recoveredPublicKey.data)) {
               print("Didn't recover correctly!")
               continue
           }
           guard let serializedSignature = SECP256K1.serializeSignature(recoverableSignature: &recoverableSignature) else { continue }
           let rawSignature = Data(toByteArray(recoverableSignature))
           return (serializedSignature, rawSignature)
               //            print("Signature required \(rounds) rounds")
       }
       print("Signature required 1024 rounds and failed")
       return (nil, nil)
   }

   static func privateToPublic(privateKey: Data, compressed: Bool = false) -> Data? {
       if privateKey.count != 32 { return nil }
       guard var publicKey = SECP256K1.privateKeyToPublicKey(privateKey: privateKey) else { return nil }
       guard let serializedKey = serializePublicKey(publicKey: &publicKey, compressed: compressed) else { return nil }
       return serializedKey
   }

   static func combineSerializedPublicKeys(keys: [Data], outputCompressed: Bool = false) -> Data? {
       let numToCombine = keys.count
       guard numToCombine >= 1 else { return nil }
       var storage = ContiguousArray<secp256k1_pubkey>()
       let arrayOfPointers = UnsafeMutablePointer< UnsafePointer<secp256k1_pubkey>? >.allocate(capacity: numToCombine)
       defer {
           arrayOfPointers.deinitialize(count: numToCombine)
           arrayOfPointers.deallocate()
       }
       for i in 0 ..< numToCombine {
           let key = keys[i]
           guard let pubkey = SECP256K1.parsePublicKey(serializedKey: key) else { return nil }
           storage.append(pubkey)
       }
       for i in 0 ..< numToCombine {
           withUnsafePointer(to: &storage[i]) { (ptr) -> Void in
               arrayOfPointers.advanced(by: i).pointee = ptr
           }
       }
       let immutablePointer = UnsafePointer(arrayOfPointers)
       var publicKey: secp256k1_pubkey = secp256k1_pubkey()

           //        let bufferPointer = UnsafeBufferPointer(start: immutablePointer, count: numToCombine)
           //        for (index, value) in bufferPointer.enumerated() {
           //            print("pointer value \(index): \(value!)")
           //            let val = value?.pointee
           //            print("value \(index): \(val!)")
           //        }
           //
       let result = withUnsafeMutablePointer(to: &publicKey) { (pubKeyPtr: UnsafeMutablePointer<secp256k1_pubkey>) -> Int32 in
           let res = secp256k1_ec_pubkey_combine(context!, pubKeyPtr, immutablePointer, numToCombine)
           return res
       }
       if result == 0 {
           return nil
       }
       let serializedKey = SECP256K1.serializePublicKey(publicKey: &publicKey, compressed: outputCompressed)
       return serializedKey
   }

   static func recoverPublicKey(hash: Data, recoverableSignature: inout secp256k1_ecdsa_recoverable_signature) -> secp256k1_pubkey? {
       guard hash.count == 32 else { return nil }
       var publicKey: secp256k1_pubkey = secp256k1_pubkey()
       let result = hash.withUnsafeBytes { hashPointer -> Int32 in
           withUnsafePointer(to: &recoverableSignature, { signaturePointer -> Int32 in
               withUnsafeMutablePointer(to: &publicKey, { pubKeyPtr -> Int32 in
                   return secp256k1_ecdsa_recover(context!, pubKeyPtr, signaturePointer, hashPointer)
               })
           })
       }
       if result == 0 {
           return nil
       }
       return publicKey
   }

   static func privateKeyToPublicKey(privateKey: Data) -> secp256k1_pubkey? {
       if privateKey.count != 32 { return nil }
       var publicKey = secp256k1_pubkey()
       let result = privateKey.withUnsafeBytes { privateKeyPointer -> Int32 in
           return secp256k1_ec_pubkey_create(context!, UnsafeMutablePointer<secp256k1_pubkey>(&publicKey), privateKeyPointer)
       }
       if result == 0 {
           return nil
       }
       return publicKey
   }

   static func serializePublicKey(publicKey: inout secp256k1_pubkey, compressed: Bool = false) -> Data? {
       var keyLength = compressed ? 33 : 65
       var serializedPubkey = Data(repeating: 0x00, count: keyLength)
       let result = serializedPubkey.withUnsafeMutableBytes { (serializedPubkeyPointer: UnsafeMutablePointer<UInt8>) -> Int32 in
           withUnsafeMutablePointer(to: &keyLength, { keyPtr -> Int32 in
               withUnsafeMutablePointer(to: &publicKey, { pubKeyPtr -> Int32 in
                   return secp256k1_ec_pubkey_serialize(context!, serializedPubkeyPointer, keyPtr, pubKeyPtr, UInt32(compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED))
               })
           })
       }

       if result == 0 {
           return nil
       }
       return Data(serializedPubkey)
   }

   static func parsePublicKey(serializedKey: Data) -> secp256k1_pubkey? {
       guard serializedKey.count == 33 || serializedKey.count == 65 else {
           return nil
       }
       let keyLen: Int = Int(serializedKey.count)
       var publicKey = secp256k1_pubkey()
       let result = serializedKey.withUnsafeBytes { serializedKeyPointer -> Int32 in
           return secp256k1_ec_pubkey_parse(context!, UnsafeMutablePointer<secp256k1_pubkey>(&publicKey), serializedKeyPointer, keyLen)
       }
       if result == 0 {
           return nil
       }
       return publicKey
   }

   static func parseSignature(signature: Data) -> secp256k1_ecdsa_recoverable_signature? {
       guard signature.count == 65 else { return nil }
       var recoverableSignature: secp256k1_ecdsa_recoverable_signature = secp256k1_ecdsa_recoverable_signature()
       let serializedSignature = Data(signature[0..<64])
       let v = Int32(signature[64])
       let result = serializedSignature.withUnsafeBytes { serPtr -> Int32 in
           withUnsafeMutablePointer(to: &recoverableSignature, { signaturePointer -> Int32 in
               return secp256k1_ecdsa_recoverable_signature_parse_compact(context!, signaturePointer, serPtr, v)
           })
       }
       if result == 0 {
           return nil
       }
       return recoverableSignature
   }

   static func serializeSignature(recoverableSignature: inout secp256k1_ecdsa_recoverable_signature) -> Data? {
       var serializedSignature = Data(repeating: 0x00, count: 64)
       var v: Int32 = 0
       let result = serializedSignature.withUnsafeMutableBytes { serSignaturePointer -> Int32 in
           withUnsafePointer(to: &recoverableSignature) { signaturePointer -> Int32 in
               withUnsafeMutablePointer(to: &v, { vPtr -> Int32 in
                   return secp256k1_ecdsa_recoverable_signature_serialize_compact(context!, serSignaturePointer, vPtr, signaturePointer)
               })
           }
       }
       if result == 0 {
           return nil
       }
       if v == 0 {
           serializedSignature.append(0x00)
       } else if v == 1 {
           serializedSignature.append(0x01)
       } else {
           return nil
       }
       return Data(serializedSignature)
   }

   static func recoverableSign(hash: Data, privateKey: Data, useExtraEntropy: Bool = true) -> secp256k1_ecdsa_recoverable_signature? {
       if hash.count != 32 || privateKey.count != 32 {
           return nil
       }
       if !SECP256K1.verifyPrivateKey(privateKey: privateKey) {
           return nil
       }
       var recoverableSignature: secp256k1_ecdsa_recoverable_signature = secp256k1_ecdsa_recoverable_signature()
       guard let extraEntropy = Data.randomBytes(length: 32) else { return nil }
       let result = hash.withUnsafeBytes { hashPointer -> Int32 in
           privateKey.withUnsafeBytes { privateKeyPointer -> Int32 in
               extraEntropy.withUnsafeBytes { extraEntropyPointer -> Int32 in
                   withUnsafeMutablePointer(to: &recoverableSignature, { recSignaturePtr -> Int32 in
                       return secp256k1_ecdsa_sign_recoverable(context!, recSignaturePtr, hashPointer, privateKeyPointer, nil, useExtraEntropy ? extraEntropyPointer : nil)
                   })
               }
           }
       }
       if result == 0 {
           print("Failed to sign!")
           return nil
       }
       return recoverableSignature
   }

   static func recoverPublicKey(hash: Data, signature: Data, compressed: Bool = false) -> Data? {
       guard hash.count == 32, signature.count == 65 else { return nil }
       guard var recoverableSignature = parseSignature(signature: signature) else { return nil }
       guard var publicKey = SECP256K1.recoverPublicKey(hash: hash, recoverableSignature: &recoverableSignature) else { return nil }
       guard let serializedKey = SECP256K1.serializePublicKey(publicKey: &publicKey, compressed: compressed) else { return nil }
       return serializedKey
   }

   static func verifyPrivateKey(privateKey: Data) -> Bool {
       if privateKey.count != 32 { return false }
       let result = privateKey.withUnsafeBytes { privateKeyPointer -> Int32 in
           return secp256k1_ec_seckey_verify(context!, privateKeyPointer)
       }
       return result == 1
   }

   static func generatePrivateKey() -> Data? {
       for _ in 0...1024 {
           guard let keyData = Data.randomBytes(length: 32) else {
               continue
           }
           return keyData
       }
       return nil
   }

   static func unmarshalSignature(signatureData: Data) -> UnmarshaledSignature? {
       if signatureData.count != 65 { return nil }
       let bytes = signatureData.bytes
       let r = Array(bytes[0..<32])
       let s = Array(bytes[32..<64])
       return UnmarshaledSignature(v: bytes[64], r: r, s: s)
   }

   static func marshalSignature(v: UInt8, r: [UInt8], s: [UInt8]) -> Data? {
       guard r.count == 32, s.count == 32 else { return nil }
       var completeSignature = Data(bytes: r)
       completeSignature.append(Data(bytes: s))
       completeSignature.append(Data(bytes: [v]))
       return completeSignature
   }

   static func marshalSignature(v: Data, r: Data, s: Data) -> Data? {
       guard r.count == 32, s.count == 32 else { return nil }
       var completeSignature = Data(r)
       completeSignature.append(s)
       completeSignature.append(v)
       return completeSignature
   }
}

func toByteArray<T>(_ value: T) -> [UInt8] {
   var value = value
   return withUnsafeBytes(of: &value) { Array($0) }
}

func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
   return value.withUnsafeBytes {
       $0.baseAddress!.load(as: T.self)
   }
}


extension Web3 {
   public struct Utils { }
}

extension Web3.Utils {
   public static func calculateContractAddress(from: EthereumAddress, nonce: BigUInt) -> EthereumAddress? {
       guard let normalizedAddress = from.addressData.setLengthLeft(32) else { return nil }
       guard let data = RLP.encode([normalizedAddress, nonce] as [Any]) else { return nil }
       guard let contractAddressData = Web3.Utils.sha3(data)?[12..<32] else { return nil }

       return EthereumAddress(Data(contractAddressData))
   }

   public enum Units {
       case eth
       case wei
       case Kwei
       case Mwei
       case Gwei
       case Microether
       case Finney

       var decimals: Int {
           switch self {
           case .eth:
               return 18
           case .wei:
               return 0
           case .Kwei:
               return 3
           case .Mwei:
               return 6
           case .Gwei:
               return 9
           case .Microether:
               return 12
           case .Finney:
               return 15
           }
       }
   }

   public static var coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
   public static var erc20ABI = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
}

extension Web3.Utils {

   public static func privateToPublic(_ privateKey: Data, compressed: Bool = false) -> Data? {
       guard let publicKey = SECP256K1.privateToPublic(privateKey: privateKey, compressed: compressed) else { return nil }
       return publicKey
   }

   public static func publicToAddressData(_ publicKey: Data) -> Data? {
       if publicKey.count == 33 {
           guard let decompressedKey = SECP256K1.combineSerializedPublicKeys(keys: [publicKey], outputCompressed: false) else { return nil }
           return publicToAddressData(decompressedKey)
       }
       var stipped = publicKey
       if stipped.count == 65 {
           if stipped[0] != 4 {
               return nil
           }
           stipped = stipped[1...64]
       }
       if stipped.count != 64 {
           return nil
       }
       let sha3 = stipped.sha3(.keccak256)
       let addressData = sha3[12...31]
       return addressData
   }

   public static func publicToAddress(_ publicKey: Data) -> EthereumAddress? {
       guard let addressData = Web3.Utils.publicToAddressData(publicKey) else { return nil }
       let address = addressData.toHexString().addHexPrefix().lowercased()
       return EthereumAddress(address)
   }

   public static func publicToAddressString(_ publicKey: Data) -> String? {
       guard let addressData = Web3.Utils.publicToAddressData(publicKey) else { return nil }
       let address = addressData.toHexString().addHexPrefix().lowercased()
       return address
   }

   public static func addressDataToString(_ addressData: Data) -> String {
       return addressData.toHexString().addHexPrefix().lowercased()
   }

   public static func hashPersonalMessage(_ personalMessage: Data) -> Data? {
       var prefix = "\u{19}Ethereum Signed Message:\n"
       prefix += String(personalMessage.count)
       guard let prefixData = prefix.data(using: .ascii) else { return nil }
       var data = Data()
       if personalMessage.count >= prefixData.count && prefixData == personalMessage[0 ..< prefixData.count] {
           data.append(personalMessage)
       } else {
           data.append(prefixData)
           data.append(personalMessage)
       }

       return data.sha3(.keccak256)
   }

   public static func parseToBigUInt(_ amount: String, units: Web3.Utils.Units = .eth) -> BigUInt? {
       let unitDecimals = units.decimals
       return parseToBigUInt(amount, decimals: unitDecimals)
   }

   public static func parseToBigUInt(_ amount: String, decimals: Int = 18) -> BigUInt? {
       let separators = CharacterSet(charactersIn: ".,")
       let components = amount.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: separators)
       guard components.count == 1 || components.count == 2 else { return nil }
       let unitDecimals = decimals
       guard let beforeDecPoint = BigUInt(components[0], radix: 10) else { return nil }
       var mainPart = beforeDecPoint*BigUInt(10).power(unitDecimals)
       if components.count == 2 {
           let numDigits = components[1].count
           guard numDigits <= unitDecimals else { return nil }
           guard let afterDecPoint = BigUInt(components[1], radix: 10) else { return nil }
           let extraPart = afterDecPoint*BigUInt(10).power(unitDecimals-numDigits)
           mainPart += extraPart
       }
       return mainPart
   }

   public static func formatToEthereumUnits(_ bigNumber: BigInt, toUnits: Web3.Utils.Units = .eth, decimals: Int = 4, decimalSeparator: String = ".") -> String {
       let magnitude = bigNumber.magnitude
       let formatted = formatToEthereumUnits(magnitude, toUnits: toUnits, decimals: decimals, decimalSeparator: decimalSeparator)
       switch bigNumber.sign {
       case .plus:
           return formatted
       case .minus:
           return "-" + formatted
       }
   }

   public static func formatToPrecision(_ bigNumber: BigInt, numberDecimals: Int = 18, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
       let magnitude = bigNumber.magnitude
       let formatted = formatToPrecision(magnitude, numberDecimals: numberDecimals, formattingDecimals: formattingDecimals, decimalSeparator: decimalSeparator, fallbackToScientific: fallbackToScientific)
       switch bigNumber.sign {
       case .plus:
           return formatted
       case .minus:
           return "-" + formatted
       }
   }

   public static func formatToEthereumUnits(_ bigNumber: BigUInt, toUnits: Web3.Utils.Units = .eth, decimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
       return formatToPrecision(bigNumber, numberDecimals: toUnits.decimals, formattingDecimals: decimals, decimalSeparator: decimalSeparator, fallbackToScientific: fallbackToScientific)
   }

   public static func formatToPrecision(_ bigNumber: BigUInt, numberDecimals: Int = 18, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
       if bigNumber == 0 {
           return "0"
       }
       let unitDecimals = numberDecimals
       var toDecimals = formattingDecimals
       if unitDecimals < toDecimals {
           toDecimals = unitDecimals
       }
       let divisor = BigUInt(10).power(unitDecimals)
       let (quotient, remainder) = bigNumber.quotientAndRemainder(dividingBy: divisor)
       let fullRemainder = String(remainder)
       let fullPaddedRemainder = fullRemainder.leftPadding(toLength: unitDecimals, withPad: "0")
       let remainderPadded = fullPaddedRemainder[0 ..< toDecimals]
       if remainderPadded == String(repeating: "0", count: toDecimals) {
           if quotient != 0 {
               return String(quotient)
           } else if fallbackToScientific {
               var firstDigit = 0
               for char in fullPaddedRemainder {
                   if char == "0" {
                       firstDigit += 1
                   } else {
                       firstDigit += 1
                       break
                   }
               }
               return fullRemainder + "e-" + String(firstDigit)
           }
       }
       if toDecimals == 0 {
           return String(quotient)
       }
       return String(quotient) + decimalSeparator + remainderPadded
   }

   static public func personalECRecover(_ personalMessage: String, signature: String) -> EthereumAddress? {
       guard let data = Data.fromHex(personalMessage) else { return nil }
       guard let sig = Data.fromHex(signature) else { return nil }
       return Web3.Utils.personalECRecover(data, signature: sig)
   }

   static public func personalECRecoverPublicKey(message: Data, r: [UInt8], s: [UInt8], v: UInt8) -> Data? {
       guard let signatureData = SECP256K1.marshalSignature(v: v, r: r, s: s) else { return nil }
       guard let hash = Web3.Utils.hashPersonalMessage(message) else { return nil }

       return SECP256K1.recoverPublicKey(hash: hash, signature: signatureData)
   }

   static public func personalECRecover(_ personalMessage: Data, signature: Data) -> EthereumAddress? {
       if signature.count != 65 { return nil }
       let rData = signature[0 ..< 32].bytes
       let sData = signature[32 ..< 64].bytes
       let vData = signature[64]
       guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else { return nil }
       guard let hash = Web3.Utils.hashPersonalMessage(personalMessage) else { return nil }
       guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else { return nil }
       return Web3.Utils.publicToAddress(publicKey)
   }

   static public func hashECRecover(hash: Data, signature: Data) -> EthereumAddress? {
       if signature.count != 65 { return nil }
       let rData = signature[0 ..< 32].bytes
       let sData = signature[32 ..< 64].bytes
       let vData = signature[64]
       guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else { return nil }
       guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else { return nil }
       return Web3.Utils.publicToAddress(publicKey)
   }

   /// returns Ethereum variant of sha3 (keccak256) of data. Returns nil is data is empty
   static public func keccak256(_ data: Data) -> Data? {
       if data.isEmpty { return nil }
       return data.sha3(.keccak256)
   }

   /// returns Ethereum variant of sha3 (keccak256) of data. Returns nil is data is empty
   static public func sha3(_ data: Data) -> Data? {
       if data.isEmpty { return nil }
       return data.sha3(.keccak256)
   }

   /// returns sha256 of data. Returns nil is data is empty
   static public func sha256(_ data: Data) -> Data? {
       if data.isEmpty { return nil }
       return data.sha256()
   }

   static func unmarshalSignature(signatureData: Data) -> SECP256K1.UnmarshaledSignature? {
       if signatureData.count != 65 { return nil }
       let bytes = signatureData.bytes
       let r = Array(bytes[0..<32])
       let s = Array(bytes[32..<64])
       return SECP256K1.UnmarshaledSignature(v: bytes[64], r: r, s: s)
   }

   public static func marshalSignature(v: UInt8, r: [UInt8], s: [UInt8]) -> Data? {
       guard r.count == 32, s.count == 32 else { return nil }
       var completeSignature = Data(bytes: r)
       completeSignature.append(Data(bytes: s))
       completeSignature.append(Data(bytes: [v]))
       return completeSignature
   }

   static func marshalSignature(unmarshalledSignature: SECP256K1.UnmarshaledSignature) -> Data? {
       var completeSignature = Data(bytes: unmarshalledSignature.r)
       completeSignature.append(Data(bytes: unmarshalledSignature.s))
       completeSignature.append(Data(bytes: [unmarshalledSignature.v]))
       return completeSignature
   }
}

public protocol EventParserResultProtocol {
   var eventName: String { get }
   var decodedResult: [String: Any] { get }
   var contractAddress: EthereumAddress { get }
   var transactionReceipt: TransactionReceipt? { get }
   var eventLog: EventLog? { get }
}

public protocol EventParserProtocol {
   func parseTransaction(_ transaction: EthereumTransaction) -> Swift.Result<[EventParserResultProtocol], Web3Error>
   func parseTransactionByHash(_ hash: Data) -> Swift.Result<[EventParserResultProtocol], Web3Error>
   func parseBlock(_ block: Block) -> Swift.Result<[EventParserResultProtocol], Web3Error>
   func parseBlockByNumber(_ blockNumber: UInt64) -> Swift.Result<[EventParserResultProtocol], Web3Error>
   func parseTransactionPromise(_ transaction: EthereumTransaction) -> Promise<[EventParserResultProtocol]>
   func parseTransactionByHashPromise(_ hash: Data) -> Promise<[EventParserResultProtocol]>
   func parseBlockByNumberPromise(_ blockNumber: UInt64) -> Promise<[EventParserResultProtocol]>
   func parseBlockPromise(_ block: Block) -> Promise<[EventParserResultProtocol]>
}

public struct EthereumBloomFilter {
   public var bytes = Data(repeatElement(UInt8(0), count: 256))

   public init?(_ biguint: BigUInt) {
       guard let data = biguint.serialize().setLengthLeft(256) else { return nil }
       bytes = data
   }

   public init() { }

   public init(_ data: Data) {
       let padding = Data(repeatElement(UInt8(0), count: 256 - data.count))
       bytes = padding + data
   }
   
   public func asBigUInt() -> BigUInt {
       return BigUInt(self.bytes)
   }
}

extension EthereumBloomFilter {
   
   static func bloom9(_ biguint: BigUInt) -> BigUInt {
       return EthereumBloomFilter.bloom9(biguint.serialize())
   }
   
   static func bloom9(_ data: Data) -> BigUInt {
       var b = data.sha3(.keccak256)
       var r = BigUInt(0)
       let mask = BigUInt(2047)
       for i in stride(from: 0, to: 6, by: 2) {
           var t = BigUInt(1)
           let num = (BigUInt(b[i+1]) + (BigUInt(b[i]) << 8)) & mask
//            b = num.serialize().setLengthLeft(8)!
           t = t << num
           r = r | t
       }
       return r
   }
   
   static func logsToBloom(_ logs: [EventLog]) -> BigUInt {
       var bin = BigUInt(0)
       for log in logs {
           bin = bin | bloom9(log.address.addressData)
           for topic in log.topics {
               bin = bin | bloom9(topic)
           }
       }
       return bin
   }
   
   public static func createBloom(_ receipts: [TransactionReceipt]) -> EthereumBloomFilter? {
       var bin = BigUInt(0)
       for receipt in receipts {
           bin = bin | EthereumBloomFilter.logsToBloom(receipt.logs)
       }
       return EthereumBloomFilter(bin)
   }
   
   public func test(topic: Data) -> Bool {
       let bin = self.asBigUInt()
       let comparison = EthereumBloomFilter.bloom9(topic)
       return bin & comparison == comparison
   }
   
   public func test(topic: BigUInt) -> Bool {
       return self.test(topic: topic.serialize())
   }
   
   public static func bloomLookup(_ bloom: EthereumBloomFilter, topic: Data) -> Bool {
       let bin = bloom.asBigUInt()
       let comparison = bloom9(topic)
       return bin & comparison == comparison
   }
   
   public static func bloomLookup(_ bloom: EthereumBloomFilter, topic: BigUInt) -> Bool {
       return EthereumBloomFilter.bloomLookup(bloom, topic: topic.serialize())
   }
   
   public mutating func add(_ biguint: BigUInt) {
       var bin = BigUInt(self.bytes)
       bin = bin | EthereumBloomFilter.bloom9(biguint)
       setBytes(bin.serialize())
   }
   
   public mutating func add(_ data: Data) {
       var bin = BigUInt(self.bytes)
       bin = bin | EthereumBloomFilter.bloom9(data)
       setBytes(bin.serialize())
   }
   
   public func lookup (_ topic: Data) -> Bool {
       return EthereumBloomFilter.bloomLookup(self, topic: topic)
   }
   
   mutating func setBytes(_ data: Data) {
       if self.bytes.count < data.count {
           fatalError("bloom bytes are too big")
       }
       self.bytes = self.bytes[0 ..< data.count] + data
   }
   
}
public class JSONRPCrequestDispatcher {
   public var MAX_WAIT_TIME: TimeInterval = 0.1
   public var policy: DispatchPolicy
   public var queue: DispatchQueue

   private var provider: Web3RequestProvider
   private var lockQueue: DispatchQueue
   private var batches: Store<Batch>

   public init(provider: Web3RequestProvider, queue: DispatchQueue, policy: DispatchPolicy) {
       self.provider = provider
       self.queue = queue
       self.policy = policy
       self.lockQueue = DispatchQueue(label: "batchingQueue", qos: .userInitiated)
       self.batches = .init(queue: lockQueue)

       createBatch()
   }

   private func getBatch() throws -> Batch {
       guard case .Batch(let batchLength) = policy else {
           throw Web3Error.inputError("Trying to batch a request when policy is not to batch")
       }

       let currentBatch = batches.last() ?? createBatch()

       if currentBatch.requests.count() % batchLength == 0 || currentBatch.triggered {
           let newBatch = Batch(capacity: Int(batchLength), queue: queue, lockQueue: lockQueue)
           newBatch.delegate = self

           batches.append(newBatch)

           return newBatch
       }

       return currentBatch
   }

   public enum DispatchPolicy {
       case Batch(Int)
       case NoBatching
   }

   func addToQueue(request: JSONRPCrequest) -> Promise<JSONRPCresponse> {
       switch policy {
       case .NoBatching:
           return provider.sendAsync(request, queue: queue)
       case .Batch:
           guard request.id != nil else {
               return provider.sendAsync(request, queue: queue)
           }
           
           do {
               let batch = try getBatch()
               return try batch.add(request, maxWaitTime: MAX_WAIT_TIME)
           } catch {
               let returnPromise = Promise<JSONRPCresponse>.pending()
               queue.async {
                   returnPromise.resolver.reject(error)
               }
               return returnPromise.promise
           }
       }
   }

   internal final class Batch: NSObject {
       private var pendingTrigger: Guarantee<Void>?
       private let queue: DispatchQueue
       private (set) var triggered: Bool = false

       var capacity: Int
       var promises: DictionaryStore<UInt64, (promise: Promise<JSONRPCresponse>, seal: Resolver<JSONRPCresponse>)>
       var requests: Store<JSONRPCrequest>

       weak var delegate: BatchDelegate?

       fileprivate func add(_ request: JSONRPCrequest, maxWaitTime: TimeInterval) throws -> Promise<JSONRPCresponse> {
           guard !triggered else {
               throw Web3Error.nodeError("Batch is already in flight")
           }

           let (promise, seal) = Promise<JSONRPCresponse>.pending()

           if let value = promises[request.id] {
               value.seal.reject(Web3Error.inputError("Request ID collision"))
           } else {
               promises[request.id] = (promise, seal)
           }

           requests.append(request)

           if pendingTrigger == nil {
               pendingTrigger = after(seconds: maxWaitTime)
                   .done(on: queue) { [weak self] in
                       self?.trigger()
                   }
           }

           if requests.count() == capacity {
               trigger()
           }

           return promise
       }

       func trigger() {
           guard !triggered else { return }
           triggered = true

           delegate?.didTrigger(id: self)
       }

       init(capacity: Int, queue: DispatchQueue, lockQueue: DispatchQueue) {
           self.capacity = capacity
           self.queue = queue
           self.promises = .init(queue: lockQueue)
           self.requests = .init(queue: lockQueue)
       }
   }

}
extension JSONRPCrequestDispatcher: BatchDelegate {

   func didTrigger(id batch: Batch) {
       let requestsBatch = JSONRPCrequestBatch(requests: batch.requests.allValues())

       provider
           .sendAsync(requestsBatch, queue: queue)
           .done(on: queue, { [weak batches] batchResponse in
               if let error = batchResponse.responses.last?.error, batchResponse.responses.count == 1 {
                   guard let keys = batch.promises.keys() else { return }

                   for key in keys {
                       guard let value = batch.promises[key] else { continue }
                       value.seal.reject(Web3Error.nodeError(error.message))
                   }

                   batches?.removeAll(batch)
                   return
               }
               
               for response in batchResponse.responses {
                   guard let id = response.id else { continue }
                   guard let value = batch.promises[UInt64(id)] else {
                       guard let keys = batch.promises.keys() else { return }
                       for key in keys {
                           guard let value = batch.promises[key] else { continue }
                           value.seal.reject(Web3Error.nodeError("Unknown request id"))
                       }
                       return
                   }
                   value.seal.fulfill(response)
               }

               batches?.removeAll(batch)
           }).catch(on: queue, { [weak batches] err in
               guard let keys = batch.promises.keys() else { return }

               for key in keys {
                   guard let value = batch.promises[key] else { continue }
                   value.seal.reject(err)
               }

               batches?.removeAll(batch)
           })
   }

   @discardableResult func createBatch() -> Batch {
       switch policy {
       case .NoBatching:
           let batch = Batch(capacity: 32, queue: queue, lockQueue: lockQueue)
           batch.delegate = self

           batches.append(batch)

           return batch
       case .Batch(let count):
           let batch = Batch(capacity: count, queue: queue, lockQueue: lockQueue)
           batch.delegate = self

           batches.append(batch)

           return batch
       }
   }
}

protocol BatchDelegate: AnyObject {
   func didTrigger(id batch: JSONRPCrequestDispatcher.Batch)
}

class DictionaryStore<K: Hashable, V> {
   private var values: [K: V] = [:]
   private let queue: DispatchQueue

   public init(queue: DispatchQueue = DispatchQueue(label: "RealmStore.syncQueue", qos: .background)) {
       self.queue = queue
   }

   public subscript(key: K) -> V? {
       get {
           var element: V?
           dispatchPrecondition(condition: .notOnQueue(queue))
           queue.sync { [weak self] in
               element = self?.values[key]
           }
           return element
       }
       set {
           dispatchPrecondition(condition: .notOnQueue(queue))
           queue.sync { [weak self] in
               self?.values[key] = newValue
           }
       }
   }

   func keys() -> Dictionary<K, V>.Keys? {
       var keys: Dictionary<K, V>.Keys?
       dispatchPrecondition(condition: .notOnQueue(queue))
       queue.sync { [weak self] in
           keys = self?.values.keys
       }
       return keys
   }
}

class Store<T> {
   private var values: [T] = []
   private let queue: DispatchQueue

   public init(queue: DispatchQueue = DispatchQueue(label: "RealmStore.syncQueue", qos: .background)) {
       self.queue = queue
   }

   func append(_ element: T) {
       dispatchPrecondition(condition: .notOnQueue(queue))
       queue.sync { [weak self] in
           self?.values.append(element)
       }
   }

   func last() -> T? {
       var element: T?
       dispatchPrecondition(condition: .notOnQueue(queue))
       queue.sync { [weak self] in
           element = self?.values.last
       }

       return element
   }

   func count() -> Int {
       var count: Int = 0
       dispatchPrecondition(condition: .notOnQueue(queue))
       queue.sync { [weak self] in
           count = self?.values.count ?? 0
       }
       return count
   }

   func allValues() -> [T] {
       var values: [T] = []
       dispatchPrecondition(condition: .notOnQueue(queue))
       queue.sync { [weak self] in
           values = self?.values ?? []
       }
       return values
   }
}

extension Store where T: Equatable & AnyObject {
   func removeAll(_ elem: T) {
       dispatchPrecondition(condition: .notOnQueue(queue))
       queue.sync { [weak self] in
           self?.values.removeAll(where: { $0 === elem })
       }
   }
}

