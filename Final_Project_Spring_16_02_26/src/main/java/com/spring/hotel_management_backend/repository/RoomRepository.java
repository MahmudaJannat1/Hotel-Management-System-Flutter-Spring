package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Hotel;
import com.spring.hotel_management_backend.model.entity.Room;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RoomRepository extends JpaRepository<Room, Long> {
    List<Room> findByHotel(Hotel hotel);
    List<Room> findByStatus(String status);
    List<Room> findByHotelAndStatus(Hotel hotel, String status);
}