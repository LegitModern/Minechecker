//
//  StringExtension.swift
//  Minetracker
//
//  Created by iD Student on 7/16/15.
//  Copyright (c) 2015 Ryan Donaldson. All rights reserved.
//

import Foundation

extension String {
    
    //MARK: Helper methods
    
    /**
     Returns the length of the string.
     
     - returns: Int length of the string.
     */
    
    var length: Int {
        return self.characters.count
    }
    
    var objcLength: Int {
        return self.utf16.count
    }
    
    //MARK: - Linguistics
    
    /**
     Returns the langauge of a String
     
     NOTE: String has to be at least 4 characters, otherwise the method will return nil.
     
     - returns: String! Returns a string representing the langague of the string (e.g. en, fr, or und for undefined).
     */
    func detectLanguage() -> String? {
        if self.length > 4 {
            let tagger = NSLinguisticTagger(tagSchemes:[NSLinguisticTagSchemeLanguage], options: 0)
            tagger.string = self
            return tagger.tag(at: 0, scheme: NSLinguisticTagSchemeLanguage, tokenRange: nil, sentenceRange: nil)
        }
        return nil
    }
    
    /**
     Returns the script of a String
     
     - returns: String! returns a string representing the script of the String (e.g. Latn, Hans).
     */
    func detectScript() -> String? {
        if self.length > 1 {
            let tagger = NSLinguisticTagger(tagSchemes:[NSLinguisticTagSchemeScript], options: 0)
            tagger.string = self
            return tagger.tag(at: 0, scheme: NSLinguisticTagSchemeScript, tokenRange: nil, sentenceRange: nil)
        }
        return nil
    }
    
    /**
     Check the text direction of a given String.
     
     NOTE: String has to be at least 4 characters, otherwise the method will return false.
     
     - returns: Bool The Bool will return true if the string was writting in a right to left langague (e.g. Arabic, Hebrew)
     
     */
    var isRightToLeft : Bool {
        let language = self.detectLanguage()
        return (language == "ar" || language == "he")
    }
    
    
    //MARK: - Usablity & Social
    
    /**
     Check that a String is only made of white spaces, and new line characters.
     
     - returns: Bool
     */
    func isOnlyEmptySpacesAndNewLineCharacters() -> Bool {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).length == 0
    }
    
    /**
     Checks if a string is an email address using NSDataDetector.
     
     - returns: Bool
     */
    var isEmail: Bool {
        let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let firstMatch = dataDetector?.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, length))
        
        return (firstMatch?.range.location != NSNotFound && firstMatch?.url?.scheme == "mailto")
    }
    
    /**
     Check that a String is 'tweetable' can be used in a tweet.
     
     - returns: Bool
     */
    func isTweetable() -> Bool {
        let tweetLength = 140,
        // Each link takes 23 characters in a tweet (assuming all links are https).
        linksLength = self.getLinks().count * 23,
        remaining = tweetLength - linksLength
        
        if linksLength != 0 {
            return remaining < 0
        } else {
            return !(self.utf16.count > tweetLength || self.utf16.count == 0 || self.isOnlyEmptySpacesAndNewLineCharacters())
        }
    }
    
    /**
     Gets an array of Strings for all links found in a String
     
     - returns: [String]
     */
    func getLinks() -> [String] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        
        let links = detector?.matches(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, length)).map {$0 }
        
        return links!.filter { link in
            return link.url != nil
            }.map { link -> String in
                return link.url!.absoluteString
        }
    }
    
    /**
     Gets an array of URLs for all links found in a String
     
     - returns: [NSURL]
     */
    func getURLs() -> [URL] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        
        let links = detector?.matches(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, length)).map {$0 }
        
        return links!.filter { link in
            return link.url != nil
            }.map { link -> URL in
                return link.url!
        }
    }
    
    
    /**
     Gets an array of dates for all dates found in a String
     
     - returns: [NSDate]
     */
    func getDates() -> [Date] {
        let error: NSErrorPointer? = nil
        let detector: NSDataDetector?
        do {
            detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        } catch let error1 as NSError {
            error??.pointee = error1
            detector = nil
        }
        let dates = detector?.matches(in: self, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: NSMakeRange(0, self.utf16.count)) .map {$0 }
        
        return dates!.filter { date in
            return date.date != nil
            }.map { link -> Date in
                return link.date!
        }
    }
    
    /**
     Gets an array of strings (hashtags #acme) for all links found in a String
     
     - returns: [String]
     */
    func getHashtags() -> [String]? {
        let hashtagDetector = try? NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        let results = hashtagDetector?.matches(in: self, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, self.utf16.count)).map { $0 }
        
        return results?.map({
            (self as NSString).substring(with: $0.rangeAt(1))
        })
    }
    
    /**
     Gets an array of distinct strings (hashtags #acme) for all hashtags found in a String
     
     - returns: [String]
     */
    func getUniqueHashtags() -> [String]? {
        return Array(Set(getHashtags()!))
    }
    
    
    
    /**
     Gets an array of strings (mentions @apple) for all mentions found in a String
     
     - returns: [String]
     */
    func getMentions() -> [String]? {
        let hashtagDetector = try? NSRegularExpression(pattern: "@(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        let results = hashtagDetector?.matches(in: self, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, self.utf16.count)).map { $0 }
        
        return results?.map({
            (self as NSString).substring(with: $0.rangeAt(1))
        })
    }
    
    /**
     Check if a String contains a Date in it.
     
     - returns: Bool with true value if it does
     */
    func getUniqueMentions() -> [String]? {
        return Array(Set(getMentions()!))
    }
    
    
    /**
     Check if a String contains a link in it.
     
     - returns: Bool with true value if it does
     */
    func containsLink() -> Bool {
        return self.getLinks().count > 0
    }
    
    /**
     Check if a String contains a date in it.
     
     - returns: Bool with true value if it does
     */
    func containsDate() -> Bool {
        return self.getDates().count > 0
    }
    
    func insert(string: String, index: Int) -> String {
        return String(self.characters.prefix(index)) + string + String(self.characters.suffix(self.characters.count - index))
    }
    
    /**
     - returns: Base64 encoded string
     */
    func encodeToBase64Encoding() -> String {
        let utf8str = self.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        return utf8str.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
    }
    
    /**
     - returns: Decoded Base64 string
     */
    func decodeFromBase64Encoding() -> String {
        let base64data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        return NSString(data: base64data!, encoding: String.Encoding.utf8.rawValue)! as String
    }
    
    // MARK: Subscript Methods
    
    subscript (i: Int) -> String {
        return String(Array(self.characters)[i])
    }
    
    subscript (r: Range<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: r.lowerBound),
        end = characters.index(startIndex, offsetBy: r.upperBound)
        
        return substring(with: Range(start ..< end))
    }
    
    subscript (range: NSRange) -> String {
        let end = range.location + range.length
        return self[Range(range.location ..< end)]
    }
    
    subscript (substring: String) -> Range<String.Index>? {
        return range(of: substring, options: NSString.CompareOptions.literal, range: Range(startIndex ..< endIndex), locale: Locale.current)
    }
}
