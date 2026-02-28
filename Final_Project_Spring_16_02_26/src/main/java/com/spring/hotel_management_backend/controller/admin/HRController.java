package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.hr.*;
import com.spring.hotel_management_backend.model.dto.response.admin.hr.*;
import com.spring.hotel_management_backend.service.admin.HRService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/hr")
@RequiredArgsConstructor
@Tag(name = "HR Management", description = "Admin HR management APIs")
@SecurityRequirement(name = "Bearer Authentication")

public class HRController {

    private final HRService hrService;

    // ========== Department Endpoints ==========

    @PostMapping("/departments")
    @Operation(summary = "Create new department")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DepartmentResponse> createDepartment(@RequestBody DepartmentRequest request) {
        return new ResponseEntity<>(hrService.createDepartment(request), HttpStatus.CREATED);
    }

    @GetMapping("/departments")
    @Operation(summary = "Get all departments")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<DepartmentResponse>> getAllDepartments(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(hrService.getAllDepartments(hotelId));
    }

    @GetMapping("/departments/{id}")
    @Operation(summary = "Get department by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DepartmentResponse> getDepartmentById(@PathVariable Long id) {
        return ResponseEntity.ok(hrService.getDepartmentById(id));
    }

    @PutMapping("/departments/{id}")
    @Operation(summary = "Update department")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DepartmentResponse> updateDepartment(
            @PathVariable Long id,
            @RequestBody DepartmentRequest request) {
        return ResponseEntity.ok(hrService.updateDepartment(id, request));
    }

    @DeleteMapping("/departments/{id}")
    @Operation(summary = "Delete department")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteDepartment(@PathVariable Long id) {
        hrService.deleteDepartment(id);
        return ResponseEntity.noContent().build();
    }

    // ========== Employee Endpoints ==========

    @PostMapping("/employees")
    @Operation(summary = "Create new employee")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EmployeeResponse> createEmployee(@RequestBody CreateEmployeeRequest request) {
        return new ResponseEntity<>(hrService.createEmployee(request), HttpStatus.CREATED);
    }

    @GetMapping("/employees")
    @Operation(summary = "Get all employees")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EmployeeResponse>> getAllEmployees(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(hrService.getAllEmployees(hotelId));
    }

    @GetMapping("/employees/{id}")
    @Operation(summary = "Get employee by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EmployeeResponse> getEmployeeById(@PathVariable Long id) {
        return ResponseEntity.ok(hrService.getEmployeeById(id));
    }

    @GetMapping("/employees/user/{userId}")
    @Operation(summary = "Get employee by user ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EmployeeResponse> getEmployeeByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(hrService.getEmployeeByUserId(userId));
    }

    @GetMapping("/employees/employee-id/{employeeId}")
    @Operation(summary = "Get employee by employee ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EmployeeResponse> getEmployeeByEmployeeId(@PathVariable String employeeId) {
        return ResponseEntity.ok(hrService.getEmployeeByEmployeeId(employeeId));
    }

    @GetMapping("/employees/department/{departmentId}")
    @Operation(summary = "Get employees by department")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EmployeeResponse>> getEmployeesByDepartment(@PathVariable Long departmentId) {
        return ResponseEntity.ok(hrService.getEmployeesByDepartment(departmentId));
    }

    @GetMapping("/employees/type/{employmentType}")
    @Operation(summary = "Get employees by employment type")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EmployeeResponse>> getEmployeesByEmploymentType(@PathVariable String employmentType) {
        return ResponseEntity.ok(hrService.getEmployeesByEmploymentType(employmentType));
    }

    @GetMapping("/employees/status/{status}")
    @Operation(summary = "Get employees by status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EmployeeResponse>> getEmployeesByStatus(@PathVariable String status) {
        return ResponseEntity.ok(hrService.getEmployeesByStatus(status));
    }

    @GetMapping("/employees/search")
    @Operation(summary = "Search employees")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EmployeeResponse>> searchEmployees(@RequestParam String term) {
        return ResponseEntity.ok(hrService.searchEmployees(term));
    }




    @PutMapping("/employees/{id}")
    @Operation(summary = "Update employee")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EmployeeResponse> updateEmployee(
            @PathVariable Long id,
            @RequestBody UpdateEmployeeRequest request) {
        EmployeeResponse response = hrService.updateEmployee(id, request);
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/leaves/{id}")
    @Operation(summary = "Update leave status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<LeaveResponse> updateLeaveStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        String status = request.get("status");
        String rejectionReason = request.get("rejectionReason");
        LeaveResponse response = hrService.updateLeaveStatus(id, status, rejectionReason);
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/employees/{id}/status")
    @Operation(summary = "Update employee status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EmployeeResponse> updateEmployeeStatus(
            @PathVariable Long id,
            @RequestParam String status) {
        return ResponseEntity.ok(hrService.updateEmployeeStatus(id, status));
    }

    @DeleteMapping("/employees/{id}")
    @Operation(summary = "Delete employee")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteEmployee(@PathVariable Long id) {
        hrService.deleteEmployee(id);
        return ResponseEntity.noContent().build();
    }

    // ========== Attendance Endpoints ==========

    @PostMapping("/attendance")
    @Operation(summary = "Mark attendance")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AttendanceResponse> markAttendance(@RequestBody MarkAttendanceRequest request) {
        return new ResponseEntity<>(hrService.markAttendance(request), HttpStatus.CREATED);
    }

    @GetMapping("/attendance/date")
    @Operation(summary = "Get attendance by date")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AttendanceResponse>> getAttendanceByDate(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam Long hotelId) {
        return ResponseEntity.ok(hrService.getAttendanceByDate(date, hotelId));
    }

    @GetMapping("/attendance/employee/{employeeId}")
    @Operation(summary = "Get attendance by employee")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AttendanceResponse>> getAttendanceByEmployee(
            @PathVariable Long employeeId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(hrService.getAttendanceByEmployee(employeeId, startDate, endDate));
    }

    @GetMapping("/attendance/department/{departmentId}")
    @Operation(summary = "Get attendance by department")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AttendanceResponse>> getAttendanceByDepartment(
            @PathVariable Long departmentId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(hrService.getAttendanceByDepartment(departmentId, date));
    }

    @GetMapping("/attendance/today/{employeeId}")
    @Operation(summary = "Get today's attendance")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AttendanceResponse> getTodayAttendance(@PathVariable Long employeeId) {
        return ResponseEntity.ok(hrService.getTodayAttendance(employeeId));
    }

    @PutMapping("/attendance/{id}")
    @Operation(summary = "Update attendance")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AttendanceResponse> updateAttendance(
            @PathVariable Long id,
            @RequestBody MarkAttendanceRequest request) {
        return ResponseEntity.ok(hrService.updateAttendance(id, request));
    }

    @PatchMapping("/attendance/{id}/approve")
    @Operation(summary = "Approve attendance")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> approveAttendance(
            @PathVariable Long id,
            @RequestParam String approvedBy) {
        hrService.approveAttendance(id, approvedBy);
        return ResponseEntity.ok().build();
    }

    // ========== Leave Endpoints ==========

    @PostMapping("/leaves")
    @Operation(summary = "Apply for leave")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<LeaveResponse> applyLeave(@RequestBody LeaveRequest request) {
        return new ResponseEntity<>(hrService.applyLeave(request), HttpStatus.CREATED);
    }

    @GetMapping("/leaves")
    @Operation(summary = "Get all leaves")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<LeaveResponse>> getAllLeaves(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(hrService.getAllLeaves(hotelId));
    }

    @GetMapping("/leaves/{id}")
    @Operation(summary = "Get leave by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<LeaveResponse> getLeaveById(@PathVariable Long id) {
        return ResponseEntity.ok(hrService.getLeaveById(id));
    }

    @GetMapping("/leaves/employee/{employeeId}")
    @Operation(summary = "Get leaves by employee")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<LeaveResponse>> getLeavesByEmployee(@PathVariable Long employeeId) {
        return ResponseEntity.ok(hrService.getLeavesByEmployee(employeeId));
    }

    @GetMapping("/leaves/status/{status}")
    @Operation(summary = "Get leaves by status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<LeaveResponse>> getLeavesByStatus(@PathVariable String status) {
        return ResponseEntity.ok(hrService.getLeavesByStatus(status));
    }

    @GetMapping("/leaves/pending")
    @Operation(summary = "Get pending leaves")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<LeaveResponse>> getPendingLeaves(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(hrService.getPendingLeaves(hotelId));
    }

    @PostMapping("/leaves/approve")
    @Operation(summary = "Approve or reject leave")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<LeaveResponse> approveLeave(@RequestBody ApproveLeaveRequest request) {
        return ResponseEntity.ok(hrService.approveLeave(request));
    }

    @PostMapping("/leaves/{id}/cancel")
    @Operation(summary = "Cancel leave")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<LeaveResponse> cancelLeave(@PathVariable Long id) {
        return ResponseEntity.ok(hrService.cancelLeave(id));
    }

    // ========== Shift Endpoints ==========

    @PostMapping("/shifts")
    @Operation(summary = "Create shift")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ShiftResponse> createShift(@RequestBody CreateShiftRequest request) {
        return new ResponseEntity<>(hrService.createShift(request), HttpStatus.CREATED);
    }

    @GetMapping("/shifts")
    @Operation(summary = "Get all shifts")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ShiftResponse>> getAllShifts(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(hrService.getAllShifts(hotelId));
    }

    @GetMapping("/shifts/{id}")
    @Operation(summary = "Get shift by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ShiftResponse> getShiftById(@PathVariable Long id) {
        return ResponseEntity.ok(hrService.getShiftById(id));
    }

    @PutMapping("/shifts/{id}")
    @Operation(summary = "Update shift")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ShiftResponse> updateShift(
            @PathVariable Long id,
            @RequestBody CreateShiftRequest request) {
        return ResponseEntity.ok(hrService.updateShift(id, request));
    }

    @DeleteMapping("/shifts/{id}")
    @Operation(summary = "Delete shift")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteShift(@PathVariable Long id) {
        hrService.deleteShift(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/shifts/assign")
    @Operation(summary = "Assign shift to employee")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ShiftResponse> assignShift(@RequestBody AssignShiftRequest request) {
        return ResponseEntity.ok(hrService.assignShift(request));
    }

    @GetMapping("/shifts/{shiftId}/employees")
    @Operation(summary = "Get employees by shift")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EmployeeResponse>> getEmployeesByShift(@PathVariable Long shiftId) {
        return ResponseEntity.ok(hrService.getEmployeesByShift(shiftId));
    }

    // ========== Payroll Endpoints ==========

    @PostMapping("/payroll/generate")
    @Operation(summary = "Generate payroll")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<PayrollResponse>> generatePayroll(@RequestBody GeneratePayrollRequest request) {
        return new ResponseEntity<>(hrService.generatePayroll(request), HttpStatus.CREATED);
    }

    @GetMapping("/payroll/month/{year}/{month}")
    @Operation(summary = "Get payroll by month")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<PayrollResponse>> getPayrollByMonth(
            @PathVariable int year,
            @PathVariable int month,
            @RequestParam(required = false) Long hotelId) {
        YearMonth yearMonth = YearMonth.of(year, month);
        return ResponseEntity.ok(hrService.getPayrollByMonth(yearMonth, hotelId));
    }

    @GetMapping("/payroll/employee/{employeeId}/{year}/{month}")
    @Operation(summary = "Get employee payroll")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PayrollResponse> getEmployeePayroll(
            @PathVariable Long employeeId,
            @PathVariable int year,
            @PathVariable int month) {
        YearMonth yearMonth = YearMonth.of(year, month);
        return ResponseEntity.ok(hrService.getEmployeePayroll(employeeId, yearMonth));
    }

    @GetMapping("/payroll/employee/{employeeId}/history")
    @Operation(summary = "Get employee payroll history")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<PayrollResponse>> getEmployeePayrollHistory(@PathVariable Long employeeId) {
        return ResponseEntity.ok(hrService.getEmployeePayrollHistory(employeeId));
    }

    @PatchMapping("/payroll/{id}/status")
    @Operation(summary = "Update payroll status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PayrollResponse> updatePayrollStatus(
            @PathVariable Long id,
            @RequestParam String status,
            @RequestParam String approvedBy) {
        return ResponseEntity.ok(hrService.updatePayrollStatus(id, status, approvedBy));
    }

    @PostMapping("/payroll/{id}/process-payment")
    @Operation(summary = "Process payment")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<PayrollResponse> processPayment(
            @PathVariable Long id,
            @RequestParam String paymentMethod,
            @RequestParam String transactionId) {
        return ResponseEntity.ok(hrService.processPayment(id, paymentMethod, transactionId));
    }

    // ========== Statistics Endpoints ==========

    @GetMapping("/statistics/employees/total")
    @Operation(summary = "Get total employees count")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Integer> getTotalEmployeesCount(@RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(hrService.getTotalEmployeesCount(hotelId));
    }

    @GetMapping("/statistics/employees/active")
    @Operation(summary = "Get active employees count")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Integer> getActiveEmployeesCount(@RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(hrService.getActiveEmployeesCount(hotelId));
    }

    @GetMapping("/statistics/attendance/today")
    @Operation(summary = "Get today's attendance statistics")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AttendanceStatsResponse> getTodayAttendanceStats(@RequestParam(required = false) Long hotelId) {
        int present = hrService.getTodayPresentCount(hotelId);
        int absent = hrService.getTodayAbsentCount(hotelId);
        int leave = hrService.getTodayLeaveCount(hotelId);
        int total = hrService.getActiveEmployeesCount(hotelId);

        return ResponseEntity.ok(new AttendanceStatsResponse(present, absent, leave, total));
    }

    @GetMapping("/statistics/leaves/pending")
    @Operation(summary = "Get pending leaves count")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Integer> getPendingLeaveCount(@RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(hrService.getPendingLeaveCount(hotelId));
    }

    @GetMapping("/statistics/payroll/month/{year}/{month}")
    @Operation(summary = "Get monthly payroll total")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Double> getMonthlyPayrollTotal(
            @PathVariable int year,
            @PathVariable int month,
            @RequestParam(required = false) Long hotelId) {
        YearMonth yearMonth = YearMonth.of(year, month);
        return ResponseEntity.ok(hrService.getMonthlyPayrollTotal(yearMonth, hotelId));
    }

    // Inner class for attendance stats
    private static class AttendanceStatsResponse {
        private int present;
        private int absent;
        private int onLeave;
        private int total;

        public AttendanceStatsResponse(int present, int absent, int onLeave, int total) {
            this.present = present;
            this.absent = absent;
            this.onLeave = onLeave;
            this.total = total;
        }

        public int getPresent() { return present; }
        public int getAbsent() { return absent; }
        public int getOnLeave() { return onLeave; }
        public int getTotal() { return total; }
    }
}