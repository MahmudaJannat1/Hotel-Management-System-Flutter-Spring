package com.spring.hotel_management_backend.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Configuration
@EnableTransactionManagement
@EnableJpaRepositories(basePackages = "com.spring.hotel_management_backend.repository")
public class DatabaseConfig {
    // Database configuration will be in application.properties
}