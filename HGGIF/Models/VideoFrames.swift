//
//  VideoFrames.swift
//  HGGIF
//
//  Created by Henrique Galo on 18/12/18.
//  Copyright © 2018 Henrique Galo. All rights reserved.
//

import Foundation

public struct VideoFrames: GIFDocument {
    /// The frames taken from the video.
    public var frames: [UINSImage]
    /// The duration of the video.
    public let duration: Double
    /// The frames took per second of the video.
    public let framesPerSecond: Int
}
