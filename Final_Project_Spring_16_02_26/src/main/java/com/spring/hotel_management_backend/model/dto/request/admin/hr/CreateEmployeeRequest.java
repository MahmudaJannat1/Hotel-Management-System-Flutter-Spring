package com.spring.hotel_management_backend.model.dto.request.admin.hr;

import lombok.Data;
import java.time.LocalDate;

@Data
public class CreateEmployeeRequest {
    // User account (optional - if employee needs system access)
    private Boolean createUserAccount;
    private String username;
    private String email;
    private String password;

    // Employee details
    private String employeeId;
    private Long departmentId;
    private String position;
    private LocalDate joiningDate;
    private LocalDate contractEndDate;
    private String employmentType; // FULL_TIME, PART_TIME, CONTRACT, INTERN

    // Salary details
    private Double basicSalary;
    private Double houseRent;
    private Double medicalAllowance;
    private Double conveyanceAllowance;
    private Double otherAllowances;

    // Personal details
    private String firstName;
    private String lastName;
    private String phone;
    private String alternativePhone;
    private String emergencyContact;
    private String emergencyPhone;
    private String address;
    private String city;
    private String state;
    private String country;
    private String postalCode;
    private LocalDate dateOfBirth;
    private String gender;
    private String maritalStatus;
    private String nationality;

    // Identification
    private String nidNumber;
    private String passportNumber;
    private String drivingLicense;

    // Bank details
    private String bankName;
    private String bankAccountNo;
    private String bankBranch;
    private String routingNo;

    // Other
    private String qualification;
    private String experience;
    private String skills;
    private String profileImageUrl;
    private Long shiftId;
    private String reportingTo;
    private Long reportingManagerId;
    private String bloodGroup;
    private String religion;
    private String remarks;

    private Long hotelId;
}