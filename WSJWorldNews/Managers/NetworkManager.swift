//
//  NetworkManager.swift
//  WSJHome

import UIKit

protocol NetworkManagerProtocol {
  func request(for url: String) -> URLSessionTask?
}

class NetworkManager: NSObject, NetworkManagerProtocol {
  typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
  @objc dynamic var dataChunk: Data?
  @objc dynamic var error: Error?
  var sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
  
  func request(for url: String) -> URLSessionTask? {
    guard let url = URL(string: url) else {
      return nil
    }
    let urlRequest = URLRequest(url: url)
    let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
    let task = session.dataTask(with: urlRequest)
    networkIndicator(true)
    task.resume()
    return task
  }
  
  func networkIndicator(_ isVisible: Bool) {
    DispatchQueue.main.async {
      UIApplication.shared.isNetworkActivityIndicatorVisible = isVisible
    }
  }

}

//MARK: URLSessionDataDelegate

extension NetworkManager: URLSessionDataDelegate, URLSessionTaskDelegate {  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    dataChunk = data
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    networkIndicator(false)
    self.error = error
  }
}
