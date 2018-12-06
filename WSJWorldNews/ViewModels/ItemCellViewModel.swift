//
//  ItemCellViewModel.swift
//  WSJWorldNews

import UIKit

class ItemCellViewModel: NSObject {

  let item: Item
  @objc dynamic var image: UIImage?
  
  init(_ item: Item) {
    self.item = item
  }
  
  // TODO - add imagedownlaoder, this is only for POC purpose
  func downloadImage() {
    guard let url = imageUrl else {
      return
    }
    let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
      guard let data = data else {
        return
      }
      DispatchQueue.main.async {
        self?.image = UIImage(data: data)
      }
    }
    task.resume()
  }
}

//MARK: Computed Properties

extension ItemCellViewModel {
  var title: String {
    return item.title ?? ""
  }
  
  var pubDate: String {
    return item.pubDate ?? ""
  }
  
  var imageUrl: URL? {
    return URL(string: item.mediaUrl ?? "")
  }
}
