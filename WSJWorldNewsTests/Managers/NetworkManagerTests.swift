//
//  NetworkManagerTests.swift
//  WSJWorldNewsTests

import XCTest
@testable import WSJWorldNews

class NetworkManagerTests: XCTestCase {
  
  var dataChunkObserver: NSKeyValueObservation?
  
  override func setUp() {
    CustomURLProtocol.registerProtocol()
  }
  
  override func tearDown() {
    CustomURLProtocol.unRegisterProtocol()
    CustomURLProtocol.stubRequest = [:]
    CustomURLProtocol.shouldThrowError = false
  }
  
  func testStubData() {
    let urlRequest = URLRequest(url: URL(string: "https://www.google.com")!)
    CustomURLProtocol.stubRequest[urlRequest] = XMLContentManagerTests.sampleFeed.data(using: .utf8)
    
    let networkManager = NetworkManager()
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [CustomURLProtocol.self] as [AnyClass] + configuration.protocolClasses!
    networkManager.sessionConfiguration = configuration
    let protocols = (configuration.protocolClasses!).map { classes in
      return "\(classes)"
    }
    XCTAssertEqual(protocols.first!, "CustomURLProtocol")
    
    CustomURLProtocol.stubRequest[urlRequest] = XMLContentManagerTests.sampleFeed.data(using: .utf8)
    
    var xmlData = Data()
    let dataChunkExpectation = expectation(description: "expect data chunks")
    dataChunkExpectation.expectedFulfillmentCount = 3
    dataChunkObserver = networkManager.observe(\.dataChunk, options: [.new, .old]) { manager, _ in
      dataChunkExpectation.fulfill()
      xmlData.append(manager.dataChunk!)
    }
    _ = networkManager.request(for: "https://www.google.com")
    waitForExpectations(timeout: 10, handler: nil)
    
    let responseString = String(data: xmlData, encoding: .utf8)
    XCTAssertTrue(responseString!.hasPrefix("<item>"), "should be true")
  }
  
  func testError() {
    let urlRequest = URLRequest(url: URL(string: "https://www.google.com")!)
    CustomURLProtocol.stubRequest[urlRequest] = XMLContentManagerTests.sampleFeed.data(using: .utf8)
    
    let networkManager = NetworkManager()
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [CustomURLProtocol.self] as [AnyClass] + configuration.protocolClasses!
    networkManager.sessionConfiguration = configuration
    
    CustomURLProtocol.stubRequest[urlRequest] = XMLContentManagerTests.sampleFeed.data(using: .utf8)
    
    XCTAssertNil(networkManager.request(for: ""), "should be equal")
    CustomURLProtocol.shouldThrowError = true
    
    let errorExpectation = expectation(description: "expect error")
    dataChunkObserver = networkManager.observe(\.error, options: [.new, .old]) { manager, _ in
      errorExpectation.fulfill()
      let error = manager.error as NSError?
      XCTAssertEqual(error?.code, 500, "should be equal")
    }
    _ = networkManager.request(for: "https://www.google.com")
    waitForExpectations(timeout: 3, handler: nil)
  }
  
}
