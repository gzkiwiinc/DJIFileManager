//
//  MediaFileAttribute.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/9/4.
//  
//

import Foundation
import DJISDK

/// basic attribute of the media file
///
/// - date: the time when the file was created
/// - size: the data size of the media file
/// - dimension: the resolution of the video
/// - duration: the duration of the video
/// - format: the frame rate of the video
enum MediaFileAttribute {
    case date, size, dimension, duration, format
    
    var description: String {
        switch self {
        case .date:
            return L10n.date
        case .size:
            return L10n.size
        case .dimension:
            return L10n.dimention
        case .duration:
            return L10n.duration
        case .format:
            return L10n.format
        }
    }
}

extension DJIMediaFile {
    /// get the string value for the corresponding MediaFileAttribute
    func getStringValueOfAttribute(_ attribute: MediaFileAttribute) -> String {
        switch attribute {
        case .date:
            return timeCreated
        case .size:
            return FormatterUtility.byteCountFormatter.string(fromByteCount: fileSizeInBytes)
        case .dimension:
            return resolution.description
        case .duration:
            return FormatterUtility.durationTimeFormatter.string(from: Double(durationInSeconds)) ?? ""
        case .format:
            return frameRate.description
        }
    }
}
