package com.spring.hotel_management_backend.model.dto.response.admin.reports;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GuestHistoryReportResponse {

    private String reportType;
    private LocalDate startDate;
    private LocalDate endDate;
    private String generatedAt;

    // Summary
    private Integer totalGuests;
    private Integer newGuests;
    private Integer repeatGuests;
    private Double averageStayLength;
    private Double averageSpending;

    // Guest list
    private List<GuestHistory> guestHistory;

    // Top guests by spending
    private List<TopGuest> topGuestsBySpending;

    // Top guests by visits
    private List<TopGuest> topGuestsByVisits;

    // Nationality wise
    private Map<String, Integer> guestsByNationality;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GuestHistory {
        private Long guestId;
        private String guestName;
        private String email;
        private String phone;
        private String nationality;
        private Integer totalVisits;
        private Integer totalNights;
        private Double totalSpending;
        private LocalDate firstVisit;
        private LocalDate lastVisit;
        private String preferredRoomType;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TopGuest {
        private Long guestId;
        private String guestName;
        private String email;
        private Integer visits;
        private Double spending;
        private Integer nights;
    }
}
