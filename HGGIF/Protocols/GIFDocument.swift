//
//  GIFDocument.swift
//  HGGIF
//
//  Created by Henrique Galo on 18/12/18.
//  Copyright © 2018 Henrique Galo. All rights reserved.
//

import Foundation

#if os(iOS)
import MobileCoreServices
#elseif os(macOS)
import CoreServices
#endif

public protocol GIFDocument {
    var frames: [UINSImage] { get set }
    func saveToGIF() -> URL?
}

public extension GIFDocument {
    /// Function to save all object frames as a GIF.
    ///
    /// - Returns: Local path URL containing the saved GIF. Returns nil if fails.
    func saveToGIF() -> URL? {
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]  as CFDictionary
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): 1/100, (kCGImagePropertyGIFUnclampedDelayTime as String): 0.000]] as CFDictionary
        
        let uuid = UUID.init().uuidString
        
        do {
            let documentsDirectoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentsDirectoryURL.appendingPathComponent(uuid).appendingPathExtension("gif")
            
            guard let destination = CGImageDestinationCreateWithURL((fileURL as CFURL), kUTTypeGIF, frames.count, nil)  else { return nil }

            CGImageDestinationSetProperties(destination, fileProperties)
            
            for frame in frames {
                if let cgImage = frame.cgImage {
                    CGImageDestinationAddImage(destination, cgImage, frameProperties)
                }
            }
            
            if !CGImageDestinationFinalize(destination) {
                print("Failed to finalize the image destination")
                return nil
            }
            
            return fileURL
        } catch {
            return nil
        }
    }
}
