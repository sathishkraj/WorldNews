//
//  HomeViewModelTests.swift
//  WSJWorldNewsTests

import XCTest
@testable import WSJWorldNews

class HomeViewModelTests: XCTestCase {
  
  let indexPath_0 = IndexPath(row: 0, section: 0)
  let indexPath_1 = IndexPath(row: 1, section: 0)
  let indexPath_2 = IndexPath(row: 2, section: 0)
  
  var itemObserver: NSKeyValueObservation?
  var errorObserver: NSKeyValueObservation?
  
  override func setUp() {
    
  }
  
  override func tearDown() {
    //tear down global data if any
  }
  
  func testEmptyHomeViewModel() {
    let contentManagerSpy = ContentMangerSpy()
    let viewModel = HomeViewModel(contentManager: contentManagerSpy)
    
    //test initial values
    XCTAssertEqual(viewModel.itemCount, 0, "items should be zero initially")
    XCTAssertNil(viewModel.cellViewModel(for: indexPath_0), "should be nil")
    XCTAssertNil(viewModel.item(at: 0), "should be nil")
  }
  
  func testFetchItem() {
    let contentManagerSpy = ContentMangerSpy()
    let viewModel = HomeViewModel(contentManager: contentManagerSpy)
    
    let itemExpectation = expectation(description: "expect a item from stream")
    itemObserver = viewModel.observe(\.items, options: [.new, .old]) { model, _ in
      itemExpectation.fulfill()
    }
    viewModel.fetchItems()
    waitForExpectations(timeout: 2, handler: nil)
    
    XCTAssertEqual(viewModel.itemCount, 1, "items should be 1")
    XCTAssertNotNil(viewModel.cellViewModel(for: indexPath_0), "should not be nil")
    XCTAssertNotNil(viewModel.item(at: 0), "should not be nil")
    
    XCTAssertNil(viewModel.cellViewModel(for: indexPath_1), "should be nil")
    XCTAssertNil(viewModel.item(at: 1), "should be nil")
    
    //test cell model in cache
    let cellModel_0 = viewModel.cellViewModel(for: indexPath_0)
    let cellModel_0_cache = viewModel.cellModelCache[indexPath_0]
    XCTAssertEqual(cellModel_0, cellModel_0_cache, "should be equal")
    viewModel.cellModelCache = [:]
    
    let cellModel_0_new = viewModel.cellViewModel(for: indexPath_0)
    XCTAssertNotEqual(cellModel_0, cellModel_0_new, "should be different")
  }
  
  func testFetchItemWithError() {
    let contentManagerSpy = ContentMangerSpy()
    contentManagerSpy.shouldThrowError = true
    let viewModel = HomeViewModel(contentManager: contentManagerSpy)
    
    let errorExpectation = expectation(description: "expect a error from stream")
    errorObserver = viewModel.observe(\.error, options: [.new, .old]) { model, _ in
      errorExpectation.fulfill()
    }
    viewModel.fetchItems()
    waitForExpectations(timeout: 2, handler: nil)
    
    XCTAssertEqual((viewModel.error as NSError?)?.code, 500, "should be equal")
    XCTAssertEqual(viewModel.itemCount, 0, "items should be 0")
    XCTAssertNil(viewModel.cellViewModel(for: indexPath_0), "should be nil")
    XCTAssertNil(viewModel.item(at: 0), "should be nil")
  }
  
  func testFetchItemComplete() {
    let contentManagerSpy = ContentMangerSpy()
    contentManagerSpy.didComplete = true
    let viewModel = HomeViewModel(contentManager: contentManagerSpy)
    
    let completeExpectation = expectation(description: "expect fetch complete")
    errorObserver = viewModel.observe(\.didComplete, options: [.new, .old]) { model, _ in
      completeExpectation.fulfill()
    }
    viewModel.fetchItems()
    waitForExpectations(timeout: 2, handler: nil)
    
    XCTAssertTrue(viewModel.didComplete, "should be true")
  }
  
}
