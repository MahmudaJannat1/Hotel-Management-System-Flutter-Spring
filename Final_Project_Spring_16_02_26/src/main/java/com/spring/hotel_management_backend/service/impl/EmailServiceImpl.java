package com.spring.hotel_management_backend.service.impl;

import com.spring.hotel_management_backend.service.EmailService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@Slf4j
public class EmailServiceImpl implements EmailService {

    @Override
    public void sendEmail(String to, String subject, String body) {
        // In production, integrate with JavaMailSender or SendGrid
        log.info("Sending email to: {}, subject: {}, body: {}", to, subject, body);
        System.out.println("📧 Email sent to: " + to);
        System.out.println("Subject: " + subject);
        System.out.println("Body: " + body);
    }

    @Override
    public void sendEmailWithHtml(String to, String subject, String htmlBody) {
        log.info("Sending HTML email to: {}, subject: {}", to, subject);
        System.out.println("📧 HTML Email sent to: " + to);
        System.out.println("Subject: " + subject);
        System.out.println("HTML Body: " + htmlBody);
    }

    @Override
    public void sendEmailWithAttachment(String to, String subject, String body, String attachmentPath) {
        log.info("Sending email with attachment to: {}, subject: {}, attachment: {}", to, subject, attachmentPath);
        System.out.println("📧 Email with attachment sent to: " + to);
        System.out.println("Subject: " + subject);
        System.out.println("Attachment: " + attachmentPath);
    }

    @Override
    public void sendBulkEmail(List<String> recipients, String subject, String body) {
        log.info("Sending bulk email to {} recipients, subject: {}", recipients.size(), subject);
        System.out.println("📧 Bulk email sent to " + recipients.size() + " recipients");
        System.out.println("Subject: " + subject);
    }
}