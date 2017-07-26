//
//  UIImageViewExtension.swift
//  Minechecker
//
//  Created by Ryan Donaldson on 12/22/16.
//  Copyright © 2016 Ryan Donaldson. All rights reserved.
//

import UIKit

extension UIImageView {
    
    /// SwifterSwift: Set image from a URL.
    ///
    /// - Parameters:
    ///   - url: URL of image.
    ///   - contentMode: imageView content mode (default is .scaleAspectFit).
    ///   - placeHolder: optional placeholder image
    ///   - completionHandler: optional completion handler to run when download finishs (default is nil).
    public func download(from url: URL,
                         contentMode: UIViewContentMode = .scaleAspectFit,
                         placeholder: UIImage? = nil,
                         completionHandler: ((UIImage?, Error?) -> Void)? = nil) {
        
        image = placeholder
        self.contentMode = contentMode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    completionHandler?(nil, error)
                    return
            }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
                completionHandler?(image, nil)
            }
        }.resume()
    }
}
