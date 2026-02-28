package com.spring.hotel_management_backend.model.dto.request.admin.hr;

import lombok.Data;
import java.time.LocalDate;

@Data
public class AssignShiftRequest {
    private Long employeeId;
    private Long shiftId;
    private LocalDate effectiveFrom;
    private LocalDate effectiveTo;
    private String remarks;
}