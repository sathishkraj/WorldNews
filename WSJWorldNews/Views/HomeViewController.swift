//
//  HomeViewController.swift
//  WSJWorldNews

import UIKit

class HomeViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  var itemsObserver: NSKeyValueObservation?
  var errorObserver: NSKeyValueObservation?
  var parserCompletionObserver: NSKeyValueObservation?
  
  let viewModel = HomeViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "World News"
    observeItems()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.fetchItems()
  }

  func observeItems() {
    itemsObserver = viewModel.observe(\.items, options: [.new, .old]) { [weak self] viewModel, _ in
      self?.collectionView.reloadData()
    }
    errorObserver = viewModel.observe(\.error, options: [.new, .old]) { viewModel, _ in
      // TODO - handle error
    }
    parserCompletionObserver = viewModel.observe(\.didComplete, options: [.new, .old]) { viewModel, _ in
      // TODO - handle if any after complete
    }
  }

}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.itemCount
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeViewConstants.itemCellReuseIdentifier, for: indexPath) as! ItemCollectionViewCell
    itemCell.viewModel = viewModel.cellViewModel(for: indexPath)
    return itemCell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: HomeViewConstants.itemCellHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let url = viewModel.item(at: indexPath.row)?.link else {
      return
    }
    let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
    let detailsViewController = storyBoard.instantiateViewController(withIdentifier: "DetailsView") as! DetailsViewController
    detailsViewController.urlString = url
    navigationController?.pushViewController(detailsViewController, animated: true)
  }
}
