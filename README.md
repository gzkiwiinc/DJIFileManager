# DJIFileManger

![iOS 9.0+](https://img.shields.io/badge/iOS-9.0%2B-blue.svg)   ![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg)  ![MIT](https://img.shields.io/github/license/gzkiwiinc/DJIFileManager.svg)

DJIFileManger 是一个基于 [DJI-SDK-iOS](https://developer.dji.com/mobile-sdk/) 和 [DJISDKExtension](https://github.com/gzkiwiinc/DJISDKExtension) 的简单媒体文件管理工具。它提供了缩略图浏览界面，单张预览图浏览，媒体文件信息查看，以及下载分享等功能。

DJIFileManger is a simple media files manager for DJI product. It's base on [DJI-SDK-iOS](https://developer.dji.com/mobile-sdk/) and [DJISDKExtension](https://github.com/gzkiwiinc/DJISDKExtension). DJIFileManager provides thumbnail browsing, single preview browsing, media file information, as well as download and share functions, etc.

## Features

- [x] 缩略图浏览，分段加载。
- [x] 单张预览图查看和分享。
- [x] 多选下载，保存图片或视频文件到系统相册。
- [x] 默认提供黑色和白色主题。

## ScreenShot

加载缩略图 | 查看预览图及删除操作
---|---
![](https://github.com/gzkiwiinc/DJIFileManager/blob/develop/Screenshots/loadMedias.gif) | ![](https://github.com/gzkiwiinc/DJIFileManager/blob/develop/Screenshots/browser.gif)

## Requirements

- iOS 9.0+
- Swift 4.2

## Installation

DJIFileManger is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'DJIFileManger'
```

## Usage

```Swift
import DJIFileManager

// DJIFileManagerLightTheme or DJIFileManagerDarkTheme
let theme: DJIFileManagerTheme.Type = DJIFileManagerLightTheme.self
let mediaFilesViewController = DJIMediaFilesViewController(style: theme)
navigationController?.pushViewController(mediaFilesViewController, animated: true)
```

本项目提供了 `FileManagerExample` 作为例子，运行起来后，点击 connect 连接无人机，当顶部状态显示 Acivated 和 Bound 即可点击 DJIFileManager 进入。

![](https://github.com/gzkiwiinc/DJIFileManager/blob/develop/Screenshots/DJIFileMangerExample.png)


## License

DJIFileManger is available under the MIT license. See the [LICENSE](https://github.com/gzkiwiinc/DJIFileManager/blob/master/LICENSE) file for more info. 

