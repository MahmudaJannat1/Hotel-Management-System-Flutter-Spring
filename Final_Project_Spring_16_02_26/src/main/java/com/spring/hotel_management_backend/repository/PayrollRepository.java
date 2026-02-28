package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Payroll;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.YearMonth;
import java.util.List;
import java.util.Optional;

@Repository
public interface PayrollRepository extends JpaRepository<Payroll, Long> {

    Optional<Payroll> findByEmployeeIdAndMonth(Long employeeId, YearMonth month);

    List<Payroll> findByMonth(YearMonth month);

    List<Payroll> findByEmployeeId(Long employeeId);

    @Query("SELECT p FROM Payroll p WHERE p.month = :month AND p.employee.department.id = :departmentId")
    List<Payroll> findByMonthAndDepartment(@Param("month") YearMonth month,
                                           @Param("departmentId") Long departmentId);

    @Query("SELECT p FROM Payroll p WHERE p.employee.id = :employeeId AND p.month BETWEEN :startMonth AND :endMonth")
    List<Payroll> findByEmployeeIdAndMonthRange(@Param("employeeId") Long employeeId,
                                                @Param("startMonth") YearMonth startMonth,
                                                @Param("endMonth") YearMonth endMonth);

    List<Payroll> findByStatus(String status);

    @Query("SELECT SUM(p.netSalary) FROM Payroll p WHERE p.month = :month")
    Double getTotalPayrollByMonth(@Param("month") YearMonth month);

    @Query("SELECT SUM(p.netSalary) FROM Payroll p WHERE p.month = :month AND p.employee.department.id = :departmentId")
    Double getTotalPayrollByMonthAndDepartment(@Param("month") YearMonth month,
                                               @Param("departmentId") Long departmentId);
}