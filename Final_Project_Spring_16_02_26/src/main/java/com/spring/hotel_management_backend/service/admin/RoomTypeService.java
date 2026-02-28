package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateRoomTypeRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.RoomTypeResponse;

import java.util.List;

public interface RoomTypeService {
    RoomTypeResponse createRoomType(CreateRoomTypeRequest request);
    List<RoomTypeResponse> getAllRoomTypes();
    RoomTypeResponse getRoomTypeById(Long id);
    List<RoomTypeResponse> getRoomTypesByHotel(Long hotelId);
    RoomTypeResponse updateRoomType(Long id, CreateRoomTypeRequest request);
    void deleteRoomType(Long id);
}