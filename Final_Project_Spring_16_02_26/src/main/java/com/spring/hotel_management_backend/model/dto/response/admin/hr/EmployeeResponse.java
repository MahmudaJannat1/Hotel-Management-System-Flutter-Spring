package com.spring.hotel_management_backend.model.dto.response.admin.hr;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmployeeResponse {
    private Long id;
    private String employeeId;
    private Long userId;
    private String username;

    // Department
    private Long departmentId;
    private String departmentName;

    private String position;
    private LocalDate joiningDate;
    private LocalDate contractEndDate;
    private String employmentType;
    private String employmentStatus;

    // Salary
    private Double basicSalary;
    private Double houseRent;
    private Double medicalAllowance;
    private Double conveyanceAllowance;
    private Double otherAllowances;
    private Double totalSalary;

    // Personal
    private String firstName;
    private String lastName;
    private String fullName;
    private String email;
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
    private Integer age;

    // Identification
    private String nidNumber;
    private String passportNumber;
    private String drivingLicense;

    // Bank
    private String bankName;
    private String bankAccountNo;
    private String bankBranch;
    private String routingNo;

    // Other
    private String qualification;
    private String experience;
    private String skills;
    private String profileImageUrl;
    private String shift;
    private Long shiftId;
    private String reportingTo;
    private Long reportingManagerId;
    private String bloodGroup;
    private String religion;
    private String remarks;

    private Boolean isActive;
    private Long hotelId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Statistics
    private Integer totalPresentDays;
    private Integer totalAbsentDays;
    private Integer totalLeaveDays;
    private Double totalOvertimeHours;
    private Double totalSalaryPaid;
}