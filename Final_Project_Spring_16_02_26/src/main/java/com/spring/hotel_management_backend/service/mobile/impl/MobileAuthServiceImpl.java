package com.spring.hotel_management_backend.service.mobile.impl;

import com.spring.hotel_management_backend.model.dto.mobile.request.MobileLoginRequest;
import com.spring.hotel_management_backend.model.dto.mobile.response.MobileLoginResponse;
import com.spring.hotel_management_backend.model.entity.User;
import com.spring.hotel_management_backend.model.entity.DeviceInfo;
import com.spring.hotel_management_backend.repository.UserRepository;
import com.spring.hotel_management_backend.repository.DeviceInfoRepository;
import com.spring.hotel_management_backend.security.JwtTokenProvider;
import com.spring.hotel_management_backend.service.mobile.MobileAuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class MobileAuthServiceImpl implements MobileAuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;
    private final DeviceInfoRepository deviceInfoRepository;

    @Override
    public MobileLoginResponse login(MobileLoginRequest request) {
        // Authenticate user
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getUsername(),
                        request.getPassword()
                )
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);

        // Get user details
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        // 🔥 FIX: Extract UserDetails from Authentication
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();

        // Generate token with UserDetails
        String token = jwtTokenProvider.generateToken(userDetails);

        // Save device info
        DeviceInfo deviceInfo = new DeviceInfo();
        deviceInfo.setUserId(user.getId());
        deviceInfo.setDeviceId(request.getDeviceId());
        deviceInfo.setDeviceType(request.getDeviceType());
        deviceInfo.setFcmToken(request.getFcmToken());
        deviceInfo.setLastLogin(LocalDateTime.now());
        deviceInfo.setIsActive(true);
        deviceInfoRepository.save(deviceInfo);

        // Build response
        return MobileLoginResponse.builder()
                .token(token)
                .type("Bearer")
                .userId(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .role(user.getRole().name())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .hotelId(user.getHotel() != null ? user.getHotel().getId() : null)
                .hotelName(user.getHotel() != null ? user.getHotel().getName() : null)
                .lastSyncTime(System.currentTimeMillis())
                .build();
    }

    @Override
    public void logout(Long userId, String deviceId) {
        DeviceInfo deviceInfo = deviceInfoRepository.findByUserIdAndDeviceId(userId, deviceId)
                .orElseThrow(() -> new RuntimeException("Device not found"));

        deviceInfo.setIsActive(false);
        deviceInfo.setLastLogout(LocalDateTime.now());
        deviceInfoRepository.save(deviceInfo);
    }

    @Override
    public Boolean validateToken(String token) {
        try {
            return jwtTokenProvider.validateToken(token, null);
        } catch (Exception e) {
            return false;
        }
    }
}