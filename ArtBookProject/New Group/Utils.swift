//
//  Utils.swift
//  ArtBookProject
//
//  Created by Abdullah Oğuz on 11.03.2021.
//

import Foundation
import UIKit

class Utils {
    static func delegateUtils() -> Void {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        return context
    }
}
