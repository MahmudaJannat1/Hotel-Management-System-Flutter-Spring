package com.spring.hotel_management_backend.service.admin.impl;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateRoomRequest;
import com.spring.hotel_management_backend.model.dto.request.admin.UpdateRoomStatusRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.RoomResponse;
import com.spring.hotel_management_backend.model.entity.Hotel;
import com.spring.hotel_management_backend.model.entity.Room;
import com.spring.hotel_management_backend.model.entity.RoomType;
import com.spring.hotel_management_backend.repository.HotelRepository;
import com.spring.hotel_management_backend.repository.RoomRepository;
import com.spring.hotel_management_backend.repository.RoomTypeRepository;
import com.spring.hotel_management_backend.service.admin.RoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoomServiceImpl implements RoomService {

    @Value("${file.upload-dir}")
    private String uploadDir;

    private final RoomRepository roomRepository;
    private final HotelRepository hotelRepository;
    private final RoomTypeRepository roomTypeRepository;

    @Override
    public RoomResponse createRoom(CreateRoomRequest request) {
        Hotel hotel = hotelRepository.findById(request.getHotelId())
                .orElseThrow(() -> new RuntimeException("Hotel not found with id: " + request.getHotelId()));

        RoomType roomType = roomTypeRepository.findById(request.getRoomTypeId())
                .orElseThrow(() -> new RuntimeException("Room type not found with id: " + request.getRoomTypeId()));

        // Check if room number exists in this hotel
        List<Room> existingRooms = roomRepository.findByHotel(hotel);
        if (existingRooms.stream().anyMatch(r -> r.getRoomNumber().equals(request.getRoomNumber()))) {
            throw new RuntimeException("Room number already exists in this hotel: " + request.getRoomNumber());
        }

        Room room = new Room();
        room.setHotel(hotel);
        room.setRoomNumber(request.getRoomNumber());
        room.setRoomType(roomType);
        room.setFloor(request.getFloor());
        room.setStatus(request.getStatus() != null ? request.getStatus() : "AVAILABLE");
        room.setBasePrice(request.getBasePrice() != null ? request.getBasePrice() : roomType.getBasePrice());
        room.setDescription(request.getDescription());
        room.setMaxOccupancy(request.getMaxOccupancy() != null ? request.getMaxOccupancy() : roomType.getMaxOccupancy());
        room.setAmenities(request.getAmenities());
        room.setImages(request.getImages());

        Room savedRoom = roomRepository.save(room);
        return mapToResponse(savedRoom);
    }

    @Override
    public List<RoomResponse> getAllRooms() {
        return roomRepository.findAll()
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public RoomResponse getRoomById(Long id) {
        Room room = roomRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Room not found with id: " + id));
        return mapToResponse(room);
    }

    @Override
    public List<RoomResponse> getRoomsByHotel(Long hotelId) {
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new RuntimeException("Hotel not found with id: " + hotelId));

        return roomRepository.findByHotel(hotel)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    // এই method টা যোগ করুন (অন্য method-গুলোর পরে)
    @Override
    @Transactional
    public RoomResponse updateRoomImage(Long id, String imageUrl) {
        Room room = roomRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Room not found with id: " + id));

        // Update image
        room.setImages(imageUrl);

        Room updatedRoom = roomRepository.save(room);
        return mapToResponse(updatedRoom);
    }

    @Override
    public List<RoomResponse> getRoomsByStatus(String status) {
        return roomRepository.findByStatus(status)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<RoomResponse> getAvailableRooms(Long hotelId) {
        Hotel hotel = hotelRepository.findById(hotelId)
                .orElseThrow(() -> new RuntimeException("Hotel not found with id: " + hotelId));

        return roomRepository.findByHotelAndStatus(hotel, "AVAILABLE")
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public RoomResponse updateRoomStatus(Long id, UpdateRoomStatusRequest request) {
        Room room = roomRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Room not found with id: " + id));

        room.setStatus(request.getStatus());
        Room updatedRoom = roomRepository.save(room);
        return mapToResponse(updatedRoom);
    }

    @Override
    public RoomResponse updateRoomRate(Long id, BigDecimal newRate) {
        Room room = roomRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Room not found with id: " + id));

        room.setBasePrice(newRate);
        Room updatedRoom = roomRepository.save(room);
        return mapToResponse(updatedRoom);
    }


    

    @Override
    public RoomResponse updateRoom(Long id, CreateRoomRequest request) {
        Room room = roomRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Room not found with id: " + id));

        if (request.getRoomNumber() != null) {
            room.setRoomNumber(request.getRoomNumber());
        }

        if (request.getFloor() != null) {
            room.setFloor(request.getFloor());
        }

        if (request.getStatus() != null) {
            room.setStatus(request.getStatus());
        }

        if (request.getBasePrice() != null) {
            room.setBasePrice(request.getBasePrice());
        }

        if (request.getDescription() != null) {
            room.setDescription(request.getDescription());
        }

        if (request.getMaxOccupancy() != null) {
            room.setMaxOccupancy(request.getMaxOccupancy());
        }

        if (request.getAmenities() != null) {
            room.setAmenities(request.getAmenities());
        }

        if (request.getImages() != null) {
            room.setImages(request.getImages());
        }

        if (request.getRoomTypeId() != null) {
            RoomType roomType = roomTypeRepository.findById(request.getRoomTypeId())
                    .orElseThrow(() -> new RuntimeException("Room type not found with id: " + request.getRoomTypeId()));
            room.setRoomType(roomType);
        }

        Room updatedRoom = roomRepository.save(room);
        return mapToResponse(updatedRoom);
    }

    @Override
    public void deleteRoom(Long id) {
        if (!roomRepository.existsById(id)) {
            throw new RuntimeException("Room not found with id: " + id);
        }
        roomRepository.deleteById(id);
    }

    private RoomResponse mapToResponse(Room room) {
        return RoomResponse.builder()
                .id(room.getId())
                .hotelId(room.getHotel() != null ? room.getHotel().getId() : null)
                .hotelName(room.getHotel() != null ? room.getHotel().getName() : null)
                .roomNumber(room.getRoomNumber())
                .roomTypeId(room.getRoomType() != null ? room.getRoomType().getId() : null)
                .roomTypeName(room.getRoomType() != null ? room.getRoomType().getName() : null)
                .floor(room.getFloor())
                .status(room.getStatus())
                .basePrice(room.getBasePrice())
                .description(room.getDescription())
                .maxOccupancy(room.getMaxOccupancy())
                .amenities(room.getAmenities())
                .images(room.getImages())
                .createdAt(room.getCreatedAt())
                .updatedAt(room.getUpdatedAt())
                .build();
    }

    @Override
    @Transactional
    public RoomResponse createRoomWithImage(CreateRoomRequest request, MultipartFile imageFile) {
        // First create room without image
        RoomResponse response = createRoom(request);

        // Then upload image
        if (imageFile != null && !imageFile.isEmpty()) {
            String imageUrl = saveImage(imageFile, response.getId());

            // Update room with image URL
            Room room = roomRepository.findById(response.getId())
                    .orElseThrow(() -> new RuntimeException("Room not found"));
            room.setImages(imageUrl);
            roomRepository.save(room);

            response = mapToResponse(room);
        }

        return response;
    }

    @Override
    @Transactional
    public RoomResponse updateRoomWithImage(Long id, CreateRoomRequest request, MultipartFile imageFile) {
        // First update room data
        RoomResponse response = updateRoom(id, request);

        // Then upload new image if provided
        if (imageFile != null && !imageFile.isEmpty()) {
            String imageUrl = saveImage(imageFile, id);

            Room room = roomRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Room not found"));
            room.setImages(imageUrl);
            roomRepository.save(room);

            response = mapToResponse(room);
        }

        return response;
    }

    private String saveImage(MultipartFile file, Long roomId) {
        try {
            // Create directory if not exists
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String filename = roomId + "_" + UUID.randomUUID().toString() + extension;

            // Save file
            Path filePath = uploadPath.resolve(filename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            // Return URL
            return "/api/admin/rooms/images/" + filename;

        } catch (IOException e) {
            throw new RuntimeException("Failed to save image: " + e.getMessage());
        }
    }

}