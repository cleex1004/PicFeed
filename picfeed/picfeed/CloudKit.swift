//
//  CloudKit.swift
//  picfeed
//
//  Created by Christina Lee on 3/27/17.
//  Copyright © 2017 Christina Lee. All rights reserved.
//

import Foundation
import CloudKit

class CloudKit {
    static let shared = CloudKit()
    
    let container = CKContainer.default()
    var privateDatabase : CKDatabase {
        return self.container.privateCloudDatabase
    }
}
