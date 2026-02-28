package com.spring.hotel_management_backend.model.dto.request.admin.hr;

import lombok.Data;
import java.time.LocalDate;

@Data
public class UpdateEmployeeRequest {
    private String employeeId;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private String position;
    private Integer departmentId;
    private String employmentType;
    private String employmentStatus;
    private Double basicSalary;
    private LocalDate joiningDate;
    private String emergencyContact;
    private String emergencyPhone;
    private String address;
}