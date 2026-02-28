package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Shift;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ShiftRepository extends JpaRepository<Shift, Long> {

    Optional<Shift> findByNameAndHotelId(String name, Long hotelId);

    List<Shift> findByHotelId(Long hotelId);

    List<Shift> findByIsActiveTrue();

    List<Shift> findByIsActiveTrueAndHotelId(Long hotelId);
}