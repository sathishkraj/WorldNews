# WorldNews

#Requirements:

Xcode 10 or later, 
Deployment target - iOS 12 or later

#Overview:

This sample app uses world news feed - http://www.wsj.com/xml/rss/3_7085.xml.

Used libxml to parse the feed, this has ability to parse the data chunk by chunk. for eg, if response size is large it will be downloaded as chunks so it starts to parse and display the first chunk even before download is complete, so this way user no need to wait to see the items untill whole data is downloaded, parsed and dispaly. And this is fast.

Design Pattern - MVVM

Architecture Block Diagram - https://s3.amazonaws.com/sample-images1/pdf/SampleAppArchitecture.pdf




