//
//  SharePhotosActivityItemSource.swift
//  MyAlbum
//
//  Created by WG Yang on 2022/03/21.
//

import Foundation
import UIKit

class SharePhotosActivityItemSource: NSObject, UIActivityItemSource {

    var title: String
    var photos: [UIImage]
    
    init(title: String, photos: [UIImage]) {
        self.title = title
        self.photos = photos
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return photos
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return photos
    }
    
    
}
