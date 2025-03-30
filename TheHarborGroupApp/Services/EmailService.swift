import Foundation

class EmailService {
    static let shared = EmailService()
    
    private let apiKey = "RESEND_API_KEY_HERE" // Replace with your actual Resend API key
    private let baseUrl = "https://api.resend.com"
    
    private init() {}
    
    func sendEmail(to recipient: String, subject: String, htmlContent: String) async throws {
        guard let url = URL(string: "\(baseUrl)/emails") else {
            throw URLError(.badURL)
        }
        
        let emailRequest = EmailRequest(
            from: "Harbor Group <notifications@yourdomain.com>", // Replace with your verified domain
            to: [recipient],
            subject: subject,
            html: htmlContent
        )
        
        let encoder = JSONEncoder()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try encoder.encode(emailRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "EmailService", code: 1003, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
    }
    
    // Template for notification emails
    func sendTicketNotification(to email: String, ticketTitle: String, message: String) async throws {
        let subject = "Ticket Update: \(ticketTitle)"
        
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; }
                .container { padding: 20px; max-width: 600px; margin: 0 auto; }
                .header { background-color: #4A6572; color: white; padding: 10px; text-align: center; }
                .content { padding: 20px; }
                .footer { font-size: 12px; color: #666; text-align: center; margin-top: 20px; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h2>Harbor Group Notification</h2>
                </div>
                <div class="content">
                    <p>Hello,</p>
                    <p>\(message)</p>
                    <p>Ticket: <strong>\(ticketTitle)</strong></p>
                    <p>Please log in to the Harbor Group app to view more details.</p>
                </div>
                <div class="footer">
                    <p>© \(Calendar.current.component(.year, from: Date())) Harbor Group. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        try await sendEmail(to: email, subject: subject, htmlContent: htmlContent)
    }
}

// Structure for the Resend API request
private struct EmailRequest: Codable {
    let from: String
    let to: [String]
    let subject: String
    let html: String
}
