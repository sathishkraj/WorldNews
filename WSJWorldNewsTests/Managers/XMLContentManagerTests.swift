//
//  XMLContentManagerTests.swift
//  WSJWorldNewsTests

import XCTest
@testable import WSJWorldNews

class XMLContentManagerTests: XCTestCase {
  
  static let sampleFeed: String = """
<item>
  <title>
  Arrest of Senior Huawei Executive Steps Up U.S.-China Confrontation
  </title>
  <guid isPermaLink="false">SB12502700134474143431404584638240525173938</guid>
  <link>
  https://www.wsj.com/articles/arrest-of-senior-huawei-executive-steps-up-u-s-china-confrontation-1544109346?mod=fox_australian
  </link>
  <description>
  The arrest of a senior executive of networking-gear maker Huawei Technologies Co.
  </description>
  <media:content xmlns:media="http://search.yahoo.com/mrss" url="http://s.wsj.net/public/resources/images/S1-BM414_chinau_G_20181206091742.jpg" type="image/jpeg" medium="image" height="369" width="553">
  <media:description>image</media:description>
  </media:content>
  <category>FREE</category>
  <pubDate>Thu, 06 Dec 2018 10:19:48 EST</pubDate>
  </item>
"""
  
  var item: Item?
  
  override func setUp() {
  }
  
  override func tearDown() {
  }
  
  func testXMLParsing() {
    let networkManagerSpy = NetworkManagerSpy()
    let xmlParser = XMLContentManager(networkManager: networkManagerSpy)
    
    let itemExpectation = expectation(description: "data expectation")
    itemExpectation.expectedFulfillmentCount = 2 // 1 for item, 2 for completion
    xmlParser.fetchItem(for: "/wsj/worldnews") { item, error, didComplete in
      itemExpectation.fulfill()
      if !didComplete {
        self.item = item
      }
    }
    networkManagerSpy.responseData = XMLContentManagerTests.sampleFeed.data(using: .utf8)
    waitForExpectations(timeout: 3, handler: nil)
    
    XCTAssertNotNil(item, "should not be nil")
    XCTAssertEqual(item?.title?.trimmingCharacters(in: .whitespacesAndNewlines), "Arrest of Senior Huawei Executive Steps Up U.S.-China Confrontation", "should be equal")
    XCTAssertEqual(item?.mediaUrl, "http://s.wsj.net/public/resources/images/S1-BM414_chinau_G_20181206091742.jpg", "should be equal")
  }
  
  func testError() {
    let networkManagerSpy = NetworkManagerSpy()
    networkManagerSpy.shouldThrowError = true
    let xmlParser = XMLContentManager(networkManager: networkManagerSpy)
    
    var parseError: Error?
    let errorExpectation = expectation(description: "data expectation")
    xmlParser.fetchItem(for: "/wsj/worldnews") { item, error, didComplete in
      errorExpectation.fulfill()
      parseError = error
    }
    networkManagerSpy.responseData = nil
    waitForExpectations(timeout: 3, handler: nil)
    
    XCTAssertNotNil(parseError, "should not be nil")
    XCTAssertEqual((parseError as NSError?)?.code, 500, "should be equal")
  }
  
}
