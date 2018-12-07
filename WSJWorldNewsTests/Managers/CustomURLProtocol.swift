//
//  CustomURLProtocol.swift
//  WSJWorldNewsTests


import UIKit
@testable import WSJWorldNews

class CustomURLProtocol: URLProtocol {
  
  static var stubRequest: [URLRequest: Data] = [:]
  static var dataChunkSize: Int = 100
  let downloadQueue = DispatchQueue(label: "downloadQueue")
  static var shouldThrowError = false
  
  class func registerProtocol() {
    URLProtocol.registerClass(CustomURLProtocol.self)
  }
  
  class func unRegisterProtocol() {
    URLProtocol.unregisterClass(CustomURLProtocol.self)
  }
  
  open override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  open override func startLoading() {
    guard var data = CustomURLProtocol.stubRequest[request] else {
      client?.urlProtocolDidFinishLoading(self)
      return
    }
    if CustomURLProtocol.shouldThrowError {
      client?.urlProtocol(self, didFailWithError: NSError(domain: "internal server error", code: 500, userInfo: nil))
    } else {
      let response = URLResponse(url: request.url!, mimeType: nil, expectedContentLength: data.count, textEncodingName: nil)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      downloadQueue.async {
      self.download(chunk: data, fromOffset: 0)
      }
    }
  }
  
  open override func stopLoading() {
  }
  
  func download(chunk data: Data, fromOffset start: Int) {
    guard start < data.count else {
      client?.urlProtocolDidFinishLoading(self)
      return
    }
    let length = min(data.count - start, CustomURLProtocol.dataChunkSize)
    downloadQueue.async {
      let dataInRange = data.subdata(in: start ..< (start + length))
      self.client?.urlProtocol(self, didLoad: dataInRange)
      let delay = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
      self.downloadQueue.asyncAfter(deadline: delay) {
        self.download(chunk: data, fromOffset: start + length)
      }
    }
  }
  
}
