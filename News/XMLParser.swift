//
//  XMLParser.swift
//  News
//
//  Created by Maxim Lebedev on 27.10.2020.
//  Copyright © 2020 Lebedev Maxim. All rights reserved.
//

import Foundation

struct RSSItem {
    var title: String
    var description: String
    var pubDate: String
    var enclouser: [String]
    var category: String
}


class FeedParser: NSObject, XMLParserDelegate
{
    private var rssItems: [RSSItem] = []
    private var currentElement = ""
    private var setOfCategory = Set<String>()
    private var currentTitle: String = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentDescription: String = "" {
        didSet {
            currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPubDate: String = "" {
        didSet {
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentCategory: String = "" {
        didSet {
            currentCategory = currentCategory.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentEnclouser = [String]()
    private var parserCompletionHandler: (([RSSItem], Set<String>) -> Void)?
    
    func parseFeed(url: String, completionHandler: (([RSSItem], Set<String>) -> Void)?)
    {
        self.parserCompletionHandler = completionHandler
        
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        
        task.resume()
    }
    
    // MARK: - XML Parser Delegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:])
    {
        switch elementName {
        case "item":
            currentTitle = String()
            currentPubDate = String()
            currentEnclouser = [String]()
            currentDescription = String()
            currentCategory = String()
        case "enclosure":
            if let urlString = attributeDict["url"] {
                currentEnclouser.append(urlString)
            }
        default:
            break
        }
        self.currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if elementName == "item" {
            let rssItem = RSSItem(
                title: currentTitle,
                description: currentDescription,
                pubDate: currentPubDate,
                enclouser: currentEnclouser,
                category: currentCategory
            )
            rssItems.append(rssItem)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        switch currentElement {
        case "title": currentTitle += string
        case "pubDate": currentPubDate += string
        case "category": currentCategory += string
        if !string.isEmpty {
            setOfCategory.insert(string)
            }
        case "yandex:full-text": currentDescription += string
            
        default:
            break
        }
    }
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(rssItems, setOfCategory)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error)
    {
        print(parseError.localizedDescription)
    }
    
}

