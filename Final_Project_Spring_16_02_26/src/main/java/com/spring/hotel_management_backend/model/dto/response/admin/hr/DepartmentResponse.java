package com.spring.hotel_management_backend.model.dto.response.admin.hr;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DepartmentResponse {
    private Long id;
    private String name;
    private String description;
    private String headOfDepartment;
    private Long headEmployeeId;
    private String headEmployeeName;
    private String location;
    private String contactNumber;
    private String email;
    private Integer totalEmployees;
    private Boolean isActive;
    private Long hotelId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}