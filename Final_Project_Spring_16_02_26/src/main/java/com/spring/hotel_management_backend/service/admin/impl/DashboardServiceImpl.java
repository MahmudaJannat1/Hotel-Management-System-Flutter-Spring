package com.spring.hotel_management_backend.service.admin.impl;

import com.spring.hotel_management_backend.model.dto.response.admin.*;
import com.spring.hotel_management_backend.model.entity.*;
import com.spring.hotel_management_backend.model.enums.BookingStatus;
import com.spring.hotel_management_backend.repository.*;
import com.spring.hotel_management_backend.service.admin.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardServiceImpl implements DashboardService {

    private final BookingRepository bookingRepository;
    private final RoomRepository roomRepository;
    private final GuestRepository guestRepository;
    private final EmployeeRepository employeeRepository;
    private final InventoryRepository inventoryRepository;
    private final UserRepository userRepository;
    private final HotelRepository hotelRepository;

    @Override
    public DashboardSummaryResponse getDashboardSummary(Long hotelId) {
        LocalDate today = LocalDate.now();
        LocalDate weekAgo = today.minusDays(7);
        LocalDate monthAgo = today.minusMonths(1);

        // Revenue calculations
        Double todayRevenue = calculateRevenue(hotelId, today, today);
        Double weekRevenue = calculateRevenue(hotelId, weekAgo, today);
        Double monthRevenue = calculateRevenue(hotelId, monthAgo, today);
        Double yearRevenue = calculateRevenue(hotelId, today.minusYears(1), today);

        // Previous period for growth
        Double prevWeekRevenue = calculateRevenue(hotelId, weekAgo.minusDays(7), weekAgo);
        Double revenueGrowth = prevWeekRevenue > 0 ?
                ((weekRevenue - prevWeekRevenue) / prevWeekRevenue) * 100 : 0;

        // Room statistics
        List<Room> rooms = hotelId != null ?
                roomRepository.findByHotel(hotelRepository.findById(hotelId).orElse(null)) :
                roomRepository.findAll();

        Integer totalRooms = rooms.size();
        Integer occupiedRooms = (int) rooms.stream().filter(r -> "OCCUPIED".equals(r.getStatus())).count();
        Integer availableRooms = (int) rooms.stream().filter(r -> "AVAILABLE".equals(r.getStatus())).count();
        Integer maintenanceRooms = (int) rooms.stream().filter(r -> "MAINTENANCE".equals(r.getStatus())).count();

        Double occupancyRate = totalRooms > 0 ? (occupiedRooms * 100.0 / totalRooms) : 0;

        // Previous occupancy for growth
        Double prevOccupancyRate = calculateOccupancyRate(hotelId, weekAgo.minusDays(7), weekAgo);
        Double occupancyGrowth = prevOccupancyRate > 0 ?
                ((occupancyRate - prevOccupancyRate) / prevOccupancyRate) * 100 : 0;

        // Booking statistics
        Integer todayCheckIns = getTodaysCheckIns(hotelId, today);
        Integer todayCheckOuts = getTodaysCheckOuts(hotelId, today);
        Integer totalBookings = getTotalBookings(hotelId);
        Integer pendingBookings = getBookingsByStatus(hotelId, BookingStatus.PENDING);
        Integer cancelledBookings = getBookingsByStatus(hotelId, BookingStatus.CANCELLED);

        // Guest statistics
        Integer totalGuests = getTotalGuests(hotelId);
        Integer newGuestsToday = getNewGuestsCount(hotelId, today);
        Integer repeatGuests = getRepeatGuestsCount(hotelId);

        // Staff statistics
        Integer totalStaff = getTotalStaff(hotelId);
        Integer staffPresent = getStaffPresent(hotelId, today);
        Integer staffOnLeave = getStaffOnLeave(hotelId, today);
        Integer staffAbsent = totalStaff - staffPresent - staffOnLeave;

        // Alerts
        Integer lowStockAlerts = getLowStockAlertsCount(hotelId);
        Integer pendingTasks = getPendingTasksCount(hotelId);
        Integer maintenanceRequests = getMaintenanceRequestsCount(hotelId);

        return DashboardSummaryResponse.builder()
                .todayRevenue(todayRevenue)
                .weekRevenue(weekRevenue)
                .monthRevenue(monthRevenue)
                .yearRevenue(yearRevenue)
                .revenueGrowth(revenueGrowth)
                .totalRooms(totalRooms)
                .occupiedRooms(occupiedRooms)
                .availableRooms(availableRooms)
                .maintenanceRooms(maintenanceRooms)
                .occupancyRate(occupancyRate)
                .occupancyGrowth(occupancyGrowth)
                .todayCheckIns(todayCheckIns)
                .todayCheckOuts(todayCheckOuts)
                .totalBookings(totalBookings)
                .pendingBookings(pendingBookings)
                .cancelledBookings(cancelledBookings)
                .totalGuests(totalGuests)
                .newGuestsToday(newGuestsToday)
                .repeatGuests(repeatGuests)
                .totalStaff(totalStaff)
                .staffPresent(staffPresent)
                .staffOnLeave(staffOnLeave)
                .staffAbsent(staffAbsent)
                .lowStockAlerts(lowStockAlerts)
                .pendingTasks(pendingTasks)
                .maintenanceRequests(maintenanceRequests)
                .build();
    }

    @Override
    public RevenueChartResponse getRevenueChart(Long hotelId, String period, LocalDate startDate, LocalDate endDate) {
        List<String> labels = new ArrayList<>();
        List<Double> revenueData = new ArrayList<>();

        LocalDate currentDate = startDate;
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd MMM");

        while (!currentDate.isAfter(endDate)) {
            labels.add(currentDate.format(formatter));

            Double dailyRevenue = calculateRevenue(hotelId, currentDate, currentDate);
            revenueData.add(dailyRevenue != null ? dailyRevenue : 0.0);

            currentDate = currentDate.plusDays(1);
        }

        RevenueChartResponse.Dataset dataset = RevenueChartResponse.Dataset.builder()
                .label("Revenue")
                .data(revenueData)
                .borderColor("#4CAF50")
                .backgroundColor("rgba(76, 175, 80, 0.1)")
                .build();

        return RevenueChartResponse.builder()
                .chartType("LINE")
                .labels(labels)
                .datasets(Collections.singletonList(dataset))
                .totalRevenue(revenueData.stream().mapToDouble(Double::doubleValue).sum())
                .averageDailyRevenue(revenueData.stream().mapToDouble(Double::doubleValue).average().orElse(0))
                .highestRevenue(revenueData.stream().mapToDouble(Double::doubleValue).max().orElse(0))
                .highestRevenueDay(labels.get(revenueData.indexOf(Collections.max(revenueData))))
                .lowestRevenue(revenueData.stream().mapToDouble(Double::doubleValue).min().orElse(0))
                .lowestRevenueDay(labels.get(revenueData.indexOf(Collections.min(revenueData))))
                .build();
    }

    @Override
    public RevenueChartResponse getRevenueByRoomType(Long hotelId, LocalDate startDate, LocalDate endDate) {
        // Implement room type wise revenue
        return RevenueChartResponse.builder()
                .chartType("PIE")
                .labels(Arrays.asList("Deluxe", "Suite", "Standard", "Presidential"))
                .datasets(Collections.singletonList(
                        RevenueChartResponse.Dataset.builder()
                                .data(Arrays.asList(50000.0, 35000.0, 25000.0, 15000.0))
                                .build()
                ))
                .build();
    }

    @Override
    public RevenueChartResponse getRevenueByPaymentMethod(Long hotelId, LocalDate startDate, LocalDate endDate) {
        // Implement payment method wise revenue
        return RevenueChartResponse.builder()
                .chartType("PIE")
                .labels(Arrays.asList("Cash", "Card", "Online"))
                .datasets(Collections.singletonList(
                        RevenueChartResponse.Dataset.builder()
                                .data(Arrays.asList(45000.0, 55000.0, 25000.0))
                                .build()
                ))
                .build();
    }

    @Override
    public OccupancyChartResponse getOccupancyChart(Long hotelId, String period, LocalDate startDate, LocalDate endDate) {
        List<String> dates = new ArrayList<>();
        List<Integer> occupied = new ArrayList<>();
        List<Integer> available = new ArrayList<>();
        List<Double> rates = new ArrayList<>();

        LocalDate currentDate = startDate;
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd MMM");

        while (!currentDate.isAfter(endDate)) {
            dates.add(currentDate.format(formatter));

            int occupiedCount = getOccupiedRoomsCount(hotelId, currentDate);
            int totalRooms = getTotalRoomsCount(hotelId);
            double rate = totalRooms > 0 ? (occupiedCount * 100.0 / totalRooms) : 0;

            occupied.add(occupiedCount);
            available.add(totalRooms - occupiedCount);
            rates.add(rate);

            currentDate = currentDate.plusDays(1);
        }

        return OccupancyChartResponse.builder()
                .chartType("LINE")
                .dates(dates)
                .occupiedRooms(occupied)
                .availableRooms(available)
                .occupancyRates(rates)
                .averageOccupancy(rates.stream().mapToDouble(Double::doubleValue).average().orElse(0))
                .build();
    }

    @Override
    public OccupancyChartResponse getOccupancyByRoomType(Long hotelId) {
        Map<String, Integer> roomTypeOccupancy = new HashMap<>();
        roomTypeOccupancy.put("Deluxe", 12);
        roomTypeOccupancy.put("Suite", 8);
        roomTypeOccupancy.put("Standard", 20);
        roomTypeOccupancy.put("Presidential", 2);

        return OccupancyChartResponse.builder()
                .chartType("PIE")
                .labels(new ArrayList<>(roomTypeOccupancy.keySet()))
                .data(new ArrayList<>(roomTypeOccupancy.values()))
                .colors(Arrays.asList("#FF6384", "#36A2EB", "#FFCE56", "#4BC0C0"))
                .roomTypeOccupancy(roomTypeOccupancy)
                .build();
    }

    @Override
    public OccupancyChartResponse getDailyOccupancy(Long hotelId, LocalDate date) {
        // Implement daily occupancy
        return OccupancyChartResponse.builder()
                .chartType("BAR")
                .labels(Arrays.asList("12 AM - 6 AM", "6 AM - 12 PM", "12 PM - 6 PM", "6 PM - 12 AM"))
                .data(Arrays.asList(15, 25, 30, 20))
                .build();
    }

    @Override
    public List<RecentActivityResponse> getRecentActivities(Long hotelId, Integer limit) {
        List<RecentActivityResponse> activities = new ArrayList<>();

        // Add recent bookings
        activities.addAll(getRecentBookings(hotelId, limit/2));

        // Add recent check-ins
        activities.addAll(getRecentCheckIns(hotelId, limit/4));

        // Add recent check-outs
        activities.addAll(getRecentCheckOuts(hotelId, limit/4));

        // Sort by timestamp descending
        activities.sort((a, b) -> b.getTimestamp().compareTo(a.getTimestamp()));

        // Limit the results
        return activities.stream().limit(limit).collect(Collectors.toList());
    }

    @Override
    public List<RecentActivityResponse> getRecentBookings(Long hotelId, Integer limit) {
        // This would come from repository
        List<RecentActivityResponse> bookings = new ArrayList<>();

        bookings.add(RecentActivityResponse.builder()
                .id(1L)
                .activityType("BOOKING")
                .description("New booking - Deluxe Room")
                .status("CONFIRMED")
                .userName("Rahim")
                .userRole("FRONT_DESK")
                .guestName("John Doe")
                .roomNumber("101")
                .amount(5000.0)
                .timestamp(LocalDateTime.now().minusHours(2))
                .icon("📅")
                .color("blue")
                .build());

        bookings.add(RecentActivityResponse.builder()
                .id(2L)
                .activityType("BOOKING")
                .description("Suite room booked")
                .status("PENDING")
                .userName("Karim")
                .userRole("FRONT_DESK")
                .guestName("Jane Smith")
                .roomNumber("201")
                .amount(8000.0)
                .timestamp(LocalDateTime.now().minusHours(5))
                .icon("📅")
                .color("orange")
                .build());

        return bookings;
    }

    @Override
    public List<RecentActivityResponse> getRecentCheckIns(Long hotelId, Integer limit) {
        List<RecentActivityResponse> checkIns = new ArrayList<>();

        checkIns.add(RecentActivityResponse.builder()
                .id(3L)
                .activityType("CHECK_IN")
                .description("Guest checked in")
                .status("COMPLETED")
                .userName("Farhana")
                .userRole("FRONT_DESK")
                .guestName("Robert Johnson")
                .roomNumber("305")
                .timestamp(LocalDateTime.now().minusHours(1))
                .icon("🚪")
                .color("green")
                .build());

        return checkIns;
    }

    @Override
    public List<RecentActivityResponse> getRecentCheckOuts(Long hotelId, Integer limit) {
        List<RecentActivityResponse> checkOuts = new ArrayList<>();

        checkOuts.add(RecentActivityResponse.builder()
                .id(4L)
                .activityType("CHECK_OUT")
                .description("Guest checked out")
                .status("COMPLETED")
                .userName("Shahin")
                .userRole("FRONT_DESK")
                .guestName("Maria Garcia")
                .roomNumber("402")
                .amount(12000.0)
                .timestamp(LocalDateTime.now().minusHours(3))
                .icon("🚪")
                .color("purple")
                .build());

        return checkOuts;
    }

    @Override
    public List<AlertResponse> getAlerts(Long hotelId) {
        List<AlertResponse> alerts = new ArrayList<>();
        alerts.addAll(getLowStockAlerts(hotelId));
        alerts.addAll(getMaintenanceAlerts(hotelId));
        return alerts;
    }

    @Override
    public List<AlertResponse> getLowStockAlerts(Long hotelId) {
        List<AlertResponse> alerts = new ArrayList<>();

        alerts.add(AlertResponse.builder()
                .id(1L)
                .alertType("LOW_STOCK")
                .severity("HIGH")
                .title("Low Stock Alert")
                .description("Mineral water running low (only 5 bottles left)")
                .action("Reorder Now")
                .actionUrl("/inventory/reorder/1")
                .isRead(false)
                .createdAt(LocalDateTime.now().minusHours(1).toString())
                .build());

        alerts.add(AlertResponse.builder()
                .id(2L)
                .alertType("LOW_STOCK")
                .severity("MEDIUM")
                .title("Inventory Alert")
                .description("Toiletries stock below reorder level")
                .action("View Inventory")
                .actionUrl("/inventory")
                .isRead(false)
                .createdAt(LocalDateTime.now().minusHours(3).toString())
                .build());

        return alerts;
    }

    @Override
    public List<AlertResponse> getMaintenanceAlerts(Long hotelId) {
        List<AlertResponse> alerts = new ArrayList<>();

        alerts.add(AlertResponse.builder()
                .id(3L)
                .alertType("MAINTENANCE")
                .severity("HIGH")
                .title("Maintenance Required")
                .description("AC not working in Room 203")
                .action("Assign Technician")
                .actionUrl("/maintenance/assign/3")
                .isRead(false)
                .createdAt(LocalDateTime.now().minusHours(2).toString())
                .build());

        return alerts;
    }

    @Override
    public Map<String, Double> getRevenueTrend(Long hotelId, Integer days) {
        Map<String, Double> trend = new LinkedHashMap<>();
        LocalDate today = LocalDate.now();

        for (int i = days-1; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            String key = date.format(DateTimeFormatter.ofPattern("dd MMM"));
            Double revenue = calculateRevenue(hotelId, date, date);
            trend.put(key, revenue != null ? revenue : 0.0);
        }

        return trend;
    }

    @Override
    public Map<String, Integer> getBookingTrend(Long hotelId, Integer days) {
        Map<String, Integer> trend = new LinkedHashMap<>();
        LocalDate today = LocalDate.now();

        for (int i = days-1; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            String key = date.format(DateTimeFormatter.ofPattern("dd MMM"));
            Integer count = getBookingsCountByDate(hotelId, date);
            trend.put(key, count != null ? count : 0);
        }

        return trend;
    }

    @Override
    public Map<String, Double> getOccupancyTrend(Long hotelId, Integer days) {
        Map<String, Double> trend = new LinkedHashMap<>();
        LocalDate today = LocalDate.now();
        int totalRooms = getTotalRoomsCount(hotelId);

        for (int i = days-1; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            String key = date.format(DateTimeFormatter.ofPattern("dd MMM"));
            int occupied = getOccupiedRoomsCount(hotelId, date);
            double rate = totalRooms > 0 ? (occupied * 100.0 / totalRooms) : 0;
            trend.put(key, rate);
        }

        return trend;
    }

    // Private helper methods for calculations

    private Double calculateRevenue(Long hotelId, LocalDate startDate, LocalDate endDate) {
        // This would calculate from booking repository
        // For now returning sample data
        return 45000.0 + (Math.random() * 10000);
    }

    private Double calculateOccupancyRate(Long hotelId, LocalDate startDate, LocalDate endDate) {
        return 65.0 + (Math.random() * 20);
    }

    private Integer getTodaysCheckIns(Long hotelId, LocalDate date) {
        return 8 + (int)(Math.random() * 5);
    }

    private Integer getTodaysCheckOuts(Long hotelId, LocalDate date) {
        return 6 + (int)(Math.random() * 4);
    }

    private Integer getTotalBookings(Long hotelId) {
        return 150;
    }

    private Integer getBookingsByStatus(Long hotelId, BookingStatus status) {
        return 12;
    }

    private Integer getTotalGuests(Long hotelId) {
        return 450;
    }

    private Integer getNewGuestsCount(Long hotelId, LocalDate date) {
        return 8;
    }

    private Integer getRepeatGuestsCount(Long hotelId) {
        return 120;
    }

    private Integer getTotalStaff(Long hotelId) {
        return 25;
    }

    private Integer getStaffPresent(Long hotelId, LocalDate date) {
        return 18;
    }

    private Integer getStaffOnLeave(Long hotelId, LocalDate date) {
        return 3;
    }

    private Integer getLowStockAlertsCount(Long hotelId) {
        return 5;
    }

    private Integer getPendingTasksCount(Long hotelId) {
        return 12;
    }

    private Integer getMaintenanceRequestsCount(Long hotelId) {
        return 3;
    }

    private Integer getTotalRoomsCount(Long hotelId) {
        return 50;
    }

    private Integer getOccupiedRoomsCount(Long hotelId, LocalDate date) {
        return 35 + (int)(Math.random() * 10);
    }

    private Integer getBookingsCountByDate(Long hotelId, LocalDate date) {
        return 10 + (int)(Math.random() * 8);
    }
}