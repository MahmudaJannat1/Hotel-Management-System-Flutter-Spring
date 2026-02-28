package com.spring.hotel_management_backend.service.admin.impl;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateBookingRequest;
import com.spring.hotel_management_backend.model.dto.request.admin.UpdateBookingStatusRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.BookingResponse;
import com.spring.hotel_management_backend.model.entity.Booking;
import com.spring.hotel_management_backend.model.entity.Guest;
import com.spring.hotel_management_backend.model.entity.Room;
import com.spring.hotel_management_backend.model.entity.User;
import com.spring.hotel_management_backend.model.enums.BookingStatus;
import com.spring.hotel_management_backend.repository.BookingRepository;
import com.spring.hotel_management_backend.repository.GuestRepository;
import com.spring.hotel_management_backend.repository.RoomRepository;
import com.spring.hotel_management_backend.repository.UserRepository;
import com.spring.hotel_management_backend.service.admin.BookingService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BookingServiceImpl implements BookingService {

    private final BookingRepository bookingRepository;
    private final GuestRepository guestRepository;
    private final RoomRepository roomRepository;
    private final UserRepository userRepository;

    private String generateBookingNumber() {
        return "BK" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 4).toUpperCase();
    }

    private User getCurrentUser() {
        UserDetails userDetails = (UserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return userRepository.findByUsername(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Override
    @Transactional
    public BookingResponse createBooking(CreateBookingRequest request) {
        // Validate guest
        Guest guest = guestRepository.findById(request.getGuestId())
                .orElseThrow(() -> new RuntimeException("Guest not found with id: " + request.getGuestId()));

        // Validate room
        Room room = roomRepository.findById(request.getRoomId())
                .orElseThrow(() -> new RuntimeException("Room not found with id: " + request.getRoomId()));

        // Check room availability
        if (!isRoomAvailable(request.getRoomId(), request.getCheckInDate(), request.getCheckOutDate())) {
            throw new RuntimeException("Room is not available for selected dates");
        }

        // Calculate number of nights
        long nights = ChronoUnit.DAYS.between(request.getCheckInDate(), request.getCheckOutDate());
        if (nights <= 0) {
            throw new RuntimeException("Check-out date must be after check-in date");
        }

        // Calculate total amount
        double roomPrice = room.getBasePrice().doubleValue();
        double totalAmount = roomPrice * nights;

        // Create booking
        Booking booking = new Booking();
        booking.setBookingNumber(generateBookingNumber());
        booking.setGuest(guest);
        booking.setRoom(room);
        booking.setCheckInDate(request.getCheckInDate());
        booking.setCheckOutDate(request.getCheckOutDate());
        booking.setNumberOfGuests(request.getNumberOfGuests());
        booking.setStatus(BookingStatus.CONFIRMED);
        booking.setTotalAmount(totalAmount);
        booking.setAdvancePayment(request.getAdvancePayment() != null ? request.getAdvancePayment() : 0.0);
        booking.setDueAmount(totalAmount - (request.getAdvancePayment() != null ? request.getAdvancePayment() : 0.0));
        booking.setPaymentMethod(request.getPaymentMethod());
        booking.setSpecialRequests(request.getSpecialRequests());
        booking.setCreatedBy(getCurrentUser().getUsername());

        Booking savedBooking = bookingRepository.save(booking);

        // Update room status to RESERVED
        room.setStatus("RESERVED");
        roomRepository.save(room);

        return mapToResponse(savedBooking);
    }

    @Override
    public List<BookingResponse> getAllBookings() {
        return bookingRepository.findAll()
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public BookingResponse getBookingById(Long id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found with id: " + id));
        return mapToResponse(booking);
    }

    @Override
    public BookingResponse getBookingByNumber(String bookingNumber) {
        // You may want to add this method to repository
        return bookingRepository.findAll()
                .stream()
                .filter(b -> b.getBookingNumber().equals(bookingNumber))
                .findFirst()
                .map(this::mapToResponse)
                .orElseThrow(() -> new RuntimeException("Booking not found with number: " + bookingNumber));
    }

    @Override
    public List<BookingResponse> getBookingsByGuest(Long guestId) {
        return bookingRepository.findByGuestId(guestId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<BookingResponse> getBookingsByRoom(Long roomId) {
        return bookingRepository.findByRoomId(roomId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<BookingResponse> getBookingsByHotel(Long hotelId) {
        return bookingRepository.findByHotelId(hotelId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<BookingResponse> getBookingsByStatus(String status) {
        try {
            BookingStatus bookingStatus = BookingStatus.valueOf(status.toUpperCase());
            return bookingRepository.findByStatus(bookingStatus)
                    .stream()
                    .map(this::mapToResponse)
                    .collect(Collectors.toList());
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid booking status: " + status);
        }
    }

    @Override
    public List<BookingResponse> getTodaysCheckIns() {
        return bookingRepository.findTodaysCheckIns(LocalDate.now())
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<BookingResponse> getTodaysCheckOuts() {
        return bookingRepository.findTodaysCheckOuts(LocalDate.now())
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<BookingResponse> getDateRangeBookings(LocalDate startDate, LocalDate endDate) {
        // This can be implemented with a custom query
        return bookingRepository.findAll()
                .stream()
                .filter(b -> !b.getCheckOutDate().isBefore(startDate) && !b.getCheckInDate().isAfter(endDate))
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public BookingResponse checkIn(Long id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found with id: " + id));

        if (booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new RuntimeException("Only confirmed bookings can be checked in");
        }

        booking.setStatus(BookingStatus.CHECKED_IN);

        // Update room status
        Room room = booking.getRoom();
        room.setStatus("OCCUPIED");
        roomRepository.save(room);

        Booking updatedBooking = bookingRepository.save(booking);
        return mapToResponse(updatedBooking);
    }

    @Override
    @Transactional
    public BookingResponse checkOut(Long id, UpdateBookingStatusRequest request) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found with id: " + id));

        if (booking.getStatus() != BookingStatus.CHECKED_IN) {
            throw new RuntimeException("Only checked-in bookings can be checked out");
        }

        booking.setStatus(BookingStatus.CHECKED_OUT);

        // Update room status
        Room room = booking.getRoom();
        room.setStatus("AVAILABLE");
        roomRepository.save(room);

        Booking updatedBooking = bookingRepository.save(booking);
        return mapToResponse(updatedBooking);
    }

    @Override
    @Transactional
    public BookingResponse cancelBooking(Long id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found with id: " + id));

        if (booking.getStatus() == BookingStatus.CHECKED_IN ||
                booking.getStatus() == BookingStatus.CHECKED_OUT) {
            throw new RuntimeException("Cannot cancel checked-in or checked-out bookings");
        }

        booking.setStatus(BookingStatus.CANCELLED);

        // Update room status
        Room room = booking.getRoom();
        room.setStatus("AVAILABLE");
        roomRepository.save(room);

        Booking updatedBooking = bookingRepository.save(booking);
        return mapToResponse(updatedBooking);
    }

    @Override
    @Transactional
    public BookingResponse updateBooking(Long id, CreateBookingRequest request) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found with id: " + id));

        if (booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new RuntimeException("Only confirmed bookings can be updated");
        }

        // Check if dates changed and room availability
        if (!request.getCheckInDate().equals(booking.getCheckInDate()) ||
                !request.getCheckOutDate().equals(booking.getCheckOutDate())) {

            if (!isRoomAvailable(booking.getRoom().getId(), request.getCheckInDate(), request.getCheckOutDate())) {
                throw new RuntimeException("Room is not available for selected dates");
            }
        }

        // Update guest if changed
        if (!request.getGuestId().equals(booking.getGuest().getId())) {
            Guest newGuest = guestRepository.findById(request.getGuestId())
                    .orElseThrow(() -> new RuntimeException("Guest not found"));
            booking.setGuest(newGuest);
        }

        // Update booking details
        booking.setCheckInDate(request.getCheckInDate());
        booking.setCheckOutDate(request.getCheckOutDate());
        booking.setNumberOfGuests(request.getNumberOfGuests());
        booking.setSpecialRequests(request.getSpecialRequests());
        booking.setPaymentMethod(request.getPaymentMethod());

        // Recalculate amounts
        long nights = ChronoUnit.DAYS.between(request.getCheckInDate(), request.getCheckOutDate());
        double roomPrice = booking.getRoom().getBasePrice().doubleValue();
        double totalAmount = roomPrice * nights;

        booking.setTotalAmount(totalAmount);
        booking.setAdvancePayment(request.getAdvancePayment() != null ? request.getAdvancePayment() : booking.getAdvancePayment());
        booking.setDueAmount(totalAmount - booking.getAdvancePayment());

        Booking updatedBooking = bookingRepository.save(booking);
        return mapToResponse(updatedBooking);
    }

    @Override
    @Transactional
    public void deleteBooking(Long id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found with id: " + id));

        // Make room available again
        Room room = booking.getRoom();
        room.setStatus("AVAILABLE");
        roomRepository.save(room);

        bookingRepository.deleteById(id);
    }

    @Override
    public boolean isRoomAvailable(Long roomId, LocalDate checkIn, LocalDate checkOut) {
        List<Booking> conflictingBookings = bookingRepository.findConflictingBookings(
                roomId, checkIn, checkOut);
        return conflictingBookings.isEmpty();
    }

    private BookingResponse mapToResponse(Booking booking) {
        long nights = ChronoUnit.DAYS.between(booking.getCheckInDate(), booking.getCheckOutDate());

        return BookingResponse.builder()
                .id(booking.getId())
                .bookingNumber(booking.getBookingNumber())

                // Guest info
                .guestId(booking.getGuest().getId())
                .guestName(booking.getGuest().getFirstName() + " " + booking.getGuest().getLastName())
                .guestEmail(booking.getGuest().getEmail())
                .guestPhone(booking.getGuest().getPhone())

                // Room info
                .roomId(booking.getRoom().getId())
                .roomNumber(booking.getRoom().getRoomNumber())
                .roomTypeName(booking.getRoom().getRoomType() != null ? booking.getRoom().getRoomType().getName() : null)
                .hotelId(booking.getRoom().getHotel() != null ? booking.getRoom().getHotel().getId() : null)
                .hotelName(booking.getRoom().getHotel() != null ? booking.getRoom().getHotel().getName() : null)

                // Booking details
                .checkInDate(booking.getCheckInDate())
                .checkOutDate(booking.getCheckOutDate())
                .numberOfNights((int) nights)
                .numberOfGuests(booking.getNumberOfGuests())
                .status(booking.getStatus().name())

                // Pricing
                .roomPrice(booking.getRoom().getBasePrice().doubleValue())
                .totalAmount(booking.getTotalAmount())
                .advancePayment(booking.getAdvancePayment())
                .dueAmount(booking.getDueAmount())
                .paymentMethod(booking.getPaymentMethod())

                // Other
                .specialRequests(booking.getSpecialRequests())
                .createdAt(booking.getCreatedAt())
                .updatedAt(booking.getUpdatedAt())
                .createdBy(booking.getCreatedBy())
                .build();
    }
}