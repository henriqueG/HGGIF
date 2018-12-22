//
//  PhotosWrapper.swift
//  HGGIF
//
//  Created by Henrique Galo on 18/12/18.
//  Copyright © 2018 Henrique Galo. All rights reserved.
//

#if os(iOS)
import Foundation
import Photos

public struct PhotosWrapper {
    /// Function wrapper to create an album inside Photos.app
    ///
    /// - Parameters:
    ///   - title: Name of the album to be created
    ///   - completionHandler: A block that Photos calls after the change block completes and Photos performs the requested changes.
    private static func createAlbum(withTitle title: String, completionHandler: @escaping ((PHAssetCollection?, Error?) -> Void)) {
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
            placeholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }) { (success, error) in
            if success {
                let collectionFetchResult = placeholder.map { PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [$0.localIdentifier], options: nil) }
                completionHandler(collectionFetchResult?.firstObject, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    /// Function wrapper to get an album inside Photos.app. This function also creates an album if doesn't exists.
    ///
    /// - Parameters:
    ///   - title: Name of the album to get or create.
    ///   - completionHandler: A block that Photos calls after the change block completes and Photos performs the requested changes.
    public static func getAlbum(withTitle title: String, completionHandler: @escaping ((PHAssetCollection?, Error?) -> Void)) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", title)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let album = collections.firstObject {
            completionHandler(album, nil)
        } else {
            PhotosWrapper.createAlbum(withTitle: title, completionHandler: { (album, error) in
                completionHandler(album, error)
            })
        }
    }
}

public extension PhotosWrapper {
    /// Function wrapper to save images inside an album in the Photos.app. Check getAlbum to see side effects of using this.
    ///
    /// - Parameters:
    ///   - sourceURL: Local path of the image to be saved.
    ///   - albumTitle: Album title to save the image. (An album will be created if doesn't exists yet.)
    ///   - completionHandler: A block that Photos calls after the change block completes and Photos performs the requested changes.
    public static func save(image sourceURL: URL, in albumTitle: String, completionHandler: @escaping ((Bool, Error?) -> Void)) {
        PhotosWrapper.getAlbum(withTitle: albumTitle) { (album, error) in
            if error == nil {
                PHPhotoLibrary.shared().performChanges({
                    let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: sourceURL)
                    let assets = assetRequest?.placeholderForCreatedAsset
                        .map { [$0] as NSArray } ?? NSArray()
                    let albumChangeRequest = album.flatMap { PHAssetCollectionChangeRequest(for: $0) }
                    albumChangeRequest?.addAssets(assets)
                }, completionHandler: { (success, error) in
                    completionHandler(success, error)
                })
            } else {
                completionHandler(false, error)
            }
        }
        
    }
}
#endif
