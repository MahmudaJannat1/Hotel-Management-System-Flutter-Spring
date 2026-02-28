package com.spring.hotel_management_backend.model.dto.request.admin.hr;

import lombok.Data;

@Data
public class ApproveLeaveRequest {
    private Long leaveId;
    private String status; // APPROVED, REJECTED
    private String rejectionReason;
    private String approvedBy;
}