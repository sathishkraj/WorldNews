//
//  Item.swift
//  WSJWorldNews

import UIKit

class Item: NSObject {
  var title: String?
  var link: String?
  var newsDescription: String?
  var category: String?
  var pubDate: String?
  var mediaUrl: String?
  
  init(title: String? = nil,
       link: String? = nil,
       newsDescription: String? = nil,
       category: String? = nil,
       pubDate: String? = nil,
       mediaUrl: String? = nil) {
    self.title = title
    self.link = link
    self.newsDescription = newsDescription
    self.category = category
    self.pubDate = pubDate
    self.mediaUrl = mediaUrl
  }
}
