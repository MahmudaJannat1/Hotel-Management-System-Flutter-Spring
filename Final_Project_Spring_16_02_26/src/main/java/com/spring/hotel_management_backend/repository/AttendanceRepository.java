package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface AttendanceRepository extends JpaRepository<Attendance, Long> {

    Optional<Attendance> findByEmployeeIdAndDate(Long employeeId, LocalDate date);

    List<Attendance> findByEmployeeId(Long employeeId);

    List<Attendance> findByDate(LocalDate date);

    @Query("SELECT a FROM Attendance a WHERE a.employee.id = :employeeId AND a.date BETWEEN :startDate AND :endDate")
    List<Attendance> findByEmployeeIdAndDateRange(@Param("employeeId") Long employeeId,
                                                  @Param("startDate") LocalDate startDate,
                                                  @Param("endDate") LocalDate endDate);

    @Query("SELECT a FROM Attendance a WHERE a.date BETWEEN :startDate AND :endDate")
    List<Attendance> findByDateRange(@Param("startDate") LocalDate startDate,
                                     @Param("endDate") LocalDate endDate);

    @Query("SELECT a FROM Attendance a WHERE a.employee.department.id = :departmentId AND a.date = :date")
    List<Attendance> findByDepartmentAndDate(@Param("departmentId") Long departmentId,
                                             @Param("date") LocalDate date);

    @Query("SELECT COUNT(a) FROM Attendance a WHERE a.employee.id = :employeeId AND a.date BETWEEN :startDate AND :endDate AND a.status = 'PRESENT'")
    Long countPresentDays(@Param("employeeId") Long employeeId,
                          @Param("startDate") LocalDate startDate,
                          @Param("endDate") LocalDate endDate);

    @Query("SELECT SUM(a.overtimeHours) FROM Attendance a WHERE a.employee.id = :employeeId AND a.date BETWEEN :startDate AND :endDate")
    Double sumOvertimeHours(@Param("employeeId") Long employeeId,
                            @Param("startDate") LocalDate startDate,
                            @Param("endDate") LocalDate endDate);

    @Query("SELECT a FROM Attendance a WHERE a.date BETWEEN :startDate AND :endDate AND a.employee.hotel.id = :hotelId")
    List<Attendance> findByDateRangeAndHotel(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate,
            @Param("hotelId") Long hotelId);
}