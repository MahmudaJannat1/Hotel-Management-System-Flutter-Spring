package com.spring.hotel_management_backend.service.admin.impl;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateRoomTypeRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.RoomTypeResponse;
import com.spring.hotel_management_backend.model.entity.Hotel;
import com.spring.hotel_management_backend.model.entity.RoomType;
import com.spring.hotel_management_backend.repository.HotelRepository;
import com.spring.hotel_management_backend.repository.RoomTypeRepository;
import com.spring.hotel_management_backend.service.admin.RoomTypeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoomTypeServiceImpl implements RoomTypeService {

    private final RoomTypeRepository roomTypeRepository;
    private final HotelRepository hotelRepository;

    @Override
    public RoomTypeResponse createRoomType(CreateRoomTypeRequest request) {
        // Check if room type exists for this hotel
        if (roomTypeRepository.existsByNameAndHotelId(request.getName(), request.getHotelId())) {
            throw new RuntimeException("Room type already exists with name: " + request.getName());
        }

        Hotel hotel = hotelRepository.findById(request.getHotelId())
                .orElseThrow(() -> new RuntimeException("Hotel not found with id: " + request.getHotelId()));

        RoomType roomType = new RoomType();
        roomType.setName(request.getName());
        roomType.setDescription(request.getDescription());
        roomType.setBasePrice(request.getBasePrice());
        roomType.setMaxOccupancy(request.getMaxOccupancy());
        roomType.setAmenities(request.getAmenities());
        roomType.setImages(request.getImages());
        roomType.setHotel(hotel);
        roomType.setIsActive(true);

        RoomType savedRoomType = roomTypeRepository.save(roomType);
        return mapToResponse(savedRoomType);
    }

    @Override
    public List<RoomTypeResponse> getAllRoomTypes() {
        return roomTypeRepository.findAll()
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public RoomTypeResponse getRoomTypeById(Long id) {
        RoomType roomType = roomTypeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Room type not found with id: " + id));
        return mapToResponse(roomType);
    }

    @Override
    public List<RoomTypeResponse> getRoomTypesByHotel(Long hotelId) {
        return roomTypeRepository.findByHotelId(hotelId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public RoomTypeResponse updateRoomType(Long id, CreateRoomTypeRequest request) {
        RoomType roomType = roomTypeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Room type not found with id: " + id));

        roomType.setName(request.getName());
        roomType.setDescription(request.getDescription());
        roomType.setBasePrice(request.getBasePrice());
        roomType.setMaxOccupancy(request.getMaxOccupancy());
        roomType.setAmenities(request.getAmenities());
        roomType.setImages(request.getImages());

        RoomType updatedRoomType = roomTypeRepository.save(roomType);
        return mapToResponse(updatedRoomType);
    }

    @Override
    public void deleteRoomType(Long id) {
        if (!roomTypeRepository.existsById(id)) {
            throw new RuntimeException("Room type not found with id: " + id);
        }
        roomTypeRepository.deleteById(id);
    }

    private RoomTypeResponse mapToResponse(RoomType roomType) {
        return RoomTypeResponse.builder()
                .id(roomType.getId())
                .name(roomType.getName())
                .description(roomType.getDescription())
                .basePrice(roomType.getBasePrice())
                .maxOccupancy(roomType.getMaxOccupancy())
                .amenities(roomType.getAmenities())
                .images(roomType.getImages())
                .hotelId(roomType.getHotel() != null ? roomType.getHotel().getId() : null)
                .hotelName(roomType.getHotel() != null ? roomType.getHotel().getName() : null)
                .createdAt(roomType.getCreatedAt())
                .updatedAt(roomType.getUpdatedAt())
                .build();
    }
}