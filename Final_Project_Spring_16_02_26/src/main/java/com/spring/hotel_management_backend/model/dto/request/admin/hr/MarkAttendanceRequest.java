package com.spring.hotel_management_backend.model.dto.request.admin.hr;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalTime;

@Data
public class MarkAttendanceRequest {
    private Long employeeId;
    private LocalDate date;
    private LocalTime checkInTime;
    private LocalTime checkOutTime;
    private String status; // PRESENT, ABSENT, HALF_DAY, LATE, OVERTIME
    private String remarks;
    private Boolean isApproved;
}