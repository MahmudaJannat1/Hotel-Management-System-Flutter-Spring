package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.SyncLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface SyncLogRepository extends JpaRepository<SyncLog, Long> {

    SyncLog findTopByUserIdAndDeviceIdOrderByRequestTimeDesc(Long userId, String deviceId);

    @Query("SELECT COUNT(s) FROM SyncLog s WHERE s.userId = ?1 AND s.deviceId = ?2 AND s.status = 'PENDING'")
    Long countPendingByUserIdAndDeviceId(Long userId, String deviceId);
}