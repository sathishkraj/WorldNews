//
//  ContentManager.swift
//  WSJWorldNews

import UIKit

protocol ContentManagerProtocol {
  func itemStream(for url: String, handler: @escaping ResultHandler)
}

class ContentManager: ContentManagerProtocol {
  
  let xmlContentManager: XMLContentManagerProtocol
  
  init(xmlContentManager: XMLContentManagerProtocol = XMLContentManager()) {
    self.xmlContentManager = xmlContentManager
  }
  
  func itemStream(for url: String, handler: @escaping ResultHandler) {
    // TODO - check the items in cache else fetch fresh
    xmlContentManager.fetchItem(for: url) { item, error, didComplete in
      handler(item, error, didComplete)
    }
  }
}
