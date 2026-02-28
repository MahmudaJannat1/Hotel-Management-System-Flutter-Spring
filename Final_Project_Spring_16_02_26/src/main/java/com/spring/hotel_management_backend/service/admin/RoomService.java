package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateRoomRequest;
import com.spring.hotel_management_backend.model.dto.request.admin.UpdateRoomStatusRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.RoomResponse;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.List;

public interface RoomService {
    RoomResponse createRoom(CreateRoomRequest request);
    List<RoomResponse> getAllRooms();
    RoomResponse getRoomById(Long id);
    List<RoomResponse> getRoomsByHotel(Long hotelId);
    List<RoomResponse> getRoomsByStatus(String status);
    List<RoomResponse> getAvailableRooms(Long hotelId);
    RoomResponse updateRoomStatus(Long id, UpdateRoomStatusRequest request);
    RoomResponse updateRoomRate(Long id, BigDecimal newRate);
    RoomResponse updateRoom(Long id, CreateRoomRequest request);
    void deleteRoom(Long id);
    RoomResponse updateRoomImage(Long id, String imageUrl);
    RoomResponse createRoomWithImage(CreateRoomRequest request, MultipartFile imageFile);
    RoomResponse updateRoomWithImage(Long id, CreateRoomRequest request, MultipartFile imageFile);
}