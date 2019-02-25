// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// 取消
  internal static let cancel = L10n.tr("Localizable", "Cancel")
  /// 确认
  internal static let confirm = L10n.tr("Localizable", "Confirm")
  /// 确认删除?
  internal static let confirmDelete = L10n.tr("Localizable", "ConfirmDelete")
  /// 日期
  internal static let date = L10n.tr("Localizable", "Date")
  /// 删除失败
  internal static let deleteFail = L10n.tr("Localizable", "DeleteFail")
  /// 删除成功
  internal static let deleteSuccess = L10n.tr("Localizable", "DeleteSuccess")
  /// 删除中...
  internal static let deleting = L10n.tr("Localizable", "Deleting")
  /// 详细
  internal static let detail = L10n.tr("Localizable", "Detail")
  /// 尺寸
  internal static let dimention = L10n.tr("Localizable", "Dimention")
  /// 下载失败
  internal static let downloadFail = L10n.tr("Localizable", "DownloadFail")
  /// 下载中...
  internal static let downloading = L10n.tr("Localizable", "Downloading")
  /// 下载成功
  internal static let downloadSuccess = L10n.tr("Localizable", "DownloadSuccess")
  /// 时长
  internal static let duration = L10n.tr("Localizable", "Duration")
  /// 格式
  internal static let format = L10n.tr("Localizable", "Format")
  /// 加载失败，请检查飞机的连接状态。
  internal static let loadingFail = L10n.tr("Localizable", "LoadingFail")
  /// 正在加载图片列表...
  internal static let loadingList = L10n.tr("Localizable", "LoadingList")
  /// 加载超时，请稍后再试。
  internal static let loadingTimeout = L10n.tr("Localizable", "LoadingTimeout")
  /// 没有媒体文件
  internal static let noMediaFiles = L10n.tr("Localizable", "NoMediaFiles")
  /// 选择
  internal static let select = L10n.tr("Localizable", "Select")
  /// 大小
  internal static let size = L10n.tr("Localizable", "Size")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: BundleToken.resourcesBundle, comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

