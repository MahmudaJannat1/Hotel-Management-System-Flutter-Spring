import '../local/database/daos/staff_attendance_dao.dart';
import '../local/database/daos/staff_leave_dao.dart'; // ✅ ADD THIS IMPORT
import '../local/database/daos/staff_schedule_dao.dart';
import '../local/database/daos/staff_task_dao.dart';
import '../local/database/daos/staff_user_dao.dart';
import '../models/staff_attendance_model.dart';
import '../models/staff_leave_balance.dart';
import '../models/staff_leave_model.dart';
import '../models/staff_schedule_model.dart';
import '../models/staff_task_model.dart';
import '../models/staff_user_model.dart';

class StaffRepository {
  final StaffUserDao _userDao = StaffUserDao();
  final StaffTaskDao _taskDao = StaffTaskDao();
  final StaffScheduleDao _scheduleDao = StaffScheduleDao();
  final StaffAttendanceDao _attendanceDao = StaffAttendanceDao();
  final StaffLeaveDao _leaveDao = StaffLeaveDao(); // ✅ ADD THIS LINE

  // ========== USER METHODS ==========

  Future<StaffUser?> getUserByEmail(String email) {
    return _userDao.getUserByEmail(email);
  }

  Future<StaffUser?> getLoggedInUser() {
    return _userDao.getLoggedInUser();
  }

  Future<int> updateUser(StaffUser user) {
    return _userDao.update(user);
  }

  Future<void> logoutAll() {
    return _userDao.logoutAll();
  }

  // ========== TASK METHODS ==========

  Future<List<StaffTask>> getTasksByStaff(int staffId) {
    return _taskDao.getTasksByStaff(staffId);
  }

  Future<int> updateTaskStatus(int taskId, String status) {
    return _taskDao.updateStatus(taskId, status);
  }

  Future<StaffTask?> getTaskById(int taskId) {
    return _taskDao.getTaskById(taskId);
  }

  // ========== SCHEDULE METHODS ==========

  Future<List<StaffSchedule>> getSchedulesByStaff(int staffId) {
    return _scheduleDao.getSchedulesByStaff(staffId);
  }

  Future<List<StaffSchedule>> getTodaysSchedules() {
    return _scheduleDao.getTodaysSchedules();
  }

  // ========== ATTENDANCE METHODS ==========

  Future<List<StaffAttendance>> getAttendanceByStaff(int staffId) {
    return _attendanceDao.getAttendanceByStaff(staffId);
  }

  Future<StaffAttendance?> getTodayAttendance(int staffId) {
    return _attendanceDao.getTodayAttendance(staffId);
  }

  Future<int> markAttendance(StaffAttendance attendance) {
    return _attendanceDao.markAttendance(attendance);
  }

  Future<int> updateCheckOut(int attendanceId, String checkOutTime) {
    return _attendanceDao.updateCheckOut(attendanceId, checkOutTime);
  }

  // ========== LEAVE METHODS ==========

  Future<List<StaffLeave>> getStaffLeaves(int staffId) {
    return _leaveDao.getStaffLeaves(staffId);
  }

  Future<StaffLeaveBalance?> getLeaveBalance(int staffId) {
    return _leaveDao.getLeaveBalance(staffId);
  }

  Future<int> applyLeave(StaffLeave leave) {
    return _leaveDao.applyLeave(leave);
  }

  Future<int> updateLeaveStatus(int leaveId, String status, {String? approvedBy, String? rejectionReason}) {
    return _leaveDao.updateLeaveStatus(leaveId, status, approvedBy: approvedBy, rejectionReason: rejectionReason);
  }

  // Add these to StaffRepository

  Future<List<StaffLeave>> getAllLeaveApplications() async {
    return _leaveDao.getAllLeaveApplications();
  }

  Future<bool> approveLeave(int leaveId, String approvedBy) async {
    return _leaveDao.approveLeave(leaveId, approvedBy);
  }

  Future<bool> rejectLeave(int leaveId, String reason, String rejectedBy) async {
    return _leaveDao.rejectLeave(leaveId, reason, rejectedBy);
  }

  Future<bool> cancelLeave(int leaveId) async {
    return _leaveDao.cancelLeave(leaveId);
  }

  // Add these methods to StaffRepository

  Future<List<StaffTask>> getAllTasks() {
    return _taskDao.getAllTasks();
  }

  Future<int> assignTask(StaffTask task) {
    return _taskDao.insertTask(task);
  }

  Future<List<StaffTask>> getTasksByStatus(String status) {
    return _taskDao.getTasksByStatus(status);
  }

  Future<List<StaffTask>> getTasksByPriority(String priority) {
    return _taskDao.getTasksByPriority(priority);
  }

  Future<int> deleteTask(int taskId) {
    return _taskDao.deleteTask(taskId);
  }

  Future<int> updateTask(StaffTask task) {
    return _taskDao.updateTask(task);
  }
}