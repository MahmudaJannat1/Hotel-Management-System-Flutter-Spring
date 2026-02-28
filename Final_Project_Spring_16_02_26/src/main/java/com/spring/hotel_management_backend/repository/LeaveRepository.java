package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Leave;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface LeaveRepository extends JpaRepository<Leave, Long> {

    List<Leave> findByEmployeeId(Long employeeId);

    List<Leave> findByStatus(String status);

    @Query("SELECT l FROM Leave l WHERE l.employee.id = :employeeId AND l.status = :status")
    List<Leave> findByEmployeeIdAndStatus(@Param("employeeId") Long employeeId,
                                          @Param("status") String status);

    @Query("SELECT l FROM Leave l WHERE l.startDate <= :endDate AND l.endDate >= :startDate")
    List<Leave> findLeavesInDateRange(@Param("startDate") LocalDate startDate,
                                      @Param("endDate") LocalDate endDate);

    @Query("SELECT l FROM Leave l WHERE l.employee.department.id = :departmentId AND l.status = 'PENDING'")
    List<Leave> findPendingLeavesByDepartment(@Param("departmentId") Long departmentId);

    @Query("SELECT SUM(l.totalDays) FROM Leave l WHERE l.employee.id = :employeeId AND l.status = 'APPROVED' AND YEAR(l.startDate) = :year")
    Integer getTotalApprovedLeaveDays(@Param("employeeId") Long employeeId,
                                      @Param("year") Integer year);
}