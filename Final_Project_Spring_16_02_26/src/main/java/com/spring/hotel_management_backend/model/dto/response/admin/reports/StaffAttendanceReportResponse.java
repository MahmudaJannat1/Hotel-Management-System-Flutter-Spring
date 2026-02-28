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
public class StaffAttendanceReportResponse {

    private String reportType;
    private LocalDate startDate;
    private LocalDate endDate;
    private String generatedAt;

    // Summary
    private Integer totalStaff;
    private Integer averageDailyPresent;
    private Integer averageDailyAbsent;
    private Integer averageDailyLeave;
    private Double attendancePercentage;

    // Department wise
    private Map<String, DepartmentAttendance> departmentStats;

    // Individual staff
    private List<StaffAttendance> staffAttendance;

    // Daily summary
    private List<DailyAttendance> dailyAttendance;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DepartmentAttendance {
        private String department;
        private Integer totalStaff;
        private Integer present;
        private Integer absent;
        private Integer onLeave;
        private Double attendancePercentage;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StaffAttendance {
        private Long employeeId;
        private String employeeName;
        private String department;
        private String position;
        private Integer totalDays;
        private Integer presentDays;
        private Integer absentDays;
        private Integer leaveDays;
        private Double attendancePercentage;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyAttendance {
        private LocalDate date;
        private Integer present;
        private Integer absent;
        private Integer onLeave;
        private Integer total;
    }
}
