package com.spring.hotel_management_backend.service.admin.impl;

import com.spring.hotel_management_backend.model.dto.request.admin.housekeeping.*;
import com.spring.hotel_management_backend.model.dto.response.admin.housekeeping.*;
import com.spring.hotel_management_backend.model.entity.*;
import com.spring.hotel_management_backend.repository.*;
import com.spring.hotel_management_backend.service.admin.HousekeepingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class HousekeepingServiceImpl implements HousekeepingService {

    private final HousekeepingTaskRepository taskRepository;
    private final MaintenanceRequestRepository maintenanceRepository;
    private final RoomRepository roomRepository;
    private final EmployeeRepository employeeRepository;

    // ========== Task Management ==========

    @Override
    @Transactional
    public TaskResponse createTask(CreateTaskRequest request) {
        Room room = roomRepository.findById(request.getRoomId())
                .orElseThrow(() -> new RuntimeException("Room not found"));

        HousekeepingTask task = new HousekeepingTask();
        task.setRoom(room);
        task.setTaskType(request.getTaskType());
        task.setPriority(request.getPriority());
        task.setStatus("PENDING");
        task.setScheduledDate(request.getScheduledDate());
        task.setNotes(request.getNotes());
        task.setHotelId(room.getHotel().getId());

        if (request.getAssignedToId() != null) {
            Employee employee = employeeRepository.findById(request.getAssignedToId())
                    .orElseThrow(() -> new RuntimeException("Employee not found"));
            task.setAssignedTo(employee);
            task.setStatus("ASSIGNED");
            task.setAssignedAt(LocalDateTime.now());
        }

        HousekeepingTask savedTask = taskRepository.save(task);
        return mapToTaskResponse(savedTask);
    }

    @Override
    public List<TaskResponse> getAllTasks(Long hotelId) {
        return taskRepository.findAll()
                .stream()
                .filter(t -> hotelId == null || t.getHotelId().equals(hotelId))
                .map(this::mapToTaskResponse)
                .collect(Collectors.toList());
    }

    @Override
    public TaskResponse getTaskById(Long id) {
        HousekeepingTask task = taskRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Task not found"));
        return mapToTaskResponse(task);
    }

    @Override
    public List<TaskResponse> getTasksByRoom(Long roomId) {
        return taskRepository.findByRoomId(roomId)
                .stream()
                .map(this::mapToTaskResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskResponse> getTasksByEmployee(Long employeeId) {
        return taskRepository.findByAssignedToId(employeeId)
                .stream()
                .map(this::mapToTaskResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskResponse> getTasksByStatus(String status) {
        return taskRepository.findByStatus(status)
                .stream()
                .map(this::mapToTaskResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskResponse> getTodaysTasks() {
        return taskRepository.findTodaysPendingTasks(LocalDate.now())
                .stream()
                .map(this::mapToTaskResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskResponse> getPendingTasks() {
        return taskRepository.findPendingTasks()
                .stream()
                .map(this::mapToTaskResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public TaskResponse updateTaskStatus(Long id, UpdateTaskStatusRequest request) {
        HousekeepingTask task = taskRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Task not found"));

        task.setStatus(request.getStatus());

        switch (request.getStatus()) {
            case "ASSIGNED":
                if (request.getAssignedToId() != null) {
                    Employee employee = employeeRepository.findById(request.getAssignedToId())
                            .orElseThrow(() -> new RuntimeException("Employee not found"));
                    task.setAssignedTo(employee);
                    task.setAssignedAt(LocalDateTime.now());
                }
                break;
            case "IN_PROGRESS":
                task.setStartedAt(LocalDateTime.now());
                break;
            case "COMPLETED":
                task.setCompletedAt(LocalDateTime.now());
                task.setCompletionNotes(request.getCompletionNotes());
                break;
            case "VERIFIED":
                task.setVerifiedBy(request.getVerifiedBy());
                task.setVerifiedAt(LocalDateTime.now());
                break;
        }

        HousekeepingTask updatedTask = taskRepository.save(task);
        return mapToTaskResponse(updatedTask);
    }

    @Override
    @Transactional
    public void deleteTask(Long id) {
        if (!taskRepository.existsById(id)) {
            throw new RuntimeException("Task not found");
        }
        taskRepository.deleteById(id);
    }

    // ========== Maintenance Management ==========

    @Override
    @Transactional
    public MaintenanceResponse createMaintenanceRequest(CreateMaintenanceRequest request) {
        Room room = roomRepository.findById(request.getRoomId())
                .orElseThrow(() -> new RuntimeException("Room not found"));

        Employee reporter = employeeRepository.findById(request.getReportedById())
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        MaintenanceRequest maintenance = new MaintenanceRequest();
        maintenance.setRoom(room);
        maintenance.setIssueType(request.getIssueType());
        maintenance.setPriority(request.getPriority());
        maintenance.setStatus("REPORTED");
        maintenance.setDescription(request.getDescription());
        maintenance.setReportedBy(reporter);
        maintenance.setReportedAt(LocalDateTime.now());
        maintenance.setNotes(request.getNotes());
        maintenance.setHotelId(room.getHotel().getId());

        MaintenanceRequest savedRequest = maintenanceRepository.save(maintenance);
        return mapToMaintenanceResponse(savedRequest);
    }

    @Override
    public List<MaintenanceResponse> getAllMaintenanceRequests(Long hotelId) {
        return maintenanceRepository.findAll()
                .stream()
                .filter(m -> hotelId == null || m.getHotelId().equals(hotelId))
                .map(this::mapToMaintenanceResponse)
                .collect(Collectors.toList());
    }

    @Override
    public MaintenanceResponse getMaintenanceRequestById(Long id) {
        MaintenanceRequest request = maintenanceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Maintenance request not found"));
        return mapToMaintenanceResponse(request);
    }

    @Override
    public List<MaintenanceResponse> getMaintenanceByRoom(Long roomId) {
        return maintenanceRepository.findByRoomId(roomId)
                .stream()
                .map(this::mapToMaintenanceResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<MaintenanceResponse> getMaintenanceByStatus(String status) {
        return maintenanceRepository.findByStatus(status)
                .stream()
                .map(this::mapToMaintenanceResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<MaintenanceResponse> getCriticalRequests() {
        return maintenanceRepository.findCriticalRequests()
                .stream()
                .map(this::mapToMaintenanceResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<MaintenanceResponse> getPendingRequests() {
        return maintenanceRepository.findPendingRequests()
                .stream()
                .map(this::mapToMaintenanceResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public MaintenanceResponse updateMaintenanceStatus(Long id, UpdateMaintenanceStatusRequest request) {
        MaintenanceRequest maintenance = maintenanceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Maintenance request not found"));

        maintenance.setStatus(request.getStatus());

        switch (request.getStatus()) {
            case "ASSIGNED":
                if (request.getAssignedToId() != null) {
                    Employee employee = employeeRepository.findById(request.getAssignedToId())
                            .orElseThrow(() -> new RuntimeException("Employee not found"));
                    maintenance.setAssignedTo(employee);
                    maintenance.setAssignedAt(LocalDateTime.now());
                }
                break;
            case "IN_PROGRESS":
                maintenance.setStartedAt(LocalDateTime.now());
                break;
            case "COMPLETED":
                maintenance.setCompletedAt(LocalDateTime.now());
                maintenance.setResolution(request.getResolution());
                maintenance.setCost(request.getCost());
                maintenance.setVerifiedBy(request.getVerifiedBy());
                maintenance.setVerifiedAt(LocalDateTime.now());
                break;
        }

        if (request.getNotes() != null) {
            maintenance.setNotes(request.getNotes());
        }

        MaintenanceRequest updatedRequest = maintenanceRepository.save(maintenance);
        return mapToMaintenanceResponse(updatedRequest);
    }

    @Override
    @Transactional
    public void deleteMaintenanceRequest(Long id) {
        if (!maintenanceRepository.existsById(id)) {
            throw new RuntimeException("Maintenance request not found");
        }
        maintenanceRepository.deleteById(id);
    }

    // ========== Statistics ==========

    @Override
    public Long getPendingTaskCount() {
        return taskRepository.countPendingTasks();
    }

    @Override
    public Long getPendingMaintenanceCount() {
        return maintenanceRepository.countPendingRequests();
    }

    @Override
    public Long getCriticalMaintenanceCount() {
        return (long) maintenanceRepository.findCriticalRequests().size();
    }

    // ========== Private Helper Methods ==========

    private TaskResponse mapToTaskResponse(HousekeepingTask task) {
        String assignedToName = null;
        if (task.getAssignedTo() != null) {
            assignedToName = task.getAssignedTo().getFirstName() + " " + task.getAssignedTo().getLastName();
        }

        return TaskResponse.builder()
                .id(task.getId())
                .roomId(task.getRoom().getId())
                .roomNumber(task.getRoom().getRoomNumber())
                .roomType(task.getRoom().getRoomType() != null ? task.getRoom().getRoomType().getName() : null)
                .taskType(task.getTaskType())
                .priority(task.getPriority())
                .status(task.getStatus())
                .assignedToId(task.getAssignedTo() != null ? task.getAssignedTo().getId() : null)
                .assignedToName(assignedToName)
                .scheduledDate(task.getScheduledDate())
                .assignedAt(task.getAssignedAt())
                .startedAt(task.getStartedAt())
                .completedAt(task.getCompletedAt())
                .notes(task.getNotes())
                .completionNotes(task.getCompletionNotes())
                .verifiedBy(task.getVerifiedBy())
                .verifiedAt(task.getVerifiedAt())
                .createdAt(task.getCreatedAt())
                .build();
    }

    private MaintenanceResponse mapToMaintenanceResponse(MaintenanceRequest request) {
        String reportedByName = request.getReportedBy() != null ?
                request.getReportedBy().getFirstName() + " " + request.getReportedBy().getLastName() : null;

        String assignedToName = request.getAssignedTo() != null ?
                request.getAssignedTo().getFirstName() + " " + request.getAssignedTo().getLastName() : null;

        return MaintenanceResponse.builder()
                .id(request.getId())
                .roomId(request.getRoom().getId())
                .roomNumber(request.getRoom().getRoomNumber())
                .roomType(request.getRoom().getRoomType() != null ? request.getRoom().getRoomType().getName() : null)
                .issueType(request.getIssueType())
                .priority(request.getPriority())
                .status(request.getStatus())
                .description(request.getDescription())
                .reportedById(request.getReportedBy() != null ? request.getReportedBy().getId() : null)
                .reportedByName(reportedByName)
                .reportedAt(request.getReportedAt())
                .assignedToId(request.getAssignedTo() != null ? request.getAssignedTo().getId() : null)
                .assignedToName(assignedToName)
                .assignedAt(request.getAssignedAt())
                .startedAt(request.getStartedAt())
                .completedAt(request.getCompletedAt())
                .resolution(request.getResolution())
                .cost(request.getCost())
                .notes(request.getNotes())
                .verifiedBy(request.getVerifiedBy())
                .verifiedAt(request.getVerifiedAt())
                .createdAt(request.getCreatedAt())
                .build();
    }
}