//
//  iOSMacBridge.swift
//  HGGIF
//
//  Created by Henrique Galo on 20/12/18.
//  Copyright © 2018 Henrique Galo. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

public typealias UINSImage = UIImage
#elseif os(macOS)
import Cocoa

public typealias UINSImage = NSImage

extension NSImage {
    var cgImage: CGImage? {
        return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    public convenience init(cgImage: CGImage) {
        self.init(cgImage: cgImage, size: NSSize.zero)
    }
}
#endif
