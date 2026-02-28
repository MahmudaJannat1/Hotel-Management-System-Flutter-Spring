package com.spring.hotel_management_backend.model.dto.response.admin.reports;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportExportResponse {

    private Boolean success;
    private String message;
    private String fileName;
    private String fileType; // PDF, EXCEL, CSV
    private String fileUrl;
    private Long fileSize;
    private String downloadUrl;
    private String generatedAt;
}
