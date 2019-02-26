//
//  MediaFilesViewController.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/8/24.
//

import UIKit
import SnapKit
import PromiseKit
import DJISDK
import MJRefresh

public class DJIMediaFilesViewController: UIViewController {

    var collectionView: UICollectionView!
    lazy var selectButton = UIBarButtonItem(title: L10n.select, style: .plain, target: self, action: #selector(selectMediaFile))
    lazy var bottomToolBar = BottomToolBar()
    
    public var mediaFileModelList = [MediaFileModel]()
    
    private var placeholderStateView = PlaceholderStateView()
    private var djiMediaFileList = [DJIMediaFile]()
    private var isSelectionState = false
    private var selectedMediaFiles = [MediaFileModel]()
    private let cellId = "MediaFileCollectionViewCell"
    private var currentDownloadIndex = 0
    private var mediaFileIndex = 0
    private var page = 1
    // 每次加载的数量
    private var batchCount = 32
    
    public init(style: DJIFileManagerTheme.Type) {
        djiFileManagerTheme = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchMediaFilesSnapshot()
    }
}

extension DJIMediaFilesViewController {
    private func setupView() {
        selectButton.tintColor = djiFileManagerTheme.themeColor
        navigationController?.navigationBar.barTintColor = djiFileManagerTheme.backgroundColor
        
        setupCollectionView()
        setupBottomToolBar()
    }
    
    private func setupCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        let space: CGFloat = 2.0
        let itemNum: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 7 : 4
        let itemSpace = space * (itemNum - 1)
        let itemWidth = (UIScreen.main.bounds.width - itemSpace) / itemNum
        collectionViewLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        collectionViewLayout.scrollDirection = .vertical
        collectionViewLayout.minimumLineSpacing = space
        collectionViewLayout.minimumInteritemSpacing = space
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = djiFileManagerTheme.backgroundColor
        collectionView.register(MediaFileCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.mj_footer = MJRefreshAutoNormalFooter {
            self.loadMoreMediaFiles()
        }
        collectionView.mj_footer.isHidden = true
        
        placeholderStateView.setup(state: .loading)
        collectionView.addSubview(placeholderStateView)
        placeholderStateView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(49)
            make.height.equalTo(100)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupBottomToolBar() {
        bottomToolBar.shareButton.image = nil
        bottomToolBar.bottomToolBarDelegate = self
        
        view.addSubview(bottomToolBar)
        bottomToolBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(49)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(self.bottomLayoutGuide.snp.bottom)
            }
        }
        bottomToolBar.isHidden = true
    }
    
    private func fetchMediaFilesSnapshot() {
        guard let camera = DJISDKManager.product()?.camera
            , let mediaManager = camera.mediaManager else {
            self.placeholderStateView.setup(state: .fail)
            return
        }
        
        firstly {
            camera.setMode(.mediaDownload)
        }.then {
            camera.getStorageLocation()
        }.then { storgeLoaction in
            mediaManager.fetchMediaFileListSnapshot(storageLocation: storgeLoaction)
        }.then { fileList -> Promise<Void> in
            return self.fetchMediaThumbnail(mediaFileList: fileList)
        }.done {
            self.navigationItem.rightBarButtonItem = self.selectButton
            self.collectionView.mj_footer.isHidden = false
            self.collectionView.mj_footer.endRefreshing()
            self.collectionView.reloadData()
        }.catch { error in
            self.placeholderStateView.setup(state: .timeout)
            print(error.localizedDescription)
        }
    }
    
    @objc private func selectMediaFile() {
        toggleSelectionState()
    }
    
    private func toggleSelectionState() {
        isSelectionState = !isSelectionState
        selectButton.title = isSelectionState ? L10n.cancel : L10n.select
        bottomToolBar.isHidden = !isSelectionState
        if !isSelectionState {
            mediaFileModelList.forEach { $0.isSelected = false }
            self.collectionView.reloadData()
        }
    }
    
    private func deleteCollectionViewItems(at indexPaths: [IndexPath], newMeidaFiles: [MediaFileModel]) {
        mediaFileModelList = newMeidaFiles
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: indexPaths)
        }, completion: nil)
        
        if mediaFileModelList.count == 0 {
            placeholderStateView.setup(state: .noData)
        }
    }
    
    private func fetchMediaThumbnail(mediaFileList: [DJIMediaFile]) -> Promise<Void> {
        collectionView.mj_footer.isHidden = true
        if mediaFileList.count == 0 {
            placeholderStateView.setup(state: .noData)
            return Promise.value(())
        } else {
            djiMediaFileList = mediaFileList.reversed()
            return self.fetchMediaContent(index: self.mediaFileIndex, contentType: .thumbnail)
        }
    }
    
    private func fetchMediaContent(index: Int, contentType: DJIFetchMediaTaskContent) -> Promise<Void> {
        guard let camera = DJISDKManager.product()?.camera
            , let mediaManager = camera.mediaManager else {
            return Promise(error: MediaFileManagerError.cameraNotReady)
        }
        
        mediaFileIndex = index
        if index >= djiMediaFileList.count || index >= batchCount * page {
            return Promise.value(())
        }
        let mediaFile = djiMediaFileList[mediaFileIndex]
        return mediaManager.fetchMediaContent(mediaFile: mediaFile, mediaContentType: contentType).then { mediaFile -> Promise<Void> in
            self.mediaFileModelList.append(MediaFileModel(djiMediaFile: mediaFile))
            self.collectionView.reloadData()
            return self.fetchMediaContent(index: self.mediaFileIndex + 1, contentType: contentType)
        }
    }
    
    private func downloadMedia(index: Int = 0,
                       downLoadProgress: @escaping (_ index: Int, _ progress: CGFloat) -> Void) -> Promise<Void> {
        if index >= self.selectedMediaFiles.count {
            return Promise.value(())
        }
        let mediaFile = selectedMediaFiles[index].djiMediaFile
        return MediaFileManager.downloadMediaFile(mediaFile) { (progress) in
            downLoadProgress(index, progress)
        }.then { _ in
            return self.downloadMedia(index: index + 1, downLoadProgress: downLoadProgress)
        }
    }
    
    private func deleteMediaFile() {
        guard let camera = DJISDKManager.product()?.camera
            , let mediaManager = camera.mediaManager else {
            let resultAlert = UIAlertController(title: L10n.deleteFail, message: "", preferredStyle: .alert)
            resultAlert.addAction(UIAlertAction(title: L10n.confirm, style: .default))
            present(resultAlert, animated: true, completion: nil)
            return
        }
        
        let statusAlert = UIAlertController(title: L10n.deleting, message: "", preferredStyle: .alert)
        self.present(statusAlert, animated: true, completion: nil)
        
        var toDeleteItemIndexPaths = [IndexPath]()
        var toDeleteDJIMediaFiles = [DJIMediaFile]()
        var leftMediaFiles = [MediaFileModel]()
        for (index, mediaFile) in mediaFileModelList.enumerated() {
            if mediaFile.isSelected == true {
                toDeleteItemIndexPaths.append(IndexPath(item: index, section: 0))
                toDeleteDJIMediaFiles.append(mediaFile.djiMediaFile)
            } else {
                leftMediaFiles.append(mediaFile)
            }
        }
        
        firstly {
            mediaManager.deleteMediaFiles(toDeleteDJIMediaFiles)
        }.done {
            statusAlert.dismiss(animated: true, completion: nil)
            self.deleteCollectionViewItems(at: toDeleteItemIndexPaths, newMeidaFiles: leftMediaFiles)
            self.toggleSelectionState()
        }.catch { error in
            statusAlert.dismiss(animated: true) {
                let resultAlert = UIAlertController(title: L10n.deleteFail, message: error.localizedDescription, preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: L10n.confirm, style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            }
        }
    }
    
    private func loadMoreMediaFiles() {
        if mediaFileIndex >= djiMediaFileList.count {
            collectionView.mj_footer.endRefreshingWithNoMoreData()
        } else {
            page += 1
            fetchMediaFilesSnapshot()
        }
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension DJIMediaFilesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        placeholderStateView.isHidden = mediaFileModelList.count > 0
        collectionView.mj_footer.isHidden = mediaFileModelList.count < batchCount
        return mediaFileModelList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MediaFileCollectionViewCell
        cell.configureCell(model: mediaFileModelList[indexPath.row])
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = collectionView.cellForItem(at: indexPath) as! MediaFileCollectionViewCell
        if isSelectionState {
            mediaFileModelList[indexPath.row].isSelected = !mediaFileModelList[indexPath.row].isSelected
            selectedItem.configureCell(model: mediaFileModelList[indexPath.row])
        } else {
            let mediaFileBrowser = MediaBrowserViewController(mediaFiles: mediaFileModelList, initialMedia: mediaFileModelList[indexPath.row], referenceView: selectedItem)
            mediaFileBrowser.delegate = self
            self.present(mediaFileBrowser, animated: true, completion: nil)
        }
    }
}


// MARK: - BottomToolBarDelegate

extension DJIMediaFilesViewController: BottomToolBarDelegate {
    func downloadButtonDidClicked() {
        selectedMediaFiles = mediaFileModelList.filter { $0.isSelected == true }
        
        currentDownloadIndex = 0
        
        let resultAlert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        resultAlert.addAction(UIAlertAction(title: L10n.confirm, style: .default))
        
        let statusAlert = UIAlertController(title: L10n.downloading, message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: L10n.cancel, style: .cancel) { _ in
            self.selectedMediaFiles[self.currentDownloadIndex].djiMediaFile.stopFetchingFileData(completion: nil)
        }
        statusAlert.addAction(cancelAction)
        present(statusAlert, animated: true, completion: nil)
        
        firstly {
            self.downloadMedia(index: currentDownloadIndex) { (index, progress) in
                self.currentDownloadIndex = index
                statusAlert.message = "\(index + 1) / \(self.selectedMediaFiles.count)" + ": " + String(format: "%.2f", progress) + "%"
            }
        }.done {
            statusAlert.dismiss(animated: true) {
                resultAlert.message = L10n.downloadSuccess
                self.present(resultAlert, animated: true, completion: nil)
            }
            self.toggleSelectionState()
        }.catch { error in
            statusAlert.dismiss(animated: true) {
                resultAlert.title = L10n.downloadFail
                var errorMessage = error.localizedDescription
                if let error = error as? MediaFileManagerError {
                    errorMessage = error.errorDescription
                }
                resultAlert.message = errorMessage
                self.present(resultAlert, animated: true, completion: nil)
            }
        }
    }
    
    func deleteButtonDidClicked() {
        let alert = UIAlertController(title: L10n.confirmDelete, message: "", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: L10n.confirm, style: .destructive) { _ in
            self.deleteMediaFile()
        }
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
}


// MARK: - MediaBrowserDelegate

extension DJIMediaFilesViewController: MediaBrowserDelegate {
    func mediaBrowser(_ mediaBrowser: MediaBrowserViewController, referenceViewForMedia media: MediaFileBrowsable) -> UIView? {
        if let index = mediaFileModelList.index(where: { $0 === media }) {
            let currentSelectedIndexPath = IndexPath(item: index, section: 0)
            if let cell = collectionView.cellForItem(at: currentSelectedIndexPath) as? MediaFileCollectionViewCell {
                return cell.imageView
            }
        }
        return nil
    }

    func mediaBrowser(_ mediaBrowser: MediaBrowserViewController, didDeletedMedia media: MediaFileBrowsable, at index: Int) {
        let newMediaFiles = mediaFileModelList.filter { $0 !== media }
        if index < mediaFileModelList.count {
            deleteCollectionViewItems(at: [IndexPath(item: index, section: 0)], newMeidaFiles: newMediaFiles)
        }
    }
}
