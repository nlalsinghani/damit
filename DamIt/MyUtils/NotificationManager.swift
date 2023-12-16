//
//  NotificationManager.swift
//  DamIt
//
//  Created by kishanS on 10/28/20.
//

import Foundation
import UIKit
import UserNotifications

class NotificationManager {
    let notificationID = "dailyNotification"
    
    func scheduleNotifications(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let windowInSeconds: UInt32 = 60*60*5
        let oneDayInSeconds: Double = 60*60*24
        let windowAroundHour = 14

        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        calendar?.timeZone = NSTimeZone.local

        if let todayAtWindowHour = calendar?.date(bySettingHour: windowAroundHour, minute: 0, second: 0, of: NSDate() as Date, options: .matchFirst)?.timeIntervalSinceReferenceDate {
                   for index in 1...48 {
                       var notificationDate = ( todayAtWindowHour + ( Double(index) * oneDayInSeconds ) )

                       // either remove or add anything up to the window
                       if arc4random_uniform(2) == 0 {
                           notificationDate = notificationDate + Double(arc4random_uniform(windowInSeconds))
                       } else {
                           notificationDate = notificationDate - Double(arc4random_uniform(windowInSeconds))
                       }

                       let fireDate = Date(timeIntervalSinceReferenceDate: notificationDate)
                       let notification = UNMutableNotificationContent()
                       notification.title = "Time to build that Dam!"
                       notification.subtitle = "Check back in and beat some levels!"
                       let triggerdate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: fireDate)
                       let trigger = UNCalendarNotificationTrigger(dateMatching: triggerdate, repeats: false)
                       let notificationRequest =  UNNotificationRequest(identifier: "notification", content: notification, trigger: trigger)
                       UNUserNotificationCenter.current().add(notificationRequest)
                       print("Set for: \(fireDate)")
                   }
        }
       print("Finished scheduling reminder notifications")
    }
    
    
    func unscheduleNotifications(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
}
