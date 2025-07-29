import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private init() {}
    
    // MARK: - Notification Permission
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Schedule Notifications
    func scheduleHerbReminder(herbName: String, dosage: String, time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Herb Reminder"
        content.body = "Time to take your \(herbName): \(dosage)"
        content.sound = .default
        
        // Create date components for the specific time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "herb_reminder_\(herbName)_\(time.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleDosageReminder(herbName: String, frequency: String) {
        let content = UNMutableNotificationContent()
        content.title = "Dosage Reminder"
        content.body = "Don't forget your \(herbName) - \(frequency)"
        content.sound = .default
        
        // Schedule for 2 hours from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2 * 60 * 60, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "dosage_reminder_\(herbName)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling dosage reminder: \(error)")
            }
        }
    }
    
    func schedulePreparationReminder(herbName: String, preparationTime: String) {
        let content = UNMutableNotificationContent()
        content.title = "Preparation Reminder"
        content.body = "Time to prepare your \(herbName) - \(preparationTime)"
        content.sound = .default
        
        // Schedule for 1 hour from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "preparation_reminder_\(herbName)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling preparation reminder: \(error)")
            }
        }
    }
    
    // MARK: - Cancel Notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelHerbNotifications(herbName: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let herbRequests = requests.filter { $0.identifier.contains("herb_reminder_\(herbName)") }
            let identifiers = herbRequests.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    // MARK: - Get Pending Notifications
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    // MARK: - Daily Wellness Reminder
    func scheduleDailyWellnessReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Wellness Check"
        content.body = "Take a moment to check your herbal remedies and wellness routine"
        content.sound = .default
        
        // Schedule for 9 AM daily
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_wellness_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily wellness reminder: \(error)")
            }
        }
    }
} 