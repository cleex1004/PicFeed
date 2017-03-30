//
//  CloudKit.swift
//  picfeed
//
//  Created by Christina Lee on 3/27/17.
//  Copyright © 2017 Christina Lee. All rights reserved.
//

import Foundation
import CloudKit

typealias PostCompletion = (Bool) -> ()

class CloudKit {
    static let shared = CloudKit()
    
    let container = CKContainer.default()
    var privateDatabase : CKDatabase {
        return self.container.privateCloudDatabase
    }
    
    func save(post: Post, completion: @escaping PostCompletion) {
        do {
            if let record = try Post.recordFor(post: post) {
                privateDatabase.save(record, completionHandler: { (record, error) in
                    if error != nil {
                        completion(false)
                    }
                    if let record = record {
                        print(record)
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
            }
        } catch {
            print(error)
        }
    }
}
