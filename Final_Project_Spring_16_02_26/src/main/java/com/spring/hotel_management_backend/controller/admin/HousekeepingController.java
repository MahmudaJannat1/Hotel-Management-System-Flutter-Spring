package com.spring.hotel_management_backend.controller.admin;

import com.spring.hotel_management_backend.model.dto.request.admin.housekeeping.*;
import com.spring.hotel_management_backend.model.dto.response.admin.housekeeping.*;
import com.spring.hotel_management_backend.service.admin.HousekeepingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/housekeeping")
@RequiredArgsConstructor
@Tag(name = "Housekeeping", description = "Admin housekeeping management APIs")
@SecurityRequirement(name = "Bearer Authentication")
public class HousekeepingController {

    private final HousekeepingService housekeepingService;

    // ========== Task Endpoints ==========

    @PostMapping("/tasks")
    @Operation(summary = "Create new housekeeping task")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<TaskResponse> createTask(@RequestBody CreateTaskRequest request) {
        return new ResponseEntity<>(housekeepingService.createTask(request), HttpStatus.CREATED);
    }

    @GetMapping("/tasks")
    @Operation(summary = "Get all tasks")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<TaskResponse>> getAllTasks(@RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(housekeepingService.getAllTasks(hotelId));
    }

    @GetMapping("/tasks/{id}")
    @Operation(summary = "Get task by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<TaskResponse> getTaskById(@PathVariable Long id) {
        return ResponseEntity.ok(housekeepingService.getTaskById(id));
    }

    @GetMapping("/tasks/room/{roomId}")
    @Operation(summary = "Get tasks by room")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<TaskResponse>> getTasksByRoom(@PathVariable Long roomId) {
        return ResponseEntity.ok(housekeepingService.getTasksByRoom(roomId));
    }

    @GetMapping("/tasks/employee/{employeeId}")
    @Operation(summary = "Get tasks by employee")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<TaskResponse>> getTasksByEmployee(@PathVariable Long employeeId) {
        return ResponseEntity.ok(housekeepingService.getTasksByEmployee(employeeId));
    }

    @GetMapping("/tasks/status/{status}")
    @Operation(summary = "Get tasks by status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<TaskResponse>> getTasksByStatus(@PathVariable String status) {
        return ResponseEntity.ok(housekeepingService.getTasksByStatus(status));
    }

    @GetMapping("/tasks/today")
    @Operation(summary = "Get today's tasks")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<TaskResponse>> getTodaysTasks() {
        return ResponseEntity.ok(housekeepingService.getTodaysTasks());
    }

    @GetMapping("/tasks/pending")
    @Operation(summary = "Get pending tasks")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<TaskResponse>> getPendingTasks() {
        return ResponseEntity.ok(housekeepingService.getPendingTasks());
    }

    @PutMapping("/tasks/{id}/status")
    @Operation(summary = "Update task status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<TaskResponse> updateTaskStatus(
            @PathVariable Long id,
            @RequestBody UpdateTaskStatusRequest request) {
        return ResponseEntity.ok(housekeepingService.updateTaskStatus(id, request));
    }

    @DeleteMapping("/tasks/{id}")
    @Operation(summary = "Delete task")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteTask(@PathVariable Long id) {
        housekeepingService.deleteTask(id);
        return ResponseEntity.noContent().build();
    }

    // ========== Maintenance Endpoints ==========

    @PostMapping("/maintenance")
    @Operation(summary = "Create maintenance request")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MaintenanceResponse> createMaintenanceRequest(@RequestBody CreateMaintenanceRequest request) {
        return new ResponseEntity<>(housekeepingService.createMaintenanceRequest(request), HttpStatus.CREATED);
    }

    @GetMapping("/maintenance")
    @Operation(summary = "Get all maintenance requests")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<MaintenanceResponse>> getAllMaintenanceRequests(
            @RequestParam(required = false) Long hotelId) {
        return ResponseEntity.ok(housekeepingService.getAllMaintenanceRequests(hotelId));
    }

    @GetMapping("/maintenance/{id}")
    @Operation(summary = "Get maintenance request by ID")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MaintenanceResponse> getMaintenanceRequestById(@PathVariable Long id) {
        return ResponseEntity.ok(housekeepingService.getMaintenanceRequestById(id));
    }

    @GetMapping("/maintenance/room/{roomId}")
    @Operation(summary = "Get maintenance by room")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<MaintenanceResponse>> getMaintenanceByRoom(@PathVariable Long roomId) {
        return ResponseEntity.ok(housekeepingService.getMaintenanceByRoom(roomId));
    }

    @GetMapping("/maintenance/status/{status}")
    @Operation(summary = "Get maintenance by status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<MaintenanceResponse>> getMaintenanceByStatus(@PathVariable String status) {
        return ResponseEntity.ok(housekeepingService.getMaintenanceByStatus(status));
    }

    @GetMapping("/maintenance/critical")
    @Operation(summary = "Get critical maintenance requests")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<MaintenanceResponse>> getCriticalRequests() {
        return ResponseEntity.ok(housekeepingService.getCriticalRequests());
    }

    @GetMapping("/maintenance/pending")
    @Operation(summary = "Get pending maintenance requests")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<MaintenanceResponse>> getPendingRequests() {
        return ResponseEntity.ok(housekeepingService.getPendingRequests());
    }

    @PutMapping("/maintenance/{id}/status")
    @Operation(summary = "Update maintenance status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MaintenanceResponse> updateMaintenanceStatus(
            @PathVariable Long id,
            @RequestBody UpdateMaintenanceStatusRequest request) {
        return ResponseEntity.ok(housekeepingService.updateMaintenanceStatus(id, request));
    }

    @DeleteMapping("/maintenance/{id}")
    @Operation(summary = "Delete maintenance request")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteMaintenanceRequest(@PathVariable Long id) {
        housekeepingService.deleteMaintenanceRequest(id);
        return ResponseEntity.noContent().build();
    }

    // ========== Statistics Endpoints ==========

    @GetMapping("/statistics/pending-tasks")
    @Operation(summary = "Get pending task count")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Long> getPendingTaskCount() {
        return ResponseEntity.ok(housekeepingService.getPendingTaskCount());
    }

    @GetMapping("/statistics/pending-maintenance")
    @Operation(summary = "Get pending maintenance count")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Long> getPendingMaintenanceCount() {
        return ResponseEntity.ok(housekeepingService.getPendingMaintenanceCount());
    }

    @GetMapping("/statistics/critical-maintenance")
    @Operation(summary = "Get critical maintenance count")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Long> getCriticalMaintenanceCount() {
        return ResponseEntity.ok(housekeepingService.getCriticalMaintenanceCount());
    }
}