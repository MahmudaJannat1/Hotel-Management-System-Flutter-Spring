package com.spring.hotel_management_backend.service.admin.impl;

import com.spring.hotel_management_backend.model.dto.request.admin.hr.*;
import com.spring.hotel_management_backend.model.dto.response.admin.hr.*;
import com.spring.hotel_management_backend.model.entity.*;
import com.spring.hotel_management_backend.model.enums.RoleType;
import com.spring.hotel_management_backend.repository.*;
import com.spring.hotel_management_backend.service.admin.HRService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class HRServiceImpl implements HRService {

    private final EmployeeRepository employeeRepository;
    private final DepartmentRepository departmentRepository;
    private final AttendanceRepository attendanceRepository;
    private final LeaveRepository leaveRepository;
    private final ShiftRepository shiftRepository;
    private final PayrollRepository payrollRepository;
    private final UserRepository userRepository;

    // ========== Department Management ==========

    @Override
    @Transactional
    public DepartmentResponse createDepartment(DepartmentRequest request) {
        if (departmentRepository.existsByNameAndHotelId(request.getName(), request.getHotelId())) {
            throw new RuntimeException("Department already exists with name: " + request.getName());
        }

        Department department = new Department();
        department.setName(request.getName());
        department.setDescription(request.getDescription());
        department.setHeadOfDepartment(request.getHeadOfDepartment());
        department.setHeadEmployeeId(request.getHeadEmployeeId());
        department.setLocation(request.getLocation());
        department.setContactNumber(request.getContactNumber());
        department.setEmail(request.getEmail());
        department.setHotelId(request.getHotelId());
        department.setIsActive(true);

        Department savedDepartment = departmentRepository.save(department);
        return mapToDepartmentResponse(savedDepartment);
    }

    @Override
    public List<DepartmentResponse> getAllDepartments(Long hotelId) {
        List<Department> departments;
        if (hotelId != null) {
            departments = departmentRepository.findByHotelId(hotelId);
        } else {
            departments = departmentRepository.findAll();
        }
        return departments.stream()
                .map(this::mapToDepartmentResponse)
                .collect(Collectors.toList());
    }

    @Override
    public DepartmentResponse getDepartmentById(Long id) {
        Department department = departmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Department not found with id: " + id));
        return mapToDepartmentResponse(department);
    }

    @Override
    @Transactional
    public DepartmentResponse updateDepartment(Long id, DepartmentRequest request) {
        Department department = departmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Department not found with id: " + id));

        department.setName(request.getName());
        department.setDescription(request.getDescription());
        department.setHeadOfDepartment(request.getHeadOfDepartment());
        department.setHeadEmployeeId(request.getHeadEmployeeId());
        department.setLocation(request.getLocation());
        department.setContactNumber(request.getContactNumber());
        department.setEmail(request.getEmail());

        Department updatedDepartment = departmentRepository.save(department);
        return mapToDepartmentResponse(updatedDepartment);
    }

    @Override
    @Transactional
    public void deleteDepartment(Long id) {
        if (!departmentRepository.existsById(id)) {
            throw new RuntimeException("Department not found with id: " + id);
        }
        departmentRepository.deleteById(id);
    }

    // ========== Employee Management ==========

    @Override
    @Transactional
    public EmployeeResponse createEmployee(CreateEmployeeRequest request) {
        // Check if employee ID exists
        if (employeeRepository.existsByEmployeeId(request.getEmployeeId())) {
            throw new RuntimeException("Employee ID already exists: " + request.getEmployeeId());
        }

        // Check if email exists
        if (request.getEmail() != null && employeeRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists: " + request.getEmail());
        }

        Employee employee = new Employee();
        employee.setEmployeeId(request.getEmployeeId());
        employee.setFirstName(request.getFirstName());
        employee.setLastName(request.getLastName());
        employee.setEmail(request.getEmail());
        employee.setPhone(request.getPhone());
        employee.setAlternativePhone(request.getAlternativePhone());
        employee.setEmergencyContact(request.getEmergencyContact());
        employee.setEmergencyPhone(request.getEmergencyPhone());
        employee.setAddress(request.getAddress());
        employee.setCity(request.getCity());
        employee.setState(request.getState());
        employee.setCountry(request.getCountry());
        employee.setPostalCode(request.getPostalCode());
        employee.setDateOfBirth(request.getDateOfBirth());
        employee.setGender(request.getGender());
        employee.setMaritalStatus(request.getMaritalStatus());
        employee.setNationality(request.getNationality());

        // Department
        if (request.getDepartmentId() != null) {
            Department department = departmentRepository.findById(request.getDepartmentId())
                    .orElseThrow(() -> new RuntimeException("Department not found"));
            employee.setDepartment(department);
        }

        employee.setPosition(request.getPosition());
        employee.setJoiningDate(request.getJoiningDate());
        employee.setContractEndDate(request.getContractEndDate());
        employee.setEmploymentType(request.getEmploymentType());
        employee.setEmploymentStatus("ACTIVE");

        // Salary
        employee.setBasicSalary(request.getBasicSalary());
        employee.setHouseRent(request.getHouseRent());
        employee.setMedicalAllowance(request.getMedicalAllowance());
        employee.setConveyanceAllowance(request.getConveyanceAllowance());
        employee.setOtherAllowances(request.getOtherAllowances());

        double totalSalary = (request.getBasicSalary() != null ? request.getBasicSalary() : 0) +
                (request.getHouseRent() != null ? request.getHouseRent() : 0) +
                (request.getMedicalAllowance() != null ? request.getMedicalAllowance() : 0) +
                (request.getConveyanceAllowance() != null ? request.getConveyanceAllowance() : 0) +
                (request.getOtherAllowances() != null ? request.getOtherAllowances() : 0);
        employee.setTotalSalary(totalSalary);

        // Identification
        employee.setNidNumber(request.getNidNumber());
        employee.setPassportNumber(request.getPassportNumber());
        employee.setDrivingLicense(request.getDrivingLicense());

        // Bank
        employee.setBankName(request.getBankName());
        employee.setBankAccountNo(request.getBankAccountNo());
        employee.setBankBranch(request.getBankBranch());
        employee.setRoutingNo(request.getRoutingNo());

        // Other
        employee.setQualification(request.getQualification());
        employee.setExperience(request.getExperience());
        employee.setSkills(request.getSkills());
        employee.setProfileImageUrl(request.getProfileImageUrl());
        employee.setShiftId(request.getShiftId());
        employee.setReportingTo(request.getReportingTo());
        employee.setReportingManagerId(request.getReportingManagerId());
        employee.setBloodGroup(request.getBloodGroup());
        employee.setReligion(request.getReligion());
        employee.setRemarks(request.getRemarks());

        employee.setIsActive(true);

        // Create user account if requested
        if (request.getCreateUserAccount() != null && request.getCreateUserAccount()) {
            User user = new User();
            user.setUsername(request.getUsername());
            user.setEmail(request.getEmail());
            user.setPassword(request.getPassword()); // Should be encoded
            user.setFirstName(request.getFirstName());
            user.setLastName(request.getLastName());
            user.setPhoneNumber(request.getPhone());
            user.setRole(RoleType.STAFF);
            user.setIsActive(true);

            User savedUser = userRepository.save(user);
            employee.setUser(savedUser);
        }

        Employee savedEmployee = employeeRepository.save(employee);
        return mapToEmployeeResponse(savedEmployee);
    }

    @Override
    public List<EmployeeResponse> getAllEmployees(Long hotelId) {
        List<Employee> employees;
        if (hotelId != null) {
            employees = employeeRepository.findByHotelId(hotelId);
        } else {
            employees = employeeRepository.findAll();
        }
        return employees.stream()
                .map(this::mapToEmployeeResponse)
                .collect(Collectors.toList());
    }

    @Override
    public EmployeeResponse getEmployeeById(Long id) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + id));
        return mapToEmployeeResponse(employee);
    }

    @Override
    public EmployeeResponse getEmployeeByUserId(Long userId) {
        Employee employee = employeeRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Employee not found with user id: " + userId));
        return mapToEmployeeResponse(employee);
    }

    @Override
    public EmployeeResponse getEmployeeByEmployeeId(String employeeId) {
        Employee employee = employeeRepository.findByEmployeeId(employeeId)
                .orElseThrow(() -> new RuntimeException("Employee not found with employee id: " + employeeId));
        return mapToEmployeeResponse(employee);
    }

    @Override
    public List<EmployeeResponse> getEmployeesByDepartment(Long departmentId) {
        return employeeRepository.findByDepartmentId(departmentId)
                .stream()
                .map(this::mapToEmployeeResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<EmployeeResponse> getEmployeesByEmploymentType(String employmentType) {
        return employeeRepository.findByEmploymentType(employmentType)
                .stream()
                .map(this::mapToEmployeeResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<EmployeeResponse> getEmployeesByStatus(String status) {
        return employeeRepository.findByEmploymentStatus(status)
                .stream()
                .map(this::mapToEmployeeResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<EmployeeResponse> searchEmployees(String searchTerm) {
        return employeeRepository.searchEmployees(searchTerm)
                .stream()
                .map(this::mapToEmployeeResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public EmployeeResponse updateEmployee(Long id, UpdateEmployeeRequest request) {
        // Find existing employee
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + id));

        // Check if employeeId already exists (if changed)
        if (request.getEmployeeId() != null && !employee.getEmployeeId().equals(request.getEmployeeId()) &&
                employeeRepository.existsByEmployeeId(request.getEmployeeId())) {
            throw new RuntimeException("Employee ID already exists: " + request.getEmployeeId());
        }

        // Check if email already exists (if changed)
        if (request.getEmail() != null && !employee.getEmail().equals(request.getEmail()) &&
                employeeRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists: " + request.getEmail());
        }

        // Update fields
        if (request.getEmployeeId() != null) {
            employee.setEmployeeId(request.getEmployeeId());
        }
        if (request.getFirstName() != null) {
            employee.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null) {
            employee.setLastName(request.getLastName());
        }
        if (request.getEmail() != null) {
            employee.setEmail(request.getEmail());
        }
        if (request.getPhone() != null) {
            employee.setPhone(request.getPhone());
        }
        if (request.getPosition() != null) {
            employee.setPosition(request.getPosition());
        }
        if (request.getDepartmentId() != null) {
            Department department = departmentRepository.findById(request.getDepartmentId().longValue())
                    .orElseThrow(() -> new RuntimeException("Department not found"));
            employee.setDepartment(department);
        }
        if (request.getEmploymentType() != null) {
            employee.setEmploymentType(request.getEmploymentType());
        }
        if (request.getEmploymentStatus() != null) {
            employee.setEmploymentStatus(request.getEmploymentStatus());
        }
        if (request.getBasicSalary() != null) {
            employee.setBasicSalary(request.getBasicSalary());

            // Recalculate total salary
            double total = request.getBasicSalary() +
                    (employee.getHouseRent() != null ? employee.getHouseRent() : 0) +
                    (employee.getMedicalAllowance() != null ? employee.getMedicalAllowance() : 0) +
                    (employee.getConveyanceAllowance() != null ? employee.getConveyanceAllowance() : 0) +
                    (employee.getOtherAllowances() != null ? employee.getOtherAllowances() : 0);
            employee.setTotalSalary(total);
        }
        if (request.getJoiningDate() != null) {
            employee.setJoiningDate(request.getJoiningDate());
        }
        if (request.getEmergencyContact() != null) {
            employee.setEmergencyContact(request.getEmergencyContact());
        }
        if (request.getEmergencyPhone() != null) {
            employee.setEmergencyPhone(request.getEmergencyPhone());
        }
        if (request.getAddress() != null) {
            employee.setAddress(request.getAddress());
        }

        Employee updatedEmployee = employeeRepository.save(employee);
        return mapToEmployeeResponse(updatedEmployee);
    }

    @Override
    @Transactional
    public EmployeeResponse updateEmployeeStatus(Long id, String status) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found with id: " + id));

        employee.setEmploymentStatus(status);

        Employee updatedEmployee = employeeRepository.save(employee);
        return mapToEmployeeResponse(updatedEmployee);
    }

    @Override
    @Transactional
    public void deleteEmployee(Long id) {
        if (!employeeRepository.existsById(id)) {
            throw new RuntimeException("Employee not found with id: " + id);
        }
        employeeRepository.deleteById(id);
    }

    // ========== Attendance Management ==========

    @Override
    @Transactional
    public AttendanceResponse markAttendance(MarkAttendanceRequest request) {
        Employee employee = employeeRepository.findById(request.getEmployeeId())
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        // Check if attendance already marked for this date
        attendanceRepository.findByEmployeeIdAndDate(request.getEmployeeId(), request.getDate())
                .ifPresent(a -> {
                    throw new RuntimeException("Attendance already marked for this date");
                });

        Attendance attendance = new Attendance();
        attendance.setEmployee(employee);
        attendance.setDate(request.getDate());
        attendance.setCheckInTime(request.getCheckInTime());
        attendance.setCheckOutTime(request.getCheckOutTime());
        attendance.setStatus(request.getStatus());
        attendance.setRemarks(request.getRemarks());
        attendance.setMarkedBy("ADMIN");
        attendance.setMarkedAt(LocalDateTime.now());
        attendance.setIsApproved(request.getIsApproved() != null ? request.getIsApproved() : true);

        // Calculate working hours
        if (request.getCheckInTime() != null && request.getCheckOutTime() != null) {
            double hours = ChronoUnit.HOURS.between(request.getCheckInTime(), request.getCheckOutTime());
            attendance.setWorkingHours(hours);
        }

        Attendance savedAttendance = attendanceRepository.save(attendance);
        return mapToAttendanceResponse(savedAttendance);
    }

    @Override
    public List<AttendanceResponse> getAttendanceByDate(LocalDate date, Long hotelId) {
        return attendanceRepository.findByDate(date)
                .stream()
                .filter(a -> hotelId == null || (a.getEmployee().getHotel() != null && a.getEmployee().getHotel().getId().equals(hotelId)))
                .map(this::mapToAttendanceResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<AttendanceResponse> getAttendanceByEmployee(Long employeeId, LocalDate startDate, LocalDate endDate) {
        return attendanceRepository.findByEmployeeIdAndDateRange(employeeId, startDate, endDate)
                .stream()
                .map(this::mapToAttendanceResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<AttendanceResponse> getAttendanceByDepartment(Long departmentId, LocalDate date) {
        return attendanceRepository.findByDepartmentAndDate(departmentId, date)
                .stream()
                .map(this::mapToAttendanceResponse)
                .collect(Collectors.toList());
    }

    @Override
    public AttendanceResponse getTodayAttendance(Long employeeId) {
        return attendanceRepository.findByEmployeeIdAndDate(employeeId, LocalDate.now())
                .map(this::mapToAttendanceResponse)
                .orElse(null);
    }

    @Override
    @Transactional
    public AttendanceResponse updateAttendance(Long id, MarkAttendanceRequest request) {
        Attendance attendance = attendanceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Attendance not found"));

        attendance.setCheckInTime(request.getCheckInTime());
        attendance.setCheckOutTime(request.getCheckOutTime());
        attendance.setStatus(request.getStatus());
        attendance.setRemarks(request.getRemarks());

        if (request.getCheckInTime() != null && request.getCheckOutTime() != null) {
            double hours = ChronoUnit.HOURS.between(request.getCheckInTime(), request.getCheckOutTime());
            attendance.setWorkingHours(hours);
        }

        Attendance updatedAttendance = attendanceRepository.save(attendance);
        return mapToAttendanceResponse(updatedAttendance);
    }

    @Override
    @Transactional
    public void approveAttendance(Long id, String approvedBy) {
        Attendance attendance = attendanceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Attendance not found"));

        attendance.setIsApproved(true);
        attendance.setApprovedBy(approvedBy);
        attendance.setApprovedAt(LocalDateTime.now());

        attendanceRepository.save(attendance);
    }

    // ========== Leave Management ==========

    @Override
    @Transactional
    public LeaveResponse applyLeave(LeaveRequest request) {
        Employee employee = employeeRepository.findById(request.getEmployeeId())
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        Leave leave = new Leave();
        leave.setEmployee(employee);
        leave.setLeaveType(request.getLeaveType());
        leave.setStartDate(request.getStartDate());
        leave.setEndDate(request.getEndDate());
        leave.setTotalDays((int) ChronoUnit.DAYS.between(request.getStartDate(), request.getEndDate()) + 1);
        leave.setReason(request.getReason());
        leave.setStatus("PENDING");
        leave.setAppliedBy("EMPLOYEE");
        leave.setAppliedDate(LocalDate.now());
        leave.setContactDuringLeave(request.getContactDuringLeave());
        leave.setHandoverNotes(request.getHandoverNotes());
        leave.setIsPaid(request.getIsPaid() != null ? request.getIsPaid() : true);

        Leave savedLeave = leaveRepository.save(leave);
        return mapToLeaveResponse(savedLeave);
    }

    @Override
    public List<LeaveResponse> getAllLeaves(Long hotelId) {
        return leaveRepository.findAll()
                .stream()
                .filter(l -> hotelId == null ||
                        (l.getEmployee().getHotel() != null && l.getEmployee().getHotel().getId().equals(hotelId)))
                .map(this::mapToLeaveResponse)
                .collect(Collectors.toList());
    }

    @Override
    public LeaveResponse getLeaveById(Long id) {
        Leave leave = leaveRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Leave not found with id: " + id));
        return mapToLeaveResponse(leave);
    }

    @Override
    public List<LeaveResponse> getLeavesByEmployee(Long employeeId) {
        return leaveRepository.findByEmployeeId(employeeId)
                .stream()
                .map(this::mapToLeaveResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<LeaveResponse> getLeavesByStatus(String status) {
        return leaveRepository.findByStatus(status)
                .stream()
                .map(this::mapToLeaveResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<LeaveResponse> getPendingLeaves(Long hotelId) {
        return leaveRepository.findByStatus("PENDING")
                .stream()
                .filter(l -> hotelId == null ||
                        (l.getEmployee().getHotel() != null && l.getEmployee().getHotel().getId().equals(hotelId)))
                .map(this::mapToLeaveResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<LeaveResponse> getLeavesByDateRange(LocalDate startDate, LocalDate endDate) {
        return leaveRepository.findLeavesInDateRange(startDate, endDate)
                .stream()
                .map(this::mapToLeaveResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public LeaveResponse approveLeave(ApproveLeaveRequest request) {
        Leave leave = leaveRepository.findById(request.getLeaveId())
                .orElseThrow(() -> new RuntimeException("Leave not found"));

        leave.setStatus(request.getStatus());
        if ("REJECTED".equals(request.getStatus())) {
            leave.setRejectionReason(request.getRejectionReason());
        }
        leave.setApprovedBy(request.getApprovedBy());
        leave.setApprovedDate(LocalDate.now());

        Leave updatedLeave = leaveRepository.save(leave);
        return mapToLeaveResponse(updatedLeave);
    }

    @Override
    @Transactional
    public LeaveResponse cancelLeave(Long id) {
        Leave leave = leaveRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Leave not found"));

        leave.setStatus("CANCELLED");

        Leave updatedLeave = leaveRepository.save(leave);
        return mapToLeaveResponse(updatedLeave);
    }

    // ========== Shift Management ==========

    @Override
    @Transactional
    public ShiftResponse createShift(CreateShiftRequest request) {
        Shift shift = new Shift();
        shift.setName(request.getName());
        shift.setStartTime(request.getStartTime());
        shift.setEndTime(request.getEndTime());

        double hours = ChronoUnit.HOURS.between(request.getStartTime(), request.getEndTime());
        shift.setTotalHours(hours);

        shift.setDescription(request.getDescription());
        shift.setOvertimeRate(request.getOvertimeRate());
        shift.setHotelId(request.getHotelId());
        shift.setIsActive(true);

        Shift savedShift = shiftRepository.save(shift);
        return mapToShiftResponse(savedShift);
    }

    @Override
    public List<ShiftResponse> getAllShifts(Long hotelId) {
        List<Shift> shifts;
        if (hotelId != null) {
            shifts = shiftRepository.findByHotelId(hotelId);
        } else {
            shifts = shiftRepository.findAll();
        }
        return shifts.stream()
                .map(this::mapToShiftResponse)
                .collect(Collectors.toList());
    }

    @Override
    public ShiftResponse getShiftById(Long id) {
        Shift shift = shiftRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shift not found with id: " + id));
        return mapToShiftResponse(shift);
    }

    @Override
    @Transactional
    public ShiftResponse updateShift(Long id, CreateShiftRequest request) {
        Shift shift = shiftRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shift not found with id: " + id));

        shift.setName(request.getName());
        shift.setStartTime(request.getStartTime());
        shift.setEndTime(request.getEndTime());

        double hours = ChronoUnit.HOURS.between(request.getStartTime(), request.getEndTime());
        shift.setTotalHours(hours);

        shift.setDescription(request.getDescription());
        shift.setOvertimeRate(request.getOvertimeRate());

        Shift updatedShift = shiftRepository.save(shift);
        return mapToShiftResponse(updatedShift);
    }

    @Override
    @Transactional
    public void deleteShift(Long id) {
        if (!shiftRepository.existsById(id)) {
            throw new RuntimeException("Shift not found with id: " + id);
        }
        shiftRepository.deleteById(id);
    }

    @Override
    @Transactional
    public ShiftResponse assignShift(AssignShiftRequest request) {
        Employee employee = employeeRepository.findById(request.getEmployeeId())
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        employee.setShiftId(request.getShiftId());
        employeeRepository.save(employee);

        return getShiftById(request.getShiftId());
    }

    @Override
    public List<EmployeeResponse> getEmployeesByShift(Long shiftId) {
        return employeeRepository.findByShiftId(shiftId)
                .stream()
                .map(this::mapToEmployeeResponse)
                .collect(Collectors.toList());
    }

    // ========== Payroll Management ==========

    @Override
    @Transactional
    public List<PayrollResponse> generatePayroll(GeneratePayrollRequest request) {
        List<Employee> employees;

        if (request.getEmployeeId() != null) {
            employees = List.of(employeeRepository.findById(request.getEmployeeId())
                    .orElseThrow(() -> new RuntimeException("Employee not found")));
        } else if (request.getDepartmentId() != null) {
            employees = employeeRepository.findByDepartmentId(request.getDepartmentId());
        } else {
            employees = employeeRepository.findAll();
        }

        List<Payroll> generatedPayrolls = employees.stream()
                .map(employee -> createPayrollForEmployee(employee, request.getMonth(), request.getGeneratedBy()))
                .collect(Collectors.toList());

        return generatedPayrolls.stream()
                .map(this::mapToPayrollResponse)
                .collect(Collectors.toList());
    }

    private Payroll createPayrollForEmployee(Employee employee, YearMonth month, String generatedBy) {
        // Check if payroll already exists
        payrollRepository.findByEmployeeIdAndMonth(employee.getId(), month)
                .ifPresent(p -> {
                    throw new RuntimeException("Payroll already exists for employee: " + employee.getEmployeeId());
                });

        Payroll payroll = new Payroll();
        payroll.setEmployee(employee);
        payroll.setMonth(month);
        payroll.setGeneratedDate(LocalDate.now());
        payroll.setGeneratedBy(generatedBy);
        payroll.setStatus("GENERATED");

        // Set salary components
        payroll.setBasicSalary(employee.getBasicSalary());
        payroll.setHouseRent(employee.getHouseRent());
        payroll.setMedicalAllowance(employee.getMedicalAllowance());
        payroll.setConveyanceAllowance(employee.getConveyanceAllowance());

        // Calculate gross salary
        double grossSalary = (employee.getBasicSalary() != null ? employee.getBasicSalary() : 0) +
                (employee.getHouseRent() != null ? employee.getHouseRent() : 0) +
                (employee.getMedicalAllowance() != null ? employee.getMedicalAllowance() : 0) +
                (employee.getConveyanceAllowance() != null ? employee.getConveyanceAllowance() : 0);
        payroll.setGrossSalary(grossSalary);

        // Calculate days
        LocalDate startDate = month.atDay(1);
        LocalDate endDate = month.atEndOfMonth();

        long presentDays = attendanceRepository.countPresentDays(employee.getId(), startDate, endDate);
        payroll.setDaysPresent((int) presentDays);

        // Get approved leave days
        Integer leaveDays = leaveRepository.getTotalApprovedLeaveDays(employee.getId(), month.getYear());
        payroll.setDaysLeave(leaveDays != null ? leaveDays : 0);

        // Calculate overtime
        Double overtimeHours = attendanceRepository.sumOvertimeHours(employee.getId(), startDate, endDate);
        payroll.setOvertimeHours(overtimeHours != null ? overtimeHours.intValue() : 0);

        // Calculate net salary (simplified)
        payroll.setNetSalary(grossSalary);

        return payrollRepository.save(payroll);
    }

    @Override
    public List<PayrollResponse> getPayrollByMonth(YearMonth month, Long hotelId) {
        return payrollRepository.findByMonth(month)
                .stream()
                .filter(p -> hotelId == null ||
                        (p.getEmployee().getHotel() != null && p.getEmployee().getHotel().getId().equals(hotelId)))
                .map(this::mapToPayrollResponse)
                .collect(Collectors.toList());
    }

    @Override
    public PayrollResponse getEmployeePayroll(Long employeeId, YearMonth month) {
        Payroll payroll = payrollRepository.findByEmployeeIdAndMonth(employeeId, month)
                .orElseThrow(() -> new RuntimeException("Payroll not found"));
        return mapToPayrollResponse(payroll);
    }

    @Override
    public List<PayrollResponse> getEmployeePayrollHistory(Long employeeId) {
        return payrollRepository.findByEmployeeId(employeeId)
                .stream()
                .map(this::mapToPayrollResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public PayrollResponse updatePayrollStatus(Long id, String status, String approvedBy) {
        Payroll payroll = payrollRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Payroll not found"));

        payroll.setStatus(status);
        if ("PAID".equals(status)) {
            payroll.setPaymentDate(LocalDate.now());
            payroll.setApprovedBy(approvedBy);
            payroll.setApprovedDate(LocalDate.now());
        }

        Payroll updatedPayroll = payrollRepository.save(payroll);
        return mapToPayrollResponse(updatedPayroll);
    }

    @Override
    @Transactional
    public PayrollResponse processPayment(Long id, String paymentMethod, String transactionId) {
        Payroll payroll = payrollRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Payroll not found"));

        payroll.setPaymentMethod(paymentMethod);
        payroll.setTransactionId(transactionId);
        payroll.setStatus("PAID");
        payroll.setPaymentDate(LocalDate.now());

        Payroll updatedPayroll = payrollRepository.save(payroll);
        return mapToPayrollResponse(updatedPayroll);
    }

    @Override
    public Double getTotalPayrollByMonth(YearMonth month, Long hotelId) {
        if (hotelId != null) {
            return payrollRepository.getTotalPayrollByMonthAndDepartment(month, hotelId);
        }
        return payrollRepository.getTotalPayrollByMonth(month);
    }

    // ========== Reports & Statistics ==========

    @Override
    public Integer getTotalEmployeesCount(Long hotelId) {
        if (hotelId != null) {
            return employeeRepository.findByHotelId(hotelId).size();
        }
        return (int) employeeRepository.count();
    }

    @Override
    public Integer getActiveEmployeesCount(Long hotelId) {
        return (int) employeeRepository.findByIsActiveTrue()
                .stream()
                .filter(e -> hotelId == null ||
                        (e.getHotel() != null && e.getHotel().getId().equals(hotelId)))
                .count();
    }

    @Override
    public Integer getTodayPresentCount(Long hotelId) {
        return (int) attendanceRepository.findByDate(LocalDate.now())
                .stream()
                .filter(a -> a.getStatus().equals("PRESENT"))
                .filter(a -> hotelId == null ||
                        (a.getEmployee().getHotel() != null && a.getEmployee().getHotel().getId().equals(hotelId)))
                .count();
    }

    @Override
    public Integer getTodayAbsentCount(Long hotelId) {
        return (int) attendanceRepository.findByDate(LocalDate.now())
                .stream()
                .filter(a -> a.getStatus().equals("ABSENT"))
                .filter(a -> hotelId == null ||
                        (a.getEmployee().getHotel() != null && a.getEmployee().getHotel().getId().equals(hotelId)))
                .count();
    }

    @Override
    public Integer getTodayLeaveCount(Long hotelId) {
        return (int) attendanceRepository.findByDate(LocalDate.now())
                .stream()
                .filter(a -> a.getStatus().equals("ON_LEAVE"))
                .filter(a -> hotelId == null ||
                        (a.getEmployee().getHotel() != null && a.getEmployee().getHotel().getId().equals(hotelId)))
                .count();
    }

    @Override
    public Integer getPendingLeaveCount(Long hotelId) {
        return (int) leaveRepository.findByStatus("PENDING")
                .stream()
                .filter(l -> hotelId == null ||
                        (l.getEmployee().getHotel() != null && l.getEmployee().getHotel().getId().equals(hotelId)))
                .count();
    }

    @Override
    public Double getMonthlyPayrollTotal(YearMonth month, Long hotelId) {
        return getTotalPayrollByMonth(month, hotelId);
    }

    // ========== Private Helper Methods ==========

    private DepartmentResponse mapToDepartmentResponse(Department department) {
        Long employeeCount = employeeRepository.countActiveByDepartment(department.getId());

        return DepartmentResponse.builder()
                .id(department.getId())
                .name(department.getName())
                .description(department.getDescription())
                .headOfDepartment(department.getHeadOfDepartment())
                .headEmployeeId(department.getHeadEmployeeId())
                .location(department.getLocation())
                .contactNumber(department.getContactNumber())
                .email(department.getEmail())
                .totalEmployees(employeeCount != null ? employeeCount.intValue() : 0)
                .isActive(department.getIsActive())
                .hotelId(department.getHotelId())
                .createdAt(department.getCreatedAt())
                .updatedAt(department.getUpdatedAt())
                .build();
    }

    private EmployeeResponse mapToEmployeeResponse(Employee employee) {
        String fullName = employee.getFirstName() + " " + employee.getLastName();
        int age = employee.getDateOfBirth() != null ?
                LocalDate.now().getYear() - employee.getDateOfBirth().getYear() : 0;

        return EmployeeResponse.builder()
                .id(employee.getId())
                .employeeId(employee.getEmployeeId())
                .userId(employee.getUser() != null ? employee.getUser().getId() : null)
                .username(employee.getUser() != null ? employee.getUser().getUsername() : null)
                .departmentId(employee.getDepartment() != null ? employee.getDepartment().getId() : null)
                .departmentName(employee.getDepartment() != null ? employee.getDepartment().getName() : null)
                .position(employee.getPosition())
                .joiningDate(employee.getJoiningDate())
                .contractEndDate(employee.getContractEndDate())
                .employmentType(employee.getEmploymentType())
                .employmentStatus(employee.getEmploymentStatus())
                .basicSalary(employee.getBasicSalary())
                .houseRent(employee.getHouseRent())
                .medicalAllowance(employee.getMedicalAllowance())
                .conveyanceAllowance(employee.getConveyanceAllowance())
                .otherAllowances(employee.getOtherAllowances())
                .totalSalary(employee.getTotalSalary())
                .firstName(employee.getFirstName())
                .lastName(employee.getLastName())
                .fullName(fullName)
                .email(employee.getEmail())
                .phone(employee.getPhone())
                .alternativePhone(employee.getAlternativePhone())
                .emergencyContact(employee.getEmergencyContact())
                .emergencyPhone(employee.getEmergencyPhone())
                .address(employee.getAddress())
                .city(employee.getCity())
                .state(employee.getState())
                .country(employee.getCountry())
                .postalCode(employee.getPostalCode())
                .dateOfBirth(employee.getDateOfBirth())
                .gender(employee.getGender())
                .maritalStatus(employee.getMaritalStatus())
                .nationality(employee.getNationality())
                .age(age)
                .nidNumber(employee.getNidNumber())
                .passportNumber(employee.getPassportNumber())
                .drivingLicense(employee.getDrivingLicense())
                .bankName(employee.getBankName())
                .bankAccountNo(employee.getBankAccountNo())
                .bankBranch(employee.getBankBranch())
                .routingNo(employee.getRoutingNo())
                .qualification(employee.getQualification())
                .experience(employee.getExperience())
                .skills(employee.getSkills())
                .profileImageUrl(employee.getProfileImageUrl())
                .shift(employee.getShift())
                .shiftId(employee.getShiftId())
                .reportingTo(employee.getReportingTo())
                .reportingManagerId(employee.getReportingManagerId())
                .bloodGroup(employee.getBloodGroup())
                .religion(employee.getReligion())
                .remarks(employee.getRemarks())
                .isActive(employee.getIsActive())
                .hotelId(employee.getHotel() != null ? employee.getHotel().getId() : null)
                .createdAt(employee.getCreatedAt())
                .updatedAt(employee.getUpdatedAt())
                .build();
    }

    private AttendanceResponse mapToAttendanceResponse(Attendance attendance) {
        return AttendanceResponse.builder()
                .id(attendance.getId())
                .employeeId(attendance.getEmployee().getId())
                .employeeName(attendance.getEmployee().getFirstName() + " " + attendance.getEmployee().getLastName())
                .employeeIdNumber(attendance.getEmployee().getEmployeeId())
                .department(attendance.getEmployee().getDepartment() != null ?
                        attendance.getEmployee().getDepartment().getName() : null)
                .date(attendance.getDate())
                .checkInTime(attendance.getCheckInTime())
                .checkOutTime(attendance.getCheckOutTime())
                .status(attendance.getStatus())
                .workingHours(attendance.getWorkingHours())
                .overtimeHours(attendance.getOvertimeHours())
                .remarks(attendance.getRemarks())
                .markedBy(attendance.getMarkedBy())
                .markedAt(attendance.getMarkedAt())
                .isApproved(attendance.getIsApproved())
                .approvedBy(attendance.getApprovedBy())
                .approvedAt(attendance.getApprovedAt())
                .build();
    }

    private LeaveResponse mapToLeaveResponse(Leave leave) {
        return LeaveResponse.builder()
                .id(leave.getId())
                .employeeId(leave.getEmployee().getId())
                .employeeName(leave.getEmployee().getFirstName() + " " + leave.getEmployee().getLastName())
                .employeeIdNumber(leave.getEmployee().getEmployeeId())
                .department(leave.getEmployee().getDepartment() != null ?
                        leave.getEmployee().getDepartment().getName() : null)
                .leaveType(leave.getLeaveType())
                .startDate(leave.getStartDate())
                .endDate(leave.getEndDate())
                .totalDays(leave.getTotalDays())
                .reason(leave.getReason())
                .status(leave.getStatus())
                .appliedBy(leave.getAppliedBy())
                .appliedDate(leave.getAppliedDate())
                .approvedBy(leave.getApprovedBy())
                .approvedDate(leave.getApprovedDate())
                .rejectionReason(leave.getRejectionReason())
                .documents(leave.getDocuments())
                .contactDuringLeave(leave.getContactDuringLeave())
                .handoverNotes(leave.getHandoverNotes())
                .isPaid(leave.getIsPaid())
                .build();
    }

    private ShiftResponse mapToShiftResponse(Shift shift) {
        Long employeeCount = (long) employeeRepository.findByShiftId(shift.getId()).size();

        return ShiftResponse.builder()
                .id(shift.getId())
                .name(shift.getName())
                .startTime(shift.getStartTime())
                .endTime(shift.getEndTime())
                .totalHours(shift.getTotalHours())
                .description(shift.getDescription())
                .overtimeRate(shift.getOvertimeRate())
                .isActive(shift.getIsActive())
                .hotelId(shift.getHotelId())
                .assignedEmployees(employeeCount.intValue())
                .createdAt(shift.getCreatedAt())
                .updatedAt(shift.getUpdatedAt())
                .build();
    }

    private PayrollResponse mapToPayrollResponse(Payroll payroll) {
        return PayrollResponse.builder()
                .id(payroll.getId())
                .employeeId(payroll.getEmployee().getId())
                .employeeName(payroll.getEmployee().getFirstName() + " " + payroll.getEmployee().getLastName())
                .employeeIdNumber(payroll.getEmployee().getEmployeeId())
                .department(payroll.getEmployee().getDepartment() != null ?
                        payroll.getEmployee().getDepartment().getName() : null)
                .position(payroll.getEmployee().getPosition())
                .month(payroll.getMonth())
                .generatedDate(payroll.getGeneratedDate())
                .paymentDate(payroll.getPaymentDate())
                .basicSalary(payroll.getBasicSalary())
                .houseRent(payroll.getHouseRent())
                .medicalAllowance(payroll.getMedicalAllowance())
                .conveyanceAllowance(payroll.getConveyanceAllowance())
                .overtimeAmount(payroll.getOvertimeAmount())
                .bonus(payroll.getBonus())
                .otherEarnings(payroll.getOtherEarnings())
                .grossSalary(payroll.getGrossSalary())
                .taxDeduction(payroll.getTaxDeduction())
                .providentFund(payroll.getProvidentFund())
                .loanDeduction(payroll.getLoanDeduction())
                .insuranceDeduction(payroll.getInsuranceDeduction())
                .otherDeductions(payroll.getOtherDeductions())
                .totalDeductions(payroll.getTotalDeductions())
                .netSalary(payroll.getNetSalary())
                .totalWorkingDays(payroll.getTotalWorkingDays())
                .daysPresent(payroll.getDaysPresent())
                .daysAbsent(payroll.getDaysAbsent())
                .daysLeave(payroll.getDaysLeave())
                .overtimeHours(payroll.getOvertimeHours())
                .status(payroll.getStatus())
                .paymentMethod(payroll.getPaymentMethod())
                .bankAccountNo(payroll.getBankAccountNo())
                .transactionId(payroll.getTransactionId())
                .notes(payroll.getNotes())
                .generatedBy(payroll.getGeneratedBy())
                .approvedBy(payroll.getApprovedBy())
                .approvedDate(payroll.getApprovedDate())
                .build();
    }

    @Override
    @Transactional
    public LeaveResponse updateLeaveStatus(Long id, String status, String rejectionReason) {
        Leave leave = leaveRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Leave not found"));

        leave.setStatus(status);
        if ("REJECTED".equals(status) && rejectionReason != null) {
            leave.setRejectionReason(rejectionReason);
        }
        leave.setApprovedBy(getCurrentUser());
        leave.setApprovedDate(LocalDate.now());

        Leave updatedLeave = leaveRepository.save(leave);
        return mapToLeaveResponse(updatedLeave);
    }

    private String getCurrentUser() {
        return "ADMIN";
    }

}