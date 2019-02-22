//
//  Theme.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/8/24.
//

import Foundation

var djiFileManagerTheme: DJIFileManagerTheme.Type = DJIFileManagerLightTheme.self

/// The theme of DJIFileManager
public protocol DJIFileManagerTheme {
    /// the background view's color
    static var backgroundColor: UIColor { get }
    
    /// the main color of the UI, including the text color of buttons, the thumbnail cell's background color(with 0.4 alpha) when selected
    static var themeColor: UIColor { get }
    
    /// the attribute label's color in the detail view of mediaFile
    static var textColor: UIColor { get }
    
    /// the title's color in navigationbar and the attribute info label's color in the detail view of mediaFile
    static var lightTextColor: UIColor { get }
    
    /// the subtitle's color which on the bottom right corner of the thumbnail cell
    static var thumbnailCellSubtitleColor: UIColor { get }
    
    /// the seperate line color
    static var separatorColor: UIColor { get }
}

extension DJIFileManagerTheme {
    public static var thumbnailCellSubtitleColor: UIColor {
        return UIColor.white
    }
}

public enum DJIFileManagerDarkTheme: DJIFileManagerTheme {
    public static let backgroundColor = UIColor.black
    public static let themeColor = UIColor(red: 0.0, green: 95.0 / 255.0, blue: 1.0, alpha: 1.0)
    public static let textColor = UIColor.white
    public static let lightTextColor = UIColor.white.withAlphaComponent(0.6)
    public static let separatorColor = UIColor(white: 50.0 / 255.0, alpha: 1.0)
}

public enum DJIFileManagerLightTheme: DJIFileManagerTheme {
    public static let backgroundColor = UIColor.white
    public static let themeColor = UIColor(red: 63.0 / 255.0, green: 170.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
    public static let textColor = UIColor(red: 56.0 / 255.0, green: 61.0 / 255.0, blue: 65.0 / 255.0, alpha: 1.0)
    public static let lightTextColor = UIColor(red: 149.0 / 255.0, green: 159.0 / 255.0, blue: 166.0 / 255.0, alpha: 1.0)
    public static let separatorColor = UIColor(white: 223.0 / 255.0, alpha: 1.0)
}
