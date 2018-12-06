//
//  XMLContentManager.swift
//  WSJWorldNews

import UIKit
import libxml2

struct XMLFeedConstants {
  static let item = "item"
  static let title = "title"
  static let link = "link"
  static let description = "description"
  static let category = "category"
  static let pubDate = "pubDate"
  static let mediaPrefix = "media"
  static let mediaUrl = "url"
  static let mediaElement = "content"
  static let attributesFieldCount: Int = 5
  static let attributesKeyPosition: Int = 0
  static let attributesValueStartPosition: Int = 3
  static let attributesValueEndPosition: Int = 4
}

typealias ResultHandler = (Item?, Error?, Bool) -> Void

class XMLContentManager: NSObject {
  
  var context: xmlParserCtxtPtr?
  var didDownloadComplete = false
  var didFindItem = false
  var appendingCharacters = false
  var stringBuffer: String = ""
  var currentItem: Item?
  let networkManager: NetworkManager
  var dataObserver: NSKeyValueObservation?
  var completionObserver: NSKeyValueObservation?
  var completionHandler: ResultHandler?
  
  lazy var xmlhandler: xmlSAXHandler = {
    var handler = xmlSAXHandler()
    handler.characters = elementContent
    handler.error = parseError
    handler.initialized = XML_SAX2_MAGIC
    handler.startElementNs = startElementNs
    handler.endElementNs = endElementNs
    return handler
  }()
  
  init(_ networkManager: NetworkManager = NetworkManager()) {
    self.networkManager = networkManager
  }
  
  func fetchItem(for url: String, handler: @escaping ResultHandler) {
    completionHandler = handler
    didDownloadComplete = false
    context = xmlCreatePushParserCtxt(&xmlhandler, Unmanaged.passUnretained(self).toOpaque(), nil, 0, nil)
    observeDataLoad()
    _ = networkManager.request(for: url)
    
    //Hold the sub thread until download complete
    repeat {
      RunLoop.current.run(mode: .default, before: Date.distantFuture)
    } while (!didDownloadComplete)
    
    xmlFreeParserCtxt(context)
  }
  
  func observeDataLoad() {
    dataObserver = networkManager.observe(\.dataChunk, options: [.new, .old]) { [weak self] manager, _ in
      guard let data = manager.dataChunk, let context = self?.context else {
        return
      }
      _ = data.withUnsafeBytes { bytes in
        xmlParseChunk(context, bytes, CInt(data.count), 0)
      }
    }
    completionObserver = networkManager.observe(\.error, options: [.new, .old]) { [weak self] manager, _ in
      guard let context = self?.context else {
        return
      }
      xmlParseChunk(context, nil, 0, 1)
      self?.didDownloadComplete = true
      self?.completionHandler?(nil, manager.error, true)
    }
  }
  
  func finishedItem() {
    guard let item = currentItem else {
      return
    }
    completionHandler?(item, nil, false)
    currentItem = nil
  }
}

//MARK - Parsing Methods
extension XMLContentManager {
  func startElement(_ prefix: UnsafePointer<xmlChar>?, _ element: UnsafePointer<xmlChar>?, _ attributesCount: Int32, _ attributes: UnsafeMutablePointer<UnsafePointer<xmlChar>?>?) {
    guard let element = element else {
      return
    }
    let elementName = String(cString: element)
    if let prefix = prefix {
      let prefixName = String(cString: prefix)
      if prefixName == XMLFeedConstants.mediaPrefix, elementName == XMLFeedConstants.mediaElement, didFindItem {
        for i in 0..<Int(attributesCount) {
          let key = attributes?[i * XMLFeedConstants.attributesFieldCount + XMLFeedConstants.attributesKeyPosition]
          if let key = key, String(cString: key) == XMLFeedConstants.mediaUrl {
            let valueStart = attributes?[i * XMLFeedConstants.attributesFieldCount + XMLFeedConstants.attributesValueStartPosition]
            let valueEnd = attributes?[i * XMLFeedConstants.attributesFieldCount + XMLFeedConstants.attributesValueEndPosition]
            let start = String(cString: valueStart!)
            let end = String(cString: valueEnd!)
            let length = start.count - end.count
            currentItem?.mediaUrl = String(start.prefix(length))
            break
          }
        }
      }
    } else {
      switch elementName {
      case XMLFeedConstants.item:
        let item = Item()
        currentItem = item
        didFindItem = true
      case XMLFeedConstants.title, XMLFeedConstants.link, XMLFeedConstants.description, XMLFeedConstants.category,
           XMLFeedConstants.pubDate where didFindItem:
        appendingCharacters = true
      default:
        break
      }
    }
  }
  
  func endElement(_ prefix: UnsafePointer<xmlChar>?, _ element: UnsafePointer<xmlChar>?) {
    guard let element = element, didFindItem else {
      appendingCharacters = false
      stringBuffer = ""
      return
    }
    let elementName = String(cString: element)
    
    if let _ = prefix {
      // No characters in media:content
    } else {
      switch elementName {
      case XMLFeedConstants.item:
        finishedItem()
        didFindItem = false
      case XMLFeedConstants.title:
        currentItem?.title = stringBuffer
      case XMLFeedConstants.link:
        currentItem?.link = stringBuffer
      case XMLFeedConstants.description:
        currentItem?.newsDescription = stringBuffer
      case XMLFeedConstants.category:
        currentItem?.category = stringBuffer
      case XMLFeedConstants.pubDate:
        currentItem?.pubDate = stringBuffer
      default:
        break
      }
    }
    appendingCharacters = false
    stringBuffer = ""
  }
  
  func content(_ cChar: UnsafePointer<xmlChar>?, _ length: Int) {
    guard let cChar = cChar, appendingCharacters else {
      return
    }
    let content = String(cString: cChar).prefix(length)
    stringBuffer.append(String(content))
  }
}

//MARK - SAX Parser handler functions

fileprivate func elementContent(context: UnsafeMutableRawPointer?, cChar: UnsafePointer<xmlChar>?, length: Int32) -> Void {
  guard let context = context else {
    return
  }
  let xmlManager = Unmanaged<XMLContentManager>.fromOpaque(context).takeUnretainedValue()
  xmlManager.content(cChar, Int(length))
}

fileprivate func startElementNs(context: UnsafeMutableRawPointer?, elementName: UnsafePointer<xmlChar>?, prefix: UnsafePointer<xmlChar>?, _: UnsafePointer<xmlChar>?, _: Int32, _: UnsafeMutablePointer<UnsafePointer<xmlChar>?>?, attributesCount: Int32, _: Int32, attributes: UnsafeMutablePointer<UnsafePointer<xmlChar>?>?) -> Void {
  guard let context = context else {
    return
  }
  let xmlManager = Unmanaged<XMLContentManager>.fromOpaque(context).takeUnretainedValue()
  xmlManager.startElement(prefix, elementName, attributesCount, attributes)
}

fileprivate func endElementNs(context: UnsafeMutableRawPointer?, elementName: UnsafePointer<xmlChar>?, prefix: UnsafePointer<xmlChar>?, _: UnsafePointer<xmlChar>?) -> Void {
  guard let context = context else {
    return
  }
  let xmlManager = Unmanaged<XMLContentManager>.fromOpaque(context).takeUnretainedValue()
  xmlManager.endElement(prefix, elementName)
}

fileprivate var parseError: errorSAXFunc?
