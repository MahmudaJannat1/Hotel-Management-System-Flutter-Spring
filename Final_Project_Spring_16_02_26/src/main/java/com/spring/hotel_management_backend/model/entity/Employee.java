package com.spring.hotel_management_backend.model.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "employees")
@Data
public class Employee extends BaseEntity {

    @OneToOne
    @JoinColumn(name = "user_id")
    private User user;

    private String employeeId;

    @ManyToOne
    @JoinColumn(name = "hotel_id")
    private Hotel hotel;

    @ManyToOne
    @JoinColumn(name = "department_id")
    private Department department;

    private String position;

    private LocalDate joiningDate;

    private LocalDate contractEndDate;

    private String employmentType; // FULL_TIME, PART_TIME, CONTRACT, INTERN

    private String employmentStatus; // ACTIVE, ON_LEAVE, TERMINATED, RESIGNED

    // Salary details
    private Double basicSalary;

    private Double houseRent;

    private Double medicalAllowance;

    private Double conveyanceAllowance;

    private Double otherAllowances;

    private Double totalSalary;

    // Personal details
    private String firstName;

    private String lastName;

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

    // Identification
    private String nidNumber;

    private String passportNumber;

    private String drivingLicense;

    // Bank details
    private String bankName;

    private String bankAccountNo;

    private String bankBranch;

    private String routingNo;

    private String panNumber;

    private String pfNumber; // Provident Fund Number

    private String uanNumber; // Universal Account Number

    // Other
    private String qualification;

    private String experience;

    private String skills;

    private String profileImageUrl;

    private String shift; // MORNING, EVENING, NIGHT

    private Long shiftId;

    private String reportingTo;

    private Long reportingManagerId;

    private String bloodGroup;

    private String religion;

    private String remarks;

    private Boolean isActive = true;

}