package com.spring.hotel_management_backend.model.dto.request.admin.hr;

import lombok.Data;
import java.time.YearMonth;

@Data
public class GeneratePayrollRequest {
    private YearMonth month;
    private Long departmentId; // Optional - if null, generate for all employees
    private Long employeeId; // Optional - for single employee
    private String generatedBy;
}