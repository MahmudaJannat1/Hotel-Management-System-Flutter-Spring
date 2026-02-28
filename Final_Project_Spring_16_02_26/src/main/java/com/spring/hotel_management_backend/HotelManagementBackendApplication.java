package com.spring.hotel_management_backend;

import com.spring.hotel_management_backend.model.entity.User;
import com.spring.hotel_management_backend.model.enums.RoleType;
import com.spring.hotel_management_backend.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
public class HotelManagementBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(HotelManagementBackendApplication.class, args);
    }

    @Bean
    public CommandLineRunner initData(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        return args -> {
            // Check if admin exists
            if (userRepository.findByUsername("admin").isEmpty()) {
                User admin = new User();
                admin.setUsername("admin");
                admin.setEmail("admin@hotel.com");
                admin.setPassword(passwordEncoder.encode("admin123"));
                admin.setRole(RoleType.ADMIN);
                admin.setIsActive(true);
                userRepository.save(admin);
                System.out.println("Admin user created successfully!");
            }
        };
    }
}