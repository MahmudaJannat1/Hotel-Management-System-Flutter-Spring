package com.spring.hotel_management_backend.service.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.housekeeping.*;
import com.spring.hotel_management_backend.model.dto.response.admin.housekeeping.*;
import java.time.LocalDate;
import java.util.List;

public interface HousekeepingService {

    // ========== Task Management ==========
    TaskResponse createTask(CreateTaskRequest request);
    List<TaskResponse> getAllTasks(Long hotelId);
    TaskResponse getTaskById(Long id);
    List<TaskResponse> getTasksByRoom(Long roomId);
    List<TaskResponse> getTasksByEmployee(Long employeeId);
    List<TaskResponse> getTasksByStatus(String status);
    List<TaskResponse> getTodaysTasks();
    List<TaskResponse> getPendingTasks();
    TaskResponse updateTaskStatus(Long id, UpdateTaskStatusRequest request);
    void deleteTask(Long id);

    // ========== Maintenance Management ==========
    MaintenanceResponse createMaintenanceRequest(CreateMaintenanceRequest request);
    List<MaintenanceResponse> getAllMaintenanceRequests(Long hotelId);
    MaintenanceResponse getMaintenanceRequestById(Long id);
    List<MaintenanceResponse> getMaintenanceByRoom(Long roomId);
    List<MaintenanceResponse> getMaintenanceByStatus(String status);
    List<MaintenanceResponse> getCriticalRequests();
    List<MaintenanceResponse> getPendingRequests();
    MaintenanceResponse updateMaintenanceStatus(Long id, UpdateMaintenanceStatusRequest request);
    void deleteMaintenanceRequest(Long id);

    // ========== Statistics ==========
    Long getPendingTaskCount();
    Long getPendingMaintenanceCount();
    Long getCriticalMaintenanceCount();
}