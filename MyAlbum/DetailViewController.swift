//
//  DetailViewController.swift
//  MyAlbum
//
//  Created by WG Yang on 2022/03/15.
//

import UIKit
import Photos

class DetailViewController: UIViewController, UIScrollViewDelegate {

    //이전 뷰컨트롤러에서 등록해줄 변수
    var photoAsset: PHAsset!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heartBarButtonItem: UIBarButtonItem!
    
    //에셋에서 이미지 생성할 imageManager
    let imageManager : PHImageManager = PHImageManager()
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
        //네비게이션바, 툴바 가리기
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
      imageManager.requestImage(for: photoAsset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: nil, resultHandler: {img, _ in self.imageView.image = img})
 
        self.navigationController?.hidesBarsOnTap = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.hidesBarsOnTap = false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
