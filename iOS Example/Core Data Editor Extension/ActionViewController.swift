//
//  ActionViewController.swift
//  Core Data Editor Extension
//
//  Created by Daniel Strokis on 9/22/14.
//  Copyright (c) 2014 Thermal Core. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        for item: AnyObject in self.extensionContext!.inputItems {
            let inputItem = item as NSExtensionItem
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as NSItemProvider
            }
        }
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }

}
