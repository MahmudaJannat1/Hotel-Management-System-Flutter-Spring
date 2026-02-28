package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Department;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DepartmentRepository extends JpaRepository<Department, Long> {

    Optional<Department> findByNameAndHotelId(String name, Long hotelId);

    List<Department> findByHotelId(Long hotelId);

    List<Department> findByIsActiveTrue();

    List<Department> findByIsActiveTrueAndHotelId(Long hotelId);

    boolean existsByNameAndHotelId(String name, Long hotelId);
}