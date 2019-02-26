//
//  PhotoLibrayManager.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/9/3.
//

import UIKit
import Photos
import PromiseKit

class PhotoLibraryManager {
    
    static func isAuthorized() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        return status == .authorized || status == .notDetermined
    }
    
    /// fetch album, create one if not exist
    static func fetchAlbum(name: String) -> Promise<PHAssetCollection> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let assetCollection = assetCollections.firstObject {
            return Promise.value(assetCollection)
        } else {
            return PHPhotoLibrary.shared().performChanges {
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            }.then {
                fetchAlbum(name: name)
            }
        }
    }
    
    static func save(imageData: [Data], albumName: String = "DJIFileManager") -> Promise<Void> {
        return fetchAlbum(name: albumName).then { assetCollection in
            PHPhotoLibrary.shared().performChanges {
                for data in imageData {
                    let image = UIImage(data: data) ?? UIImage()
                    let changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    if let assetPlaceholder = changeRequest.placeholderForCreatedAsset
                     , let albumChangeRequset = PHAssetCollectionChangeRequest(for: assetCollection) {
                        albumChangeRequset.addAssets([assetPlaceholder] as NSArray)
                    }
                }
            }
        }
    }
    
    static func saveVideo(url: URL, albumName: String = "DJIFileManager") -> Promise<Void> {
        return fetchAlbum(name: albumName).then { assetCollection in
            PHPhotoLibrary.shared().performChanges {
                let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                if let assetPlaceholder = changeRequest?.placeholderForCreatedAsset
                 , let albumChangeRequset = PHAssetCollectionChangeRequest(for: assetCollection) {
                    albumChangeRequset.addAssets([assetPlaceholder] as NSArray)
                }
            }
        }
    }
    
}

extension PHPhotoLibrary {
    
    func performChanges(_ changeBlock: @escaping () -> Void) -> Promise<Void> {
        return Promise { seal in
            performChanges(changeBlock, completionHandler: { (result, error) in
                if result {
                    seal.fulfill(())
                } else {
                    seal.reject(error ?? PMKError.emptySequence)
                }
            })
        }
    }
    
    func requestPhotoLibrayAuthorization() -> Promise<Void> {
        return Promise { seal in
            PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
                if authorizationStatus == .authorized {
                    seal.fulfill(())
                } else {
                    seal.reject(MediaFileManagerError.unAuthorized)
                }
            }
        }
    }
    
}
