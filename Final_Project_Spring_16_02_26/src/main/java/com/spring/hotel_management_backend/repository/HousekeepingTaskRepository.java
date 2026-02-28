package com.spring.hotel_management_backend.repository;

import com.spring.hotel_management_backend.model.entity.HousekeepingTask;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface HousekeepingTaskRepository extends JpaRepository<HousekeepingTask, Long> {

    List<HousekeepingTask> findByRoomId(Long roomId);

    List<HousekeepingTask> findByAssignedToId(Long employeeId);

    List<HousekeepingTask> findByStatus(String status);

    List<HousekeepingTask> findByScheduledDate(LocalDate date);

    @Query("SELECT t FROM HousekeepingTask t WHERE t.status NOT IN ('COMPLETED', 'CANCELLED')")
    List<HousekeepingTask> findPendingTasks();

    @Query("SELECT t FROM HousekeepingTask t WHERE t.assignedTo.id = :employeeId AND t.status = 'IN_PROGRESS'")
    List<HousekeepingTask> findCurrentTasksByEmployee(@Param("employeeId") Long employeeId);

    @Query("SELECT COUNT(t) FROM HousekeepingTask t WHERE t.status = 'PENDING'")
    Long countPendingTasks();

    @Query("SELECT t FROM HousekeepingTask t WHERE t.scheduledDate = :date AND t.status NOT IN ('COMPLETED', 'CANCELLED')")
    List<HousekeepingTask> findTodaysPendingTasks(@Param("date") LocalDate date);
}