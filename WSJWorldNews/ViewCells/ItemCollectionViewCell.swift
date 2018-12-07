//
//  ItemCollectionViewCell.swift
//  WSJWorldNews

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var pubDate: UILabel!
  var imageObserver: NSKeyValueObservation?
  
  weak var viewModel: ItemCellViewModel? {
    didSet {
      guard let viewModel = viewModel else {
        return
      }
      isAccessibilityElement = true
      accessibilityLabel = viewModel.title
      title.text = viewModel.title
      pubDate.text = viewModel.pubDate
      if let image = viewModel.image {
        imageView.image = image
      } else {
        imageObserver = viewModel.observe(\.image, options: [.new, .old]) { [weak self] model, _ in
          self?.imageView.image = model.image
        }
        viewModel.downloadImage() // TODO - Add download manager - this is only for POC
      }
    }
  }
}
