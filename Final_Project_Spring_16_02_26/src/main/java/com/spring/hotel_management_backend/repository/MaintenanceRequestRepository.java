package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.MaintenanceRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MaintenanceRequestRepository extends JpaRepository<MaintenanceRequest, Long> {

    List<MaintenanceRequest> findByRoomId(Long roomId);

    List<MaintenanceRequest> findByAssignedToId(Long employeeId);

    List<MaintenanceRequest> findByStatus(String status);

    List<MaintenanceRequest> findByPriority(String priority);

    @Query("SELECT r FROM MaintenanceRequest r WHERE r.status NOT IN ('COMPLETED', 'CANCELLED')")
    List<MaintenanceRequest> findPendingRequests();

    @Query("SELECT r FROM MaintenanceRequest r WHERE r.priority = 'CRITICAL' AND r.status NOT IN ('COMPLETED', 'CANCELLED')")
    List<MaintenanceRequest> findCriticalRequests();

    @Query("SELECT COUNT(r) FROM MaintenanceRequest r WHERE r.status = 'REPORTED'")
    Long countPendingRequests();
}