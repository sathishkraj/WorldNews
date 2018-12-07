//
//  NetworkManagerSpy.swift
//  WSJWorldNewsTests

import UIKit
@testable import WSJWorldNews

class NetworkManagerSpy: NetworkManager {
  
  var requestedUrl: String = ""
  var responseData: Data? {
    didSet {
      setResponse()
    }
  }
  
  var shouldThrowError = false
  
  override func request(for url: String) -> URLSessionTask? {
    requestedUrl = url
    return nil
  }
  
  private func setResponse() {
    if shouldThrowError {
      error = NSError(domain: "Internal Error", code: 500, userInfo: nil)
    } else {
      dataChunk = responseData
      error = nil
    }
  }

}
