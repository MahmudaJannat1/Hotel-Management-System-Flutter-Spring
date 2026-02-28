package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.RoomType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RoomTypeRepository extends JpaRepository<RoomType, Long> {
    List<RoomType> findByHotelId(Long hotelId);
    boolean existsByNameAndHotelId(String name, Long hotelId);
}