import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    /// Schedule daily reminder at specified time
    func scheduleDailyReminder(at components: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = "Today's BackFlow session"
        content.body = "Time for your rehab session. Let's keep building capacity."
        content.sound = .default
        content.userInfo = ["deepLink": "backflow://today"]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule daily reminder: \(error)")
            }
        }
    }
    
    /// Schedule next-day check-in reminder (24h after session)
    func scheduleNextDayCheckIn(sessionDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "How did your back feel today?"
        content.body = "Quick check-in to track your 24-hour response."
        content.sound = .default
        content.userInfo = ["deepLink": "backflow://log?s=nextday"]
        
        // Schedule for 24 hours + 8 hours (next morning)
        let triggerDate = Calendar.current.date(byAdding: .hour, value: 32, to: sessionDate) ?? Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "nextDayCheckIn-\(sessionDate.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule next-day check-in: \(error)")
            }
        }
    }
    
    /// Cancel all notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
