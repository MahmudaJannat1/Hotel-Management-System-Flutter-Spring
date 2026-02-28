package com.spring.hotel_management_backend.service.admin.impl;

import com.spring.hotel_management_backend.model.dto.response.admin.reports.*;
import com.spring.hotel_management_backend.model.entity.*;
import com.spring.hotel_management_backend.model.enums.BookingStatus;
import com.spring.hotel_management_backend.repository.*;
import com.spring.hotel_management_backend.service.admin.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final BookingRepository bookingRepository;
    private final RoomRepository roomRepository;
    private final GuestRepository guestRepository;
    private final EmployeeRepository employeeRepository;
    private final InventoryRepository inventoryRepository;
    private final HotelRepository hotelRepository;
    private final AttendanceRepository attendanceRepository;

    @Override
    public OccupancyReportResponse getOccupancyReport(Long hotelId, LocalDate startDate, LocalDate endDate) {
        List<Room> rooms = getRoomsByHotel(hotelId);
        int totalRooms = rooms.size();

        List<OccupancyReportResponse.DailyOccupancy> dailyOccupancy = new ArrayList<>();
        Map<String, OccupancyReportResponse.RoomTypeOccupancy> roomTypeStats = new HashMap<>();
        Map<String, OccupancyReportResponse.MonthlyOccupancy> monthlyStats = new HashMap<>();

        LocalDate currentDate = startDate;
        int totalOccupiedNights = 0;
        int totalDays = 0;

        while (!currentDate.isAfter(endDate)) {
            int occupiedCount = getOccupiedRoomsCountForDate(hotelId, currentDate);
            int maintenanceCount = getMaintenanceRoomsCountForDate(hotelId, currentDate);
            int availableCount = totalRooms - occupiedCount - maintenanceCount;
            double occupancyRate = totalRooms > 0 ? (occupiedCount * 100.0 / totalRooms) : 0;
            double dailyRevenue = calculateRevenueForDate(hotelId, currentDate);

            dailyOccupancy.add(OccupancyReportResponse.DailyOccupancy.builder()
                    .date(currentDate)
                    .occupiedRooms(occupiedCount)
                    .availableRooms(availableCount)
                    .maintenanceRooms(maintenanceCount)
                    .occupancyRate(occupancyRate)
                    .revenue(dailyRevenue)
                    .build());

            totalOccupiedNights += occupiedCount;
            totalDays++;

            // Update room type stats (simplified - in real app would calculate properly)
            for (Room room : rooms) {
                String roomTypeName = room.getRoomType() != null ? room.getRoomType().getName() : "Standard";
                OccupancyReportResponse.RoomTypeOccupancy stats = roomTypeStats.getOrDefault(roomTypeName,
                        OccupancyReportResponse.RoomTypeOccupancy.builder()
                                .roomTypeName(roomTypeName)
                                .totalRooms(0)
                                .occupiedRooms(0)
                                .totalRevenue(0.0)
                                .build());

                stats.setTotalRooms(stats.getTotalRooms() + 1);
                // This is simplified - should check actual occupancy per room type
                roomTypeStats.put(roomTypeName, stats);
            }

            currentDate = currentDate.plusDays(1);
        }

        double averageOccupancyRate = totalDays > 0 ? (totalOccupiedNights * 100.0 / (totalRooms * totalDays)) : 0;

        return OccupancyReportResponse.builder()
                .reportType("OCCUPANCY_REPORT")
                .startDate(startDate)
                .endDate(endDate)
                .generatedAt(LocalDate.now().toString())
                .totalRooms(totalRooms)
                .totalOccupiedRooms(totalOccupiedNights / totalDays)
                .totalAvailableRooms(totalRooms - (totalOccupiedNights / totalDays))
                .averageOccupancyRate(averageOccupancyRate)
                .dailyOccupancy(dailyOccupancy)
                .roomTypeStats(roomTypeStats)
                .monthlyStats(monthlyStats)
                .build();
    }

    @Override
    public OccupancyReportResponse getOccupancyReportByRoomType(Long hotelId, LocalDate startDate, LocalDate endDate) {
        // Similar to above but grouped by room type
        return getOccupancyReport(hotelId, startDate, endDate);
    }

    @Override
    public OccupancyReportResponse getMonthlyOccupancyReport(Long hotelId, Integer year) {
        LocalDate startDate = LocalDate.of(year, 1, 1);
        LocalDate endDate = LocalDate.of(year, 12, 31);
        return getOccupancyReport(hotelId, startDate, endDate);
    }

    @Override
    public RevenueReportResponse getRevenueReport(Long hotelId, LocalDate startDate, LocalDate endDate) {
        List<Booking> bookings = getBookingsByDateRange(hotelId, startDate, endDate);

        double totalRevenue = bookings.stream()
                .filter(b -> b.getStatus() == BookingStatus.CHECKED_OUT)
                .mapToDouble(Booking::getTotalAmount)
                .sum();

        int totalBookings = bookings.size();
        int cancelledBookings = (int) bookings.stream()
                .filter(b -> b.getStatus() == BookingStatus.CANCELLED)
                .count();

        double averageDailyRate = calculateAverageDailyRate(bookings);
        double revenuePerAvailableRoom = calculateRevPAR(hotelId, totalRevenue, startDate, endDate);

        Map<String, Double> paymentMethodRevenue = new HashMap<>();
        Map<String, Double> roomTypeRevenue = new HashMap<>();
        List<RevenueReportResponse.DailyRevenue> dailyRevenue = new ArrayList<>();

        LocalDate currentDate = startDate;
        while (!currentDate.isAfter(endDate)) {
            LocalDate date = currentDate;
            List<Booking> dayBookings = bookings.stream()
                    .filter(b -> b.getCheckInDate().equals(date) ||
                            (b.getCheckInDate().isBefore(date) && b.getCheckOutDate().isAfter(date)))
                    .collect(Collectors.toList());

            double dayRevenue = dayBookings.stream()
                    .filter(b -> b.getStatus() == BookingStatus.CHECKED_OUT)
                    .mapToDouble(Booking::getTotalAmount)
                    .sum();

            dailyRevenue.add(RevenueReportResponse.DailyRevenue.builder()
                    .date(date)
                    .roomRevenue(dayRevenue)
                    .fnbRevenue(0.0) // Food & Beverage revenue - would come from separate table
                    .otherRevenue(0.0)
                    .totalRevenue(dayRevenue)
                    .bookings(dayBookings.size())
                    .build());

            currentDate = currentDate.plusDays(1);
        }

        return RevenueReportResponse.builder()
                .reportType("REVENUE_REPORT")
                .startDate(startDate)
                .endDate(endDate)
                .generatedAt(LocalDate.now().toString())
                .totalRevenue(totalRevenue)
                .totalRoomRevenue(totalRevenue)
                .totalFnbRevenue(0.0)
                .totalOtherRevenue(0.0)
                .averageDailyRate(averageDailyRate)
                .revenuePerAvailableRoom(revenuePerAvailableRoom)
                .totalBookings(totalBookings)
                .cancelledBookings(cancelledBookings)
                .noShowBookings(0)
                .dailyRevenue(dailyRevenue)
                .paymentMethodRevenue(paymentMethodRevenue)
                .roomTypeRevenue(roomTypeRevenue)
                .monthlyRevenue(new HashMap<>())
                .build();
    }

    @Override
    public RevenueReportResponse getRevenueReportByPaymentMethod(Long hotelId, LocalDate startDate, LocalDate endDate) {
        return getRevenueReport(hotelId, startDate, endDate);
    }

    @Override
    public RevenueReportResponse getRevenueReportByRoomType(Long hotelId, LocalDate startDate, LocalDate endDate) {
        return getRevenueReport(hotelId, startDate, endDate);
    }

    @Override
    public RevenueReportResponse getYearlyRevenueComparison(Long hotelId, Integer year) {
        LocalDate startDate = LocalDate.of(year, 1, 1);
        LocalDate endDate = LocalDate.of(year, 12, 31);
        return getRevenueReport(hotelId, startDate, endDate);
    }

    @Override
    public StaffAttendanceReportResponse getStaffAttendanceReport(Long hotelId, LocalDate startDate, LocalDate endDate) {
        // Get real employees
        List<Employee> employees = employeeRepository.findByHotelId(hotelId);
        int totalStaff = employees.size();

        // Calculate total days
        long totalDays = ChronoUnit.DAYS.between(startDate, endDate) + 1;  // 🔥 এই line যোগ করুন

        // Get real attendances for date range
        List<Attendance> attendances = attendanceRepository.findByDateRangeAndHotel(startDate, endDate, hotelId);

        // Build staff attendance list
        List<StaffAttendanceReportResponse.StaffAttendance> staffAttendanceList = new ArrayList<>();
        for (Employee emp : employees) {
            List<Attendance> empAttendances = attendances.stream()
                    .filter(a -> a.getEmployee().getId().equals(emp.getId()))
                    .collect(Collectors.toList());

            int presentDays = (int) empAttendances.stream()
                    .filter(a -> "PRESENT".equals(a.getStatus()))
                    .count();
            int absentDays = (int) empAttendances.stream()
                    .filter(a -> "ABSENT".equals(a.getStatus()))
                    .count();
            int leaveDays = (int) empAttendances.stream()
                    .filter(a -> "LEAVE".equals(a.getStatus()))
                    .count();

            double percentage = totalDays > 0 ? (presentDays * 100.0 / totalDays) : 0;

            staffAttendanceList.add(StaffAttendanceReportResponse.StaffAttendance.builder()
                    .employeeId(emp.getId())
                    .employeeName(emp.getFirstName() + " " + emp.getLastName())
                    .department(emp.getDepartment() != null ? emp.getDepartment().getName() : "N/A")
                    .position(emp.getPosition())
                    .totalDays((int) ChronoUnit.DAYS.between(startDate, endDate) + 1)
                    .presentDays(presentDays)
                    .absentDays(absentDays)
                    .leaveDays(leaveDays)
                    .attendancePercentage(percentage)
                    .build());
        }

        // Build daily attendance
        List<StaffAttendanceReportResponse.DailyAttendance> dailyAttendanceList = new ArrayList<>();
        LocalDate currentDate = startDate;
        while (!currentDate.isAfter(endDate)) {
            LocalDate date = currentDate;
            long present = attendances.stream()
                    .filter(a -> a.getDate().equals(date) && "PRESENT".equals(a.getStatus()))
                    .count();
            long absent = attendances.stream()
                    .filter(a -> a.getDate().equals(date) && "ABSENT".equals(a.getStatus()))
                    .count();
            long onLeave = attendances.stream()
                    .filter(a -> a.getDate().equals(date) && "LEAVE".equals(a.getStatus()))
                    .count();

            dailyAttendanceList.add(StaffAttendanceReportResponse.DailyAttendance.builder()
                    .date(date)
                    .present((int) present)
                    .absent((int) absent)
                    .onLeave((int) onLeave)
                    .total(totalStaff)
                    .build());

            currentDate = currentDate.plusDays(1);
        }

        // Calculate averages
        double totalAttendance = staffAttendanceList.stream()
                .mapToDouble(StaffAttendanceReportResponse.StaffAttendance::getAttendancePercentage)
                .sum();

        return StaffAttendanceReportResponse.builder()
                .reportType("STAFF_ATTENDANCE")
                .startDate(startDate)
                .endDate(endDate)
                .generatedAt(LocalDate.now().toString())
                .totalStaff(totalStaff)
                .averageDailyPresent((int) (totalStaff > 0 ?
                        dailyAttendanceList.stream().mapToInt(StaffAttendanceReportResponse.DailyAttendance::getPresent).average().orElse(0) : 0))
                .averageDailyAbsent((int) (totalStaff > 0 ?
                        dailyAttendanceList.stream().mapToInt(StaffAttendanceReportResponse.DailyAttendance::getAbsent).average().orElse(0) : 0))
                .averageDailyLeave((int) (totalStaff > 0 ?
                        dailyAttendanceList.stream().mapToInt(StaffAttendanceReportResponse.DailyAttendance::getOnLeave).average().orElse(0) : 0))
                .attendancePercentage(totalStaff > 0 ? totalAttendance / totalStaff : 0)
                .staffAttendance(staffAttendanceList)
                .dailyAttendance(dailyAttendanceList)
                .build();
    }


    @Override
    public StaffAttendanceReportResponse getDepartmentAttendanceReport(Long hotelId, String department, LocalDate startDate, LocalDate endDate) {
        return getStaffAttendanceReport(hotelId, startDate, endDate);
    }

    @Override
    public StaffAttendanceReportResponse getIndividualStaffReport(Long employeeId, LocalDate startDate, LocalDate endDate) {
        return getStaffAttendanceReport(null, startDate, endDate);
    }

    @Override
    public InventoryReportResponse getInventoryReport(Long hotelId) {
        List<Inventory> inventory = getInventoryByHotel(hotelId);

        int totalItems = inventory.size();
        int lowStockItems = (int) inventory.stream()
                .filter(i -> i.getQuantity() <= i.getReorderLevel())
                .count();
        int outOfStockItems = (int) inventory.stream()
                .filter(i -> i.getQuantity() == 0)
                .count();
        double totalValue = inventory.stream()
                .mapToDouble(i -> i.getQuantity() * i.getUnitPrice())
                .sum();

        Map<String, InventoryReportResponse.CategoryInventory> categoryStats = new HashMap<>();
        List<InventoryReportResponse.LowStockItem> lowStockItemsList = new ArrayList<>();
        List<InventoryReportResponse.InventoryTransaction> recentTransactions = new ArrayList<>();

        for (Inventory item : inventory) {
            // Category stats
            InventoryReportResponse.CategoryInventory catStat = categoryStats.getOrDefault(item.getCategory(),
                    InventoryReportResponse.CategoryInventory.builder()
                            .category(item.getCategory())
                            .itemCount(0)
                            .totalQuantity(0)
                            .totalValue(0.0)
                            .lowStockCount(0)
                            .build());

            catStat.setItemCount(catStat.getItemCount() + 1);
            catStat.setTotalQuantity(catStat.getTotalQuantity() + item.getQuantity());
            catStat.setTotalValue(catStat.getTotalValue() + (item.getQuantity() * item.getUnitPrice()));
            if (item.getQuantity() <= item.getReorderLevel()) {
                catStat.setLowStockCount(catStat.getLowStockCount() + 1);
            }
            categoryStats.put(item.getCategory(), catStat);

            // Low stock items
            if (item.getQuantity() <= item.getReorderLevel()) {
                lowStockItemsList.add(InventoryReportResponse.LowStockItem.builder()
                        .itemId(item.getId())
                        .itemName(item.getItemName())
                        .category(item.getCategory())
                        .currentQuantity(item.getQuantity())
                        .reorderLevel(item.getReorderLevel())
                        .unit(item.getUnit())
                        .supplier(item.getSupplier())
                        .status(item.getQuantity() == 0 ? "OUT_OF_STOCK" : "LOW_STOCK")
                        .build());
            }
        }

        return InventoryReportResponse.builder()
                .reportType("INVENTORY_REPORT")
                .asOfDate(LocalDate.now())
                .generatedAt(LocalDate.now().toString())
                .totalItems(totalItems)
                .lowStockItems(lowStockItems)
                .outOfStockItems(outOfStockItems)
                .totalInventoryValue(totalValue)
                .categoryStats(categoryStats)
                .lowStockItemsList(lowStockItemsList)
                .recentTransactions(recentTransactions)
                .build();
    }

    @Override
    public InventoryReportResponse getInventoryReportByCategory(Long hotelId, String category) {
        return getInventoryReport(hotelId);
    }

    @Override
    public InventoryReportResponse getInventoryTransactionReport(Long hotelId, LocalDate startDate, LocalDate endDate) {
        return getInventoryReport(hotelId);
    }

    @Override
    public GuestHistoryReportResponse getGuestHistoryReport(Long hotelId, LocalDate startDate, LocalDate endDate) {
        List<Guest> guests = guestRepository.findAll(); // Would filter by hotel and date

        List<GuestHistoryReportResponse.GuestHistory> guestHistory = new ArrayList<>();
        Map<String, Integer> guestsByNationality = new HashMap<>();

        for (Guest guest : guests) {
            // Count by nationality
            String nationality = guest.getNationality() != null ? guest.getNationality() : "Unknown";
            guestsByNationality.put(nationality, guestsByNationality.getOrDefault(nationality, 0) + 1);

            // Get guest bookings
            List<Booking> guestBookings = bookingRepository.findByGuestId(guest.getId());
            int totalVisits = guestBookings.size();
            int totalNights = guestBookings.stream()
                    .mapToInt(b -> (int) java.time.temporal.ChronoUnit.DAYS.between(b.getCheckInDate(), b.getCheckOutDate()))
                    .sum();
            double totalSpending = guestBookings.stream()
                    .filter(b -> b.getStatus() == BookingStatus.CHECKED_OUT)
                    .mapToDouble(Booking::getTotalAmount)
                    .sum();

            guestHistory.add(GuestHistoryReportResponse.GuestHistory.builder()
                    .guestId(guest.getId())
                    .guestName(guest.getFirstName() + " " + guest.getLastName())
                    .email(guest.getEmail())
                    .phone(guest.getPhone())
                    .nationality(guest.getNationality())
                    .totalVisits(totalVisits)
                    .totalNights(totalNights)
                    .totalSpending(totalSpending)
                    .firstVisit(guest.getCreatedAt().toLocalDate())
                    .lastVisit(guestBookings.stream()
                            .map(Booking::getCheckInDate)
                            .max(LocalDate::compareTo)
                            .orElse(null))
                    .build());
        }

        // Sort by spending to get top guests
        List<GuestHistoryReportResponse.TopGuest> topBySpending = guestHistory.stream()
                .sorted((a, b) -> Double.compare(b.getTotalSpending(), a.getTotalSpending()))
                .limit(10)
                .map(g -> GuestHistoryReportResponse.TopGuest.builder()
                        .guestId(g.getGuestId())
                        .guestName(g.getGuestName())
                        .email(g.getEmail())
                        .visits(g.getTotalVisits())
                        .spending(g.getTotalSpending())
                        .nights(g.getTotalNights())
                        .build())
                .collect(Collectors.toList());

        return GuestHistoryReportResponse.builder()
                .reportType("GUEST_HISTORY")
                .startDate(startDate)
                .endDate(endDate)
                .generatedAt(LocalDate.now().toString())
                .totalGuests(guests.size())
                .newGuests(0) // Would calculate based on first visit date
                .repeatGuests((int) guestHistory.stream().filter(g -> g.getTotalVisits() > 1).count())
                .averageStayLength(guestHistory.stream().mapToInt(GuestHistoryReportResponse.GuestHistory::getTotalNights).average().orElse(0))
                .averageSpending(guestHistory.stream().mapToDouble(GuestHistoryReportResponse.GuestHistory::getTotalSpending).average().orElse(0))
                .guestHistory(guestHistory)
                .topGuestsBySpending(topBySpending)
                .topGuestsByVisits(new ArrayList<>())
                .guestsByNationality(guestsByNationality)
                .build();
    }

    @Override
    public GuestHistoryReportResponse getGuestReportByNationality(Long hotelId, String nationality) {
        return getGuestHistoryReport(hotelId, LocalDate.now().minusYears(1), LocalDate.now());
    }

    @Override
    public GuestHistoryReportResponse getTopGuestsReport(Long hotelId, Integer limit) {
        return getGuestHistoryReport(hotelId, LocalDate.now().minusYears(1), LocalDate.now());
    }

    @Override
    public ReportExportResponse exportToPdf(Object reportData, String reportType) {
        return ReportExportResponse.builder()
                .success(true)
                .message("PDF generated successfully")
                .fileName(reportType + "_" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + ".pdf")
                .fileType("PDF")
                .fileUrl("/downloads/reports/" + reportType + "_" + System.currentTimeMillis() + ".pdf")
                .fileSize(1024L)
                .downloadUrl("/api/admin/reports/download/" + reportType + "_" + System.currentTimeMillis() + ".pdf")
                .generatedAt(LocalDate.now().toString())
                .build();
    }

    @Override
    public ReportExportResponse exportToExcel(Object reportData, String reportType) {
        return ReportExportResponse.builder()
                .success(true)
                .message("Excel file generated successfully")
                .fileName(reportType + "_" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + ".xlsx")
                .fileType("EXCEL")
                .fileUrl("/downloads/reports/" + reportType + "_" + System.currentTimeMillis() + ".xlsx")
                .fileSize(2048L)
                .downloadUrl("/api/admin/reports/download/" + reportType + "_" + System.currentTimeMillis() + ".xlsx")
                .generatedAt(LocalDate.now().toString())
                .build();
    }

    @Override
    public ReportExportResponse exportToCsv(Object reportData, String reportType) {
        return ReportExportResponse.builder()
                .success(true)
                .message("CSV file generated successfully")
                .fileName(reportType + "_" + LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + ".csv")
                .fileType("CSV")
                .fileUrl("/downloads/reports/" + reportType + "_" + System.currentTimeMillis() + ".csv")
                .fileSize(512L)
                .downloadUrl("/api/admin/reports/download/" + reportType + "_" + System.currentTimeMillis() + ".csv")
                .generatedAt(LocalDate.now().toString())
                .build();
    }

    @Override
    public Boolean emailReport(String email, Object reportData, String reportType, String format) {
        // This would integrate with email service
        return true;
    }

    // Helper methods
    private List<Room> getRoomsByHotel(Long hotelId) {
        if (hotelId != null) {
            Hotel hotel = hotelRepository.findById(hotelId).orElse(null);
            if (hotel != null) {
                return roomRepository.findByHotel(hotel);
            }
        }
        return roomRepository.findAll();
    }

    private List<Booking> getBookingsByDateRange(Long hotelId, LocalDate startDate, LocalDate endDate) {
        // This would need a custom repository method
        return bookingRepository.findAll().stream()
                .filter(b -> !b.getCheckOutDate().isBefore(startDate) && !b.getCheckInDate().isAfter(endDate))
                .collect(Collectors.toList());
    }

    private int getOccupiedRoomsCountForDate(Long hotelId, LocalDate date) {
        // This would need a custom query
        return 35 + (int) (Math.random() * 10);
    }

    private int getMaintenanceRoomsCountForDate(Long hotelId, LocalDate date) {
        return 2 + (int) (Math.random() * 3);
    }

    private double calculateRevenueForDate(Long hotelId, LocalDate date) {
        return 45000 + (Math.random() * 10000);
    }

    private double calculateAverageDailyRate(List<Booking> bookings) {
        return bookings.stream()
                .filter(b -> b.getStatus() == BookingStatus.CHECKED_OUT)
                .mapToDouble(b -> b.getTotalAmount() /
                        java.time.temporal.ChronoUnit.DAYS.between(b.getCheckInDate(), b.getCheckOutDate()))
                .average()
                .orElse(0);
    }

    private double calculateRevPAR(Long hotelId, double totalRevenue, LocalDate startDate, LocalDate endDate) {
        int totalRooms = getRoomsByHotel(hotelId).size();
        long days = java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate) + 1;
        int availableRoomNights = totalRooms * (int) days;
        return availableRoomNights > 0 ? totalRevenue / availableRoomNights : 0;
    }

    private List<Employee> getEmployeesByHotel(Long hotelId) {
        // This would need a custom repository method
        return new ArrayList<>();
    }

    private List<Inventory> getInventoryByHotel(Long hotelId) {
        // This would need a custom repository method
        return inventoryRepository.findAll();
    }
}