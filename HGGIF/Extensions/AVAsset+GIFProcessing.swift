//
//  VideoAsset.swift
//  HGGIF
//
//  Created by Henrique Galo on 22/12/18.
//  Copyright © 2018 Henrique Galo. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAsset {
    /// Function to get all video frames of a related interval of time.
    ///
    /// - Parameters:
    ///   - videoURL: Video local path location
    ///   - startTime: Time to start getting frames. Default is 0.
    ///   - endTime: Time to finish getting frames. Passing nil means to get video's duration time.
    ///   - framesPerSecond: Number of frames per second to capture of a video. Defaults to 15.
    /// - Returns: Object that contains all frames and related information of the video.
    public func getAllFrames(from startTime: Double = 0, to endTime: Double? = nil, framesPerSecond: Int = 15) -> VideoFrames? {
        let intervalToGetFrame = (1.0 / Double.init(framesPerSecond))
        
        let frameSeconds = stride(from: startTime, to: endTime ?? self.duration.seconds, by: intervalToGetFrame)
        
        let frames = frameSeconds.compactMap { (second) -> UINSImage? in
            let time = CMTime.init(seconds: second, preferredTimescale: self.duration.timescale)
            return self.getFrame(of: self, at: time)
        }
        
        return VideoFrames.init(frames: frames, duration: self.duration.seconds, framesPerSecond: framesPerSecond)
    }
    
    /// Function to get a frame of a specific time.
    ///
    /// - Parameters:
    ///   - asset: Asset to get the frame.
    ///   - time: Specific time to get the frame.
    /// - Returns: Image with the frame of the specific time.
    private func getFrame(of asset: AVAsset, at time: CMTime) -> UINSImage? {
        let imageGenerator = AVAssetImageGenerator.init(asset: asset)
        imageGenerator.requestedTimeToleranceAfter = CMTime.zero
        imageGenerator.requestedTimeToleranceBefore = CMTime.zero
        
        do {
            let imageFrame = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UINSImage.init(cgImage: imageFrame)
        } catch {
            return nil
        }
    }
}
