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
  
  func request(for url: String) -> URLSessionTask? {
    guard let url = URL(string: url) else {
      return nil
    }
    let urlReuest = URLRequest(url: url)
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    let task = session.dataTask(with: urlReuest)
    networkIndicator(true)
    task.resume()
    return task
  }
  
  func data(for url: String, completionHandler: @escaping CompletionHandler) {
    guard let url = URL(string: url) else {
      completionHandler(nil, nil, nil)
      return
    }
    let urlReuest = URLRequest(url: url)
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    let task = session.dataTask(with: urlReuest) { data, response, error in
      DispatchQueue.main.async { [weak self] in
        self?.networkIndicator(false)
        completionHandler(data, response, error)
      }
    }
    networkIndicator(true)
    task.resume()
  }
  
  func networkIndicator(_ isVisible: Bool) {
    DispatchQueue.main.async {
      UIApplication.shared.isNetworkActivityIndicatorVisible = isVisible
    }
  }

}

//MARK: URLSessionDataDelegate

extension NetworkManager: URLSessionDataDelegate, URLSessionTaskDelegate {
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    completionHandler(URLSession.ResponseDisposition.allow)
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    dataChunk = data
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    networkIndicator(false)
    self.error = error
  }
}
