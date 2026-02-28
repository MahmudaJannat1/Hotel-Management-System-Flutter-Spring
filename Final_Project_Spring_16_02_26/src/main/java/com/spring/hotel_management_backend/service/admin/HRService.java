package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.hr.*;
import com.spring.hotel_management_backend.model.dto.response.admin.hr.*;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

public interface HRService {

    // ========== Department Management ==========
    DepartmentResponse createDepartment(DepartmentRequest request);
    List<DepartmentResponse> getAllDepartments(Long hotelId);
    DepartmentResponse getDepartmentById(Long id);
    DepartmentResponse updateDepartment(Long id, DepartmentRequest request);
    void deleteDepartment(Long id);

    // ========== Employee Management ==========
    EmployeeResponse createEmployee(CreateEmployeeRequest request);
    List<EmployeeResponse> getAllEmployees(Long hotelId);
    EmployeeResponse getEmployeeById(Long id);
    EmployeeResponse getEmployeeByUserId(Long userId);
    EmployeeResponse getEmployeeByEmployeeId(String employeeId);
    List<EmployeeResponse> getEmployeesByDepartment(Long departmentId);
    List<EmployeeResponse> getEmployeesByEmploymentType(String employmentType);
    List<EmployeeResponse> getEmployeesByStatus(String status);
    List<EmployeeResponse> searchEmployees(String searchTerm);
    EmployeeResponse updateEmployee(Long id, UpdateEmployeeRequest request);
    EmployeeResponse updateEmployeeStatus(Long id, String status);
    void deleteEmployee(Long id);

    // ========== Attendance Management ==========
    AttendanceResponse markAttendance(MarkAttendanceRequest request);
    List<AttendanceResponse> getAttendanceByDate(LocalDate date, Long hotelId);
    List<AttendanceResponse> getAttendanceByEmployee(Long employeeId, LocalDate startDate, LocalDate endDate);
    List<AttendanceResponse> getAttendanceByDepartment(Long departmentId, LocalDate date);
    AttendanceResponse getTodayAttendance(Long employeeId);
    AttendanceResponse updateAttendance(Long id, MarkAttendanceRequest request);
    void approveAttendance(Long id, String approvedBy);

    // ========== Leave Management ==========
    LeaveResponse applyLeave(LeaveRequest request);
    List<LeaveResponse> getAllLeaves(Long hotelId);
    LeaveResponse getLeaveById(Long id);
    List<LeaveResponse> getLeavesByEmployee(Long employeeId);
    List<LeaveResponse> getLeavesByStatus(String status);
    List<LeaveResponse> getPendingLeaves(Long hotelId);
    List<LeaveResponse> getLeavesByDateRange(LocalDate startDate, LocalDate endDate);
    LeaveResponse approveLeave(ApproveLeaveRequest request);
    LeaveResponse cancelLeave(Long id);

    // ========== Shift Management ==========
    ShiftResponse createShift(CreateShiftRequest request);
    List<ShiftResponse> getAllShifts(Long hotelId);
    ShiftResponse getShiftById(Long id);
    ShiftResponse updateShift(Long id, CreateShiftRequest request);
    void deleteShift(Long id);
    ShiftResponse assignShift(AssignShiftRequest request);
    List<EmployeeResponse> getEmployeesByShift(Long shiftId);

    // ========== Payroll Management ==========
    List<PayrollResponse> generatePayroll(GeneratePayrollRequest request);
    List<PayrollResponse> getPayrollByMonth(YearMonth month, Long hotelId);
    PayrollResponse getEmployeePayroll(Long employeeId, YearMonth month);
    List<PayrollResponse> getEmployeePayrollHistory(Long employeeId);
    PayrollResponse updatePayrollStatus(Long id, String status, String approvedBy);
    PayrollResponse processPayment(Long id, String paymentMethod, String transactionId);
    Double getTotalPayrollByMonth(YearMonth month, Long hotelId);

    // ========== Reports & Statistics ==========
    Integer getTotalEmployeesCount(Long hotelId);
    Integer getActiveEmployeesCount(Long hotelId);
    Integer getTodayPresentCount(Long hotelId);
    Integer getTodayAbsentCount(Long hotelId);
    Integer getTodayLeaveCount(Long hotelId);
    Integer getPendingLeaveCount(Long hotelId);
    Double getMonthlyPayrollTotal(YearMonth month, Long hotelId);


    LeaveResponse updateLeaveStatus(Long id, String status, String rejectionReason);
}