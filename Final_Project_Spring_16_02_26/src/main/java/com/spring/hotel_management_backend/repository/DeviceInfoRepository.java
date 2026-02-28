package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.DeviceInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DeviceInfoRepository extends JpaRepository<DeviceInfo, Long> {
    Optional<DeviceInfo> findByUserIdAndDeviceId(Long userId, String deviceId);
}