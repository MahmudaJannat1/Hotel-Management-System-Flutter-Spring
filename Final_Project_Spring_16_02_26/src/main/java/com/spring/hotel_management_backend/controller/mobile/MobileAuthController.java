package com.spring.hotel_management_backend.controller.mobile;

import com.spring.hotel_management_backend.model.dto.mobile.request.MobileLoginRequest;
import com.spring.hotel_management_backend.model.dto.mobile.response.MobileLoginResponse;
import com.spring.hotel_management_backend.service.mobile.MobileAuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/mobile/auth")
@RequiredArgsConstructor
@Tag(name = "Mobile Auth", description = "Mobile app authentication APIs")
public class MobileAuthController {

    private final MobileAuthService mobileAuthService;

    @PostMapping("/login")
    @Operation(summary = "Mobile app login")
    public ResponseEntity<MobileLoginResponse> login(@RequestBody MobileLoginRequest request) {
        return ResponseEntity.ok(mobileAuthService.login(request));
    }

    @PostMapping("/logout")
    @Operation(summary = "Mobile app logout")
    public ResponseEntity<Void> logout(@RequestParam Long userId, @RequestParam String deviceId) {
        mobileAuthService.logout(userId, deviceId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/validate")
    @Operation(summary = "Validate token")
    public ResponseEntity<Boolean> validateToken(@RequestParam String token) {
        return ResponseEntity.ok(mobileAuthService.validateToken(token));
    }
}