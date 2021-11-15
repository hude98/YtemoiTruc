//
//  NotificationService.swift
//  CustomNotificationServicee
//
//  Created by Ta Huy Hung on 16/10/2021.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            print("bestAttemptContent.userInfo : \(bestAttemptContent.userInfo)")
            bestAttemptContent.title = "titleeee"
            bestAttemptContent.body = "bodyyyy"
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            print("bestAttemptContent.userInfo : \(bestAttemptContent.userInfo)")
            bestAttemptContent.subtitle = "(Encrypted)"
            bestAttemptContent.body = ""
            contentHandler(bestAttemptContent)
        }
    }
    
}
