//
//  ViewController.swift
//  MyAlbum
//
//  Created by WG Yang on 2022/03/15.
//

import UIKit
import Photos

class AlbumViewController: UIViewController, UICollectionViewDataSource {
    
    

    @IBOutlet weak var collectionView: UICollectionView!
    let cellIdentifier = "albumCell"

    let half : CGFloat = UIScreen.main.bounds.width/2 - 20
    
    // MARK: 라이브러리 앨범 불러오기
    var fetchResult: PHFetchResult<PHAsset>!
    var userAsset = [PHFetchResult<PHAsset>]() //앨범별 분류된 사진 저장
    var albumName = [String]() //앨범별 이름
    var assetCount = [Int]() //앨범별 사진수
    
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    //cell 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: AlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? AlbumCollectionViewCell else {
            print("cell dequeue error")
            fatalError()
        }
        
        //MARK: - 앨범리스트별 셀만들기
        //let asset: PHAsset = fetchResult.object(at: indexPath.item)
        
        //앨범별 처음사진 할당
        let img: PHAsset = userAsset[indexPath.item].object(at:0)
        
        cell.nameLabel.text = albumName[indexPath.item]
        cell.countLabel.text = "\(assetCount[indexPath.item])"
    
        imageManager.requestImage(for: img, targetSize: CGSize(width: half, height: half), contentMode: .aspectFill, options: nil, resultHandler: {img, _ in cell.imageView?.image = img })
        
        return cell
    }
    
    //cell 설정
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("셀 개수: \(self.userAsset.count)")
        return self.userAsset.count
    }
    
    func requestCollection() {
        let fetchOptions = PHFetchOptions()
        
        //최신순 정렬
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let listfet = PHFetchOptions()
        listfet.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: false)]
        //MARK: - 전체앨범
        //camera Roll 목록
        let cameraRoll: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        guard let cameraRollCollection = cameraRoll.firstObject else {
            print("전체 앨범 조회 실패")
            return
        }
        
        userAsset.append(PHAsset.fetchAssets(in:cameraRollCollection, options: fetchOptions))
        albumName.append("Camera Roll")
        assetCount.append(userAsset[0].count)
        
        //MARK: - 앨범리스트
        //앨범 리스트 받기
        let userAlbumList: PHFetchResult<PHAssetCollection>
        = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: listfet)
        let albumCount = userAlbumList.count
        let userAlbum: [PHAssetCollection]
        = userAlbumList.objects(at: IndexSet(0..<albumCount))
        
        //var userAsset = [PHFetchResult<PHAsset>]() 앨범별로 분류해서 사진저장
        //userAsset 인덱스 0에는 카메라롤 저장되었음.
        for i in 0..<albumCount {
            userAsset.append(PHAsset.fetchAssets(in: userAlbum[i], options: fetchOptions)) //앨범마다 사진저장
            print("\(i)번째 배열 \(userAlbum[i].localizedTitle!)의 사진 개수 \(userAsset[i+1].count)")
            assetCount.append(userAsset[i+1].count)
            albumName.append(userAlbum[i].localizedTitle!)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //MARK: 레이아웃 설정
        let heightSize: CGFloat = half + 40
        
        self.navigationItem.title = "앨범"
        
        //layout 설정
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: half , height: heightSize)
        flowlayout.sectionInset = UIEdgeInsets.zero
        flowlayout.minimumLineSpacing = 40
        flowlayout.minimumInteritemSpacing = 20 //같은 행끼리 간격
        self.collectionView.collectionViewLayout = flowlayout
        
        //MARK: 사진 라이브러리 접급권한 획득
        let photoAurhorization = PHPhotoLibrary.authorizationStatus()
        
        switch photoAurhorization {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .denied:
                    print("사용자가 사진 접근 거부")
                case .authorized:
                    print("사진 접근 허용 완료")
                    self.requestCollection()
                    OperationQueue.main.addOperation {
                        self.collectionView.reloadData()
                    }
                case .notDetermined: break
                case .restricted: break
                case .limited: break
                }
            })
        case .restricted: break
        case .denied: break
        case .authorized:
            print("사진 접근 이미 허용")
            self.requestCollection()
            OperationQueue.main.addOperation {
                self.collectionView.reloadData()
            }
        case .limited: break
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //사진을 눌렀을 때
        if segue.identifier == "photos" {
            
            //띄어질 뷰 컨트롤러 불러오기
            guard let nextView: PhotosViewController = segue.destination as? PhotosViewController else {
                return
            }
            
            //해당 셀 불러오기
            guard let cell: AlbumCollectionViewCell = sender as? AlbumCollectionViewCell else {
                return
            }
            
            //해당 셀 index 불러오기
            guard let index: IndexPath = self.collectionView.indexPath(for: cell) else {
                return
            }
            
            //선택된 앨범의 사진들을 다음 뷰컨트롤러에 넘겨줌.
            nextView.pictures = userAsset[index.item]
            nextView.albumName = albumName[index.item]
            nextView.albumindex = index.item
            print("선택된 앨범 index: \(index.item)")
        }
        
    }


}

