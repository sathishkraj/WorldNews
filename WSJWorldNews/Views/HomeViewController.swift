//
//  HomeViewController.swift
//  WSJWorldNews

import UIKit
import SafariServices

class HomeViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  var itemsObserver: NSKeyValueObservation?
  var errorObserver: NSKeyValueObservation?
  var parserCompletionObserver: NSKeyValueObservation?
  var loadingObserver: NSKeyValueObservation?
  
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
    
    errorObserver = viewModel.observe(\.error, options: [.new, .old]) { [weak self] viewModel, _ in
      self?.showError()
      viewModel.isLoadingItems = false
    }
    
    parserCompletionObserver = viewModel.observe(\.didComplete, options: [.new, .old]) { viewModel, _ in
      // TODO - handle if any after complete
    }
    
    loadingObserver = viewModel.observe(\.isLoadingItems, options: [.new, .old]) { [weak self] viewModel, _ in
      if viewModel.isLoadingItems {
        self?.activityIndicator.startAnimating()
      } else {
        self?.activityIndicator.stopAnimating()
      }
    }
  }

  func showError() {
    guard let nsError = viewModel.error as NSError? else { return }
    let alertViewController = UIAlertController(title: nsError.domain, message: nsError.localizedDescription, preferredStyle: .alert)
    let alertActionOk = UIAlertAction(title: "Ok", style: .default) { action in
      alertViewController.dismiss(animated: true, completion:nil)
    }
    alertViewController.addAction(alertActionOk)
    present(alertViewController, animated: true, completion: nil)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    collectionView?.collectionViewLayout.invalidateLayout()
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
    guard let urlString = viewModel.item(at: indexPath.row)?.link, let url = URL(string: urlString) else {
      return
    }
    let safariViewController = SFSafariViewController(url: url)
    navigationController?.pushViewController(safariViewController, animated: true)
  }
}
