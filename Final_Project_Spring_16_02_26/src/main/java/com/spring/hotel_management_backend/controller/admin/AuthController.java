package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.LoginRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.LoginResponse;
import com.spring.hotel_management_backend.service.admin.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout() {
        // Client side token deletion handled
        return ResponseEntity.ok().build();
    }
}