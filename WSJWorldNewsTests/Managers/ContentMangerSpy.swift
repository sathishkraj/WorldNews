//
//  ContentMangerSpy.swift
//  WSJWorldNewsTests

import UIKit
@testable import WSJWorldNews

class ContentMangerSpy: ContentManagerProtocol {
  let spyItem = Item(title: "news title")
  var shouldThrowError = false
  var didComplete = false
  var error = NSError(domain: "Internal server error", code: 500, userInfo: nil)
  
  func itemStream(for url: String, handler: @escaping ResultHandler) {
    if shouldThrowError {
      handler(nil, error, false)
    } else if didComplete {
      handler(nil, nil, true)
    } else {
      handler(spyItem, nil, false)
    }
  }
}
