package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeRepository extends JpaRepository<Employee, Long> {

    Optional<Employee> findByUserId(Long userId);

    Optional<Employee> findByEmployeeId(String employeeId);

    List<Employee> findByDepartmentId(Long departmentId);

    List<Employee> findByEmploymentType(String employmentType);

    List<Employee> findByEmploymentStatus(String status);

    List<Employee> findByHotelId(Long hotelId);

    List<Employee> findByIsActiveTrue();

    @Query("SELECT e FROM Employee e WHERE LOWER(e.firstName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR LOWER(e.lastName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR LOWER(e.email) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR e.employeeId LIKE CONCAT('%', :searchTerm, '%')")
    List<Employee> searchEmployees(@Param("searchTerm") String searchTerm);

    boolean existsByEmployeeId(String employeeId);

    boolean existsByEmail(String email);

    @Query("SELECT COUNT(e) FROM Employee e WHERE e.department.id = :departmentId AND e.isActive = true")
    Long countActiveByDepartment(@Param("departmentId") Long departmentId);

    @Query("SELECT e FROM Employee e WHERE e.shiftId = :shiftId")
    List<Employee> findByShiftId(@Param("shiftId") Long shiftId);
}