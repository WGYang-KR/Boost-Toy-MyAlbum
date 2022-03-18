//
//  PhotosViewController.swift
//  MyAlbum
//
//  Created by WG Yang on 2022/03/15.
//

import UIKit
import Photos

class PhotosViewController: UIViewController, UICollectionViewDataSource , UICollectionViewDelegate{
   
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectionBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var actionBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var sortingBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var trashBarButtonItem: UIBarButtonItem!
    
    let cellIdentifier: String = "photosCell"
    var pictures: PHFetchResult<PHAsset>!
    var albumName: String!
    var albumindex: Int!
    
    //PHAsset에서 image를 꺼내려면 사용해야함. 썸네일 생성에 특화된 image manager
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    //셀 가로 크기
    let cellWidth: CGFloat = UIScreen.main.bounds.width/3 - 5

    
    //MARK: 콜렌션뷰 datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: PhotosCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PhotosCollectionViewCell else {
            print("cell dequeue error")
            fatalError()
        }
        
        //image manager로 image 불러오기.
        imageManager.requestImage(for: pictures[indexPath.item], targetSize: CGSize(width: cellWidth, height: cellWidth), contentMode: PHImageContentMode.aspectFill , options: nil, resultHandler: {img, _ in cell.imageView?.image = img })
        
        return cell
  
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        //MARK: title 설정
        self.navigationItem.title = self.albumName
        
        //MARK: flowlayout 설정
        //1행 3열
        let flowlayout = UICollectionViewFlowLayout()
        
        flowlayout.itemSize = CGSize(width: cellWidth, height: cellWidth) // cell size
        flowlayout.sectionInset = UIEdgeInsets.zero //margin: 0
        flowlayout.minimumLineSpacing = 7.5 //줄 간격
        flowlayout.minimumInteritemSpacing = 7.5 // 열 간격
        self.collectionView.collectionViewLayout = flowlayout
    
        //MARK: '선택'버튼 초기화
        self.setNormalMode(selectionBarButtonItem)
        
    }
    
    //MARK: 셀 다중선택 구현
    var indexListSelected = [Int]() //선택된 사진 index 저장.
    
    @objc func setSelectMode(_ sender: UIBarButtonItem) {
        sender.title = "해제"
        sender.target = self
        sender.action = #selector(setNormalMode(_:))
        //툴바버튼 활성화
        self.sortingBarButtonItem.isEnabled = false
        self.navigationItem.hidesBackButton = true
        //콜렉션뷰 선택모드
        self.collectionView.allowsMultipleSelection = true
    }
    
    @objc func setNormalMode(_ sender: UIBarButtonItem) {
        sender.title = "선택"
        sender.target = self
        sender.action = #selector(setSelectMode(_:))
        //툴바버튼 비활성화
        self.sortingBarButtonItem.isEnabled = true
        self.actionBarButtonItem.isEnabled = false
        self.trashBarButtonItem.isEnabled = false
        self.navigationItem.hidesBackButton = false
        //콜렉션부 노말모드
        self.collectionView.allowsMultipleSelection = false
        //선택값 저장 배열 초기화
        print("\(indexListSelected): 초기화 예정 배열")
        self.indexListSelected = [Int]()
        //선택값 제거를 위해 리로드
        self.collectionView.reloadData()
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.item)번째 사진 선택됨")
        //셀 불투명으로 바꾸기
        collectionView.cellForItem(at: indexPath)?.alpha = 0.5
        
        //중복선택이 아니면 리스트에 추가
        if(!indexListSelected.contains(indexPath.item)) {
            indexListSelected.append(indexPath.item)
        }
        
        //리스트 비어있는 지 확인해서 툴바 활성화
        if(!indexListSelected.isEmpty) {
            self.actionBarButtonItem.isEnabled = true
            self.trashBarButtonItem.isEnabled = true
        } else {
                self.actionBarButtonItem.isEnabled = false
                self.trashBarButtonItem.isEnabled = false
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("\(indexPath.item)번째 사진 해제됨")
        collectionView.cellForItem(at: indexPath)?.alpha = 1
        
        //해당 인덱스 리스트에서 찾아서 삭제.
        let index: Int! = indexListSelected.firstIndex(of: indexPath.item)
        indexListSelected.remove(at: index)
       
        //리스트 비어있는 지 확인해서 툴바 활성화
        if(!indexListSelected.isEmpty) {
            self.actionBarButtonItem.isEnabled = true
            self.trashBarButtonItem.isEnabled = true
        } else {
                self.actionBarButtonItem.isEnabled = false
                self.trashBarButtonItem.isEnabled = false
        }
        
    }
    
    
    //MARK: 사진 삭제 구현
    @IBAction func removePhotos(_ sender: Any){
        
        var assets = [PHAsset]()
        
        for index in indexListSelected {
            
            assets.append(self.pictures[index])
        }
            
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        })
        
    }
    
    //MARK: 사진 공유 구현
    //MARK: 사진 정렬 구현
    //MARK: 사진 클릭 세그 구현
    //MARK: 라이브러리 상태 변경시.
        //선택된 사진 초기화.
        //라이브러리 다시 불러오기
    

    
    // MARK: - Navigation

/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
