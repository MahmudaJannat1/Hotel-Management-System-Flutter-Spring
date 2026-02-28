package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateUserRequest;
import com.spring.hotel_management_backend.model.dto.request.admin.UpdateUserRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.UserResponse;

import java.util.List;

public interface UserService {
    UserResponse createUser(CreateUserRequest request);
    List<UserResponse> getAllUsers();
    UserResponse getUserById(Long id);
    List<UserResponse> getUsersByRole(String role);
    UserResponse updateUser(Long id, UpdateUserRequest request);
    UserResponse toggleUserStatus(Long id);
    void deleteUser(Long id);
}