//
//  MediaFile.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/8/23.
//  Copyright © 2018年 kiwi. All rights reserved.
//

import DJISDK

public protocol MediaFileBrowsable: class {
    var isSelected: Bool { get set }
    var thumbnailImage: UIImage? { get set }
}

public class MediaFileModel: MediaFileBrowsable {
    public var isSelected: Bool = false
    public var thumbnailImage: UIImage?
    public var djiMediaFile: DJIMediaFile
    
    public init(djiMediaFile: DJIMediaFile) {
        self.djiMediaFile = djiMediaFile
        self.thumbnailImage = djiMediaFile.thumbnail
    }
}
