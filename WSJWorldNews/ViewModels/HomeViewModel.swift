//
//  HomeViewModel.swift
//  WSJWorldNews


import UIKit

struct HomeViewConstants {
  static let feedUrl = "http://www.wsj.com/xml/rss/3_7085.xml"
  static let itemCellReuseIdentifier = "ItemCell"
  static let itemCellHeight: CGFloat = 148
}

class HomeViewModel: NSObject {
  
  let contentManager: ContentManagerProtocol
  let parserQueue = DispatchQueue(label: "ParserQueue")
  @objc dynamic var items: [Item] = []
  @objc dynamic var error: Error?
  @objc dynamic var didComplete: Bool = false
  var cellModelCache: [IndexPath: ItemCellViewModel] = [:]
  
  init(_ contentManager: ContentManagerProtocol = ContentManager()) {
    self.contentManager = contentManager
  }
  
  func fetchItems() {
    parserQueue.async {
      self.contentManager.itemStream(for: HomeViewConstants.feedUrl) { [weak self] item, error, didComplete in
        if let item = item {
          self?.items.append(item)
        } else if let error = error {
          self?.error = error
        } else if didComplete {
          self?.didComplete = didComplete
        }
      }
    }
  }

  func cellViewModel(for indexPath: IndexPath) -> ItemCellViewModel? {
    if let cellModel = cellModelCache[indexPath] {
      return cellModel
    }
    guard let item = item(at: indexPath.row) else {
      return nil
    }
    let cellModel = ItemCellViewModel(item)
    cellModelCache[indexPath] = cellModel
    return cellModel
  }
  
  func item(at index: Int) -> Item? {
    guard index >= 0, index < itemCount else {
      return nil
    }
    return items[index]
  }
}

//MARK: Computed Properties

extension HomeViewModel {
  var itemCount: Int {
    return items.count
  }
}
