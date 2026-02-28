package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.User;
import com.spring.hotel_management_backend.model.enums.RoleType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    List<User> findByRole(RoleType role);
    Boolean existsByUsername(String username);
    Boolean existsByEmail(String email);
}