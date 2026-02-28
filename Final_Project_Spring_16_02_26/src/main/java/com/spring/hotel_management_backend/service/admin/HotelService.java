package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateHotelRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.HotelResponse;

import java.util.List;

public interface HotelService {
    HotelResponse createHotel(CreateHotelRequest request);
    List<HotelResponse> getAllHotels();
    HotelResponse getHotelById(Long id);
    HotelResponse updateHotel(Long id, CreateHotelRequest request);
    void deleteHotel(Long id);
}