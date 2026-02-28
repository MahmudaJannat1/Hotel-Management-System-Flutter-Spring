package com.spring.hotel_management_backend.model.dto.request.admin.hr;

import lombok.Data;

@Data
public class DepartmentRequest {
    private String name;
    private String description;
    private String headOfDepartment;
    private Long headEmployeeId;
    private String location;
    private String contactNumber;
    private String email;
    private Long hotelId;
}