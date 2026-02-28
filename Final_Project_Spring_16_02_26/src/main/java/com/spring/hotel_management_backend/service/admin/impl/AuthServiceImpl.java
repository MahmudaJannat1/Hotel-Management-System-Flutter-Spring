package com.spring.hotel_management_backend.service.admin.impl;

import com.spring.hotel_management_backend.model.dto.request.admin.LoginRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.LoginResponse;
import com.spring.hotel_management_backend.model.entity.User;
import com.spring.hotel_management_backend.repository.UserRepository;
import com.spring.hotel_management_backend.security.JwtTokenProvider;
import com.spring.hotel_management_backend.service.admin.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;

    @Override
    public LoginResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getUsername(),
                        request.getPassword()
                )
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);

        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        String jwt = jwtTokenProvider.generateToken(userDetails);

        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        return LoginResponse.fromUser(user, jwt);
    }
}