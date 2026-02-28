package com.spring.hotel_management_backend.service.admin.impl;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateHotelRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.HotelResponse;
import com.spring.hotel_management_backend.model.entity.Hotel;
import com.spring.hotel_management_backend.repository.HotelRepository;
import com.spring.hotel_management_backend.service.admin.HotelService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class HotelServiceImpl implements HotelService {

    private final HotelRepository hotelRepository;

    @Override
    public HotelResponse createHotel(CreateHotelRequest request) {
        Hotel hotel = new Hotel();
        hotel.setName(request.getName());
        hotel.setAddress(request.getAddress());
        hotel.setCity(request.getCity());
        hotel.setCountry(request.getCountry());
        hotel.setPhone(request.getPhone());
        hotel.setEmail(request.getEmail());
        hotel.setWebsite(request.getWebsite());
        hotel.setStarRating(request.getStarRating());
        hotel.setDescription(request.getDescription());
        hotel.setLogoUrl(request.getLogoUrl());
        hotel.setCheckInTime(request.getCheckInTime());
        hotel.setCheckOutTime(request.getCheckOutTime());

        Hotel savedHotel = hotelRepository.save(hotel);
        return mapToResponse(savedHotel);
    }

    @Override
    public List<HotelResponse> getAllHotels() {
        return hotelRepository.findAll()
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public HotelResponse getHotelById(Long id) {
        Hotel hotel = hotelRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Hotel not found with id: " + id));
        return mapToResponse(hotel);
    }

    @Override
    public HotelResponse updateHotel(Long id, CreateHotelRequest request) {
        Hotel hotel = hotelRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Hotel not found with id: " + id));

        hotel.setName(request.getName());
        hotel.setAddress(request.getAddress());
        hotel.setCity(request.getCity());
        hotel.setCountry(request.getCountry());
        hotel.setPhone(request.getPhone());
        hotel.setEmail(request.getEmail());
        hotel.setWebsite(request.getWebsite());
        hotel.setStarRating(request.getStarRating());
        hotel.setDescription(request.getDescription());
        hotel.setLogoUrl(request.getLogoUrl());
        hotel.setCheckInTime(request.getCheckInTime());
        hotel.setCheckOutTime(request.getCheckOutTime());

        Hotel updatedHotel = hotelRepository.save(hotel);
        return mapToResponse(updatedHotel);
    }

    @Override
    public void deleteHotel(Long id) {
        if (!hotelRepository.existsById(id)) {
            throw new RuntimeException("Hotel not found with id: " + id);
        }
        hotelRepository.deleteById(id);
    }

    private HotelResponse mapToResponse(Hotel hotel) {
        return HotelResponse.builder()
                .id(hotel.getId())
                .name(hotel.getName())
                .address(hotel.getAddress())
                .city(hotel.getCity())
                .country(hotel.getCountry())
                .phone(hotel.getPhone())
                .email(hotel.getEmail())
                .website(hotel.getWebsite())
                .starRating(hotel.getStarRating())
                .description(hotel.getDescription())
                .logoUrl(hotel.getLogoUrl())
                .checkInTime(hotel.getCheckInTime())
                .checkOutTime(hotel.getCheckOutTime())
                .createdAt(hotel.getCreatedAt())
                .updatedAt(hotel.getUpdatedAt())
                .build();
    }
}