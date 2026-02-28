package com.spring.hotel_management_backend.model.dto.request.admin.hr;

import lombok.Data;
import java.time.LocalDate;

@Data
public class LeaveRequest {
    private Long employeeId;
    private String leaveType; // ANNUAL, SICK, EMERGENCY, MATERNITY, PATERNITY, UNPAID
    private LocalDate startDate;
    private LocalDate endDate;
    private String reason;
    private String contactDuringLeave;
    private String handoverNotes;
    private Boolean isPaid;
}