//
//  AssetLibrary2.swift
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 20/09/2023.
//

import UIKit
import Photos

class ALInfo {
    private var assets: [PHAsset]
    private var localizedTitle: String
    
    init(assets: [PHAsset], localizedTitle: String) {
        self.assets = assets
        self.localizedTitle = localizedTitle
    }
    
    /**
     Return number of assets in album
     */
    func getCount() -> Int {
        return assets.count
    }
    
    /**
     Return asset at index
     
     - Parameters:
        - index: Index of asset in album
     */
    func getAsset(at index: Int) -> PHAsset? {
        if getCount() > index {
            return assets[index]
        }
        return nil
    }
    
    /**
     Return album's name
     */
    func getName() -> String {
        return localizedTitle
    }
}

/**
 Available for iOS 14 or upper
 
 > Important: Run **request()** before using other function
 
 - AssetLibrary need user permission to access and fetch data so **request()** must run first.
 - After run **request()** you can use other function has their discription
 
 **Setup example**
 ```
 override func viewDidLoad() {
    super.viewDidLoad()
    
    request { status in
        // do some stuff with return status
    }
 }
 ```
   
 */
class AssetLibrary {
    static var shared = AssetLibrary()
    
    private let albumType = PHAssetMediaType.image
    
    private var req: PHImageRequestID?
    
    private var albums: [ALInfo] = []
    
    private var albumIndex: Int = 0
    private var albumSelect: ALInfo?
    
    private var didFetch = false
    
    /**
     Request user permisstion and fetch data
     
     - Parameters:
        - forceSettings: A Boolean value indicating whether need open settings immediately when user cancel access permission
        - completion: An action after get permission and fetch data
     
     */
    func request(forceSettings: Bool = false, completion: ((PHAuthorizationStatus)->Void)? = nil) {
        DispatchQueue.global(qos: .default).async { [self] in
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            
            if status == .notDetermined {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { [self] status in
                    request(forceSettings: forceSettings, completion: completion)
                }
                return
            }
            
            if status == .denied || status == .restricted {
                DispatchQueue.main.async {
                    if forceSettings {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }
                    completion?(status)
                }
                return
            }
            
            fetchAlbumData()
            selectAlbum(albumIndex)
            
            DispatchQueue.main.async {
                completion?(status)
            }
        }
    }
    
    /**
     Return current album settings status
     */
    func getCurrentStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    /**
     Select album with index
     
     > Important: If index not available this will auto select to closest available index
     
     - Parameters:
        - index: Index of an album in available albums. Pass nil to reselect current selected album
     */
    @discardableResult
    func selectAlbum(_ index: Int? = nil) -> Int {
        let index = index ?? albumIndex
        
        albumIndex = (0..<albums.count).contains(index) ? index : (albums.count - 1)
        
        if (albums.indices.contains(albumIndex)) {
            albumSelect = albums[albumIndex]
        } else {
            albumSelect = nil
        }
        
        return albumIndex
    }
    
    /**
     Return current selected album
     */
    func getCurrentAlbum() -> ALInfo? {
        return albumSelect
    }
    
    /**
     Return current selected album index
     */
    func getCurrentAlbumIndex() -> Int {
        return albumIndex
    }
    
    /**
     Return all available album
     - Parameters:
        - infoOnly: No asset was take, use for getName() only
     */
    func getAllAlbum(_ infoOnly: Bool = false) -> [ALInfo] {
        return albums
    }
    
    /**
     Get UIImage from PHAsset
     
     > Important: if size is negative number this will export full size
     
     - Parameters:
        - asset: Input asset
        - size: Expect size to export, default is full size
        - quality: Expect image quality to export, default is .highQualityFormat
        - resizeMode: Expect mode to export, default is .fast
     */
    func getUIImage(from asset: PHAsset, size: CGSize = CGSize(width: -1, height: -1), quality: PHImageRequestOptionsDeliveryMode = .highQualityFormat, resizeMode: PHImageRequestOptionsResizeMode = .fast, completion: ((UIImage)->Void)? = nil) {
        DispatchQueue.global(qos: .default).async { [self] in
            var size = size
            if size.width < 0 {
                size = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
            }
            
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            
            options.deliveryMode = quality
            options.resizeMode = resizeMode
            options.isNetworkAccessAllowed = true
            
            req = manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: {(result, _)->Void in
                guard let results = result else{
                    return
                }
                DispatchQueue.main.async {
                    completion?(results)
                }
            })
        }
    }
    
    /**
     Cancel export asset
     */
    func cancelRequest() {
        guard let req = req else { return }
        
        PHImageManager.default().cancelImageRequest(req)
        self.req = nil
    }
    
    /**
     Delete asset in library
     
     - Parameters:
        - assets: Array of asset need to delete
        - completion: Handler return boolean declare asset delete success or not
     */
    func deleteImage(assets: [PHAsset?], completion: @escaping (Bool)->Void) {
        let locals = assets.map { asset -> String in
            if let asset = asset{
                return asset.localIdentifier
            }
            return ""
        }.filter { path in
            return path != ""
        }
        PHPhotoLibrary.shared().performChanges({
            let imageAssetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: locals, options: nil)
            PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
        }, completionHandler: { success, error in
            completion(success)
        })
    }
    
    /**
     Get asset type such as PNG, JPEG,...
     */
    func getSourceType(_ asset: PHAsset) -> String{
        let resource = PHAssetResource.assetResources(for: asset)
        var name = "Unknown"
        for r in resource{
            if r.type == .photo{
                name = "\(r.uniformTypeIdentifier.split(separator: ".")[1])"
                name = name.uppercased()
            }
        }
        return name
    }
    
    /**
     Get asset from specific assetID
     */
    func getAsset(from assetID: String) -> PHAsset? {
        return PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil).firstObject
    }
    
    /**
     Get multi asset from multi specific assetID
     */
    func getAssets(from assetID: String) -> [PHAsset] {
        var assets = [PHAsset]()
        
        PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil).enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
    
    /**
     Get assetID for later to get just one specific asset only
     */
    func getAssetID(from asset: PHAsset) -> String {
        return asset.localIdentifier
    }
    
    /**
     Get AVAsset from PHAsset
     */
    func getAVAsset(_ asset: PHAsset, deliveryMode: PHVideoRequestOptionsDeliveryMode = .highQualityFormat, completion: @escaping (AVAsset?) -> Void) {
        let option = PHVideoRequestOptions()
        option.deliveryMode = deliveryMode
        option.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: option) { avAsset, _, _ in
            DispatchQueue.main.async {
                completion(avAsset)
            }
        }
    }
}

extension AssetLibrary {
    private func fetchAlbumData() {
        albums.removeAll()
        
        func append(_ result: PHFetchResult<PHAsset>, _ name: String) {
            if result.count <= 0 { return }
            
            var assets = [PHAsset]()
            result.enumerateObjects { asset, _, _ in
                assets.append(asset)
            }
            
            albums.append(ALInfo(assets: assets.reversed(), localizedTitle: name))
        }
        
        append(PHAsset.fetchAssets(with: albumType, options: nil), "Recents")
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        
        [userAlbums, smartAlbums].forEach({
            $0.enumerateObjects { [self] (collection, _, _) in
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", albumType.rawValue)
                let result = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                let count = result.count
                
                if count > 0 && collection.localizedTitle != "Recents" {
                    append(result, collection.localizedTitle ?? "")
                }
            }
        })
    }
}
