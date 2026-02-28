package com.spring.hotel_management_backend.model.dto.request.admin.hr;

import lombok.Data;
import java.time.LocalTime;

@Data
public class CreateShiftRequest {
    private String name;
    private LocalTime startTime;
    private LocalTime endTime;
    private String description;
    private Double overtimeRate;
    private Long hotelId;
}