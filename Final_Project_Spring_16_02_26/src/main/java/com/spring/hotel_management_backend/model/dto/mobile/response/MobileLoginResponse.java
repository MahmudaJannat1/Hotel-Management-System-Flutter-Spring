package com.spring.hotel_management_backend.model.dto.mobile.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MobileLoginResponse {
    private String token;
    private String type;
    private Long userId;
    private String username;
    private String email;
    private String role;
    private String firstName;
    private String lastName;
    private Long hotelId;
    private String hotelName;
    private Long lastSyncTime;
}