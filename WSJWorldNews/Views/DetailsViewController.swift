//
//  DetailsViewController.swift
//  WSJWorldNews

import UIKit
import WebKit

class DetailsViewController: UIViewController {
  
  @IBOutlet weak var webView: WKWebView!
  var urlString: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    load()
  }
  
  func load() {
    guard let url = URL(string: urlString ?? "") else {
      return
    }
    let request = URLRequest(url: url)
    webView.load(request)
  }
  
}
