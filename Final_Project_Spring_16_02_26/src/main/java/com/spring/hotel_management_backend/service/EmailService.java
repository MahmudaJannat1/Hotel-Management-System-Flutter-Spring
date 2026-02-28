package com.spring.hotel_management_backend.service;

import java.util.List;

public interface EmailService {
    void sendEmail(String to, String subject, String body);
    void sendEmailWithHtml(String to, String subject, String htmlBody);
    void sendEmailWithAttachment(String to, String subject, String body, String attachmentPath);
    void sendBulkEmail(List<String> recipients, String subject, String body);
}