package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.CreateBookingRequest;
import com.spring.hotel_management_backend.model.dto.request.admin.UpdateBookingStatusRequest;
import com.spring.hotel_management_backend.model.dto.response.admin.BookingResponse;

import java.time.LocalDate;
import java.util.List;

public interface BookingService {
    BookingResponse createBooking(CreateBookingRequest request);
    List<BookingResponse> getAllBookings();
    BookingResponse getBookingById(Long id);
    BookingResponse getBookingByNumber(String bookingNumber);
    List<BookingResponse> getBookingsByGuest(Long guestId);
    List<BookingResponse> getBookingsByRoom(Long roomId);
    List<BookingResponse> getBookingsByHotel(Long hotelId);
    List<BookingResponse> getBookingsByStatus(String status);
    List<BookingResponse> getTodaysCheckIns();
    List<BookingResponse> getTodaysCheckOuts();
    List<BookingResponse> getDateRangeBookings(LocalDate startDate, LocalDate endDate);
    BookingResponse checkIn(Long id);
    BookingResponse checkOut(Long id, UpdateBookingStatusRequest request);
    BookingResponse cancelBooking(Long id);
    BookingResponse updateBooking(Long id, CreateBookingRequest request);
    void deleteBooking(Long id);
    boolean isRoomAvailable(Long roomId, LocalDate checkIn, LocalDate checkOut);
}