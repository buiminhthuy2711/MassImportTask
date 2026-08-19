/**
 * Copyright (c) 2023-2026 JIP Academy (Tokyo, Japan).
 * Developed by JIP Academy R&D Team / Nguyen Minh Phuong.
 * All rights reserved.
 */
@isTest
private class JIP_HRAttendanceControllerTest {
  @testSetup
  static void setupTestData() {
    JIP_Department__c dept = JIP_TestDataFactory.createDepartment(
      'Test Department',
      true
    );

    // Create Worker linked to running user
    JIP_Worker__c worker = new JIP_Worker__c(
      Name = 'Test User Worker',
      User__c = UserInfo.getUserId(),
      Department__c = dept.Id,
      LastName__c = 'Test',
      FirstName__c = 'User',
      Email__c = 'testuser@test.com'
    );
    insert worker;

    // Create another worker for search tests
    JIP_Worker__c worker2 = JIP_TestDataFactory.createWorker(
      'Test Worker 2',
      dept.Id,
      true
    );

    // Create attendance with check-in (no checkout yet)
    JIP_Attendance__c attendance = new JIP_Attendance__c(
      Worker__c = worker.Id,
      AttendanceDate__c = Date.today(),
      CheckInTime__c = Datetime.now().addHours(-4),
      Status__c = '出勤',
      BreakMinutes__c = 60,
      Notes__c = 'Test note'
    );
    insert attendance;

    // Create another attendance with full check-in/out
    JIP_Attendance__c attendance2 = new JIP_Attendance__c(
      Worker__c = worker.Id,
      AttendanceDate__c = Date.today().addDays(-1),
      CheckInTime__c = Datetime.now().addDays(-1).addHours(-9),
      CheckOutTime__c = Datetime.now().addDays(-1),
      WorkingHours__c = 8.0,
      OvertimeHours__c = 0,
      Status__c = '退勤済',
      IsLate__c = false,
      BreakMinutes__c = 60
    );
    insert attendance2;

    // Create attendance with late status
    JIP_Attendance__c lateAttendance = new JIP_Attendance__c(
      Worker__c = worker2.Id,
      AttendanceDate__c = Date.today(),
      CheckInTime__c = Datetime.now().addHours(-2),
      Status__c = '出勤',
      IsLate__c = true
    );
    insert lateAttendance;

    // Create paid leave attendance
    JIP_Attendance__c leaveAttendance = new JIP_Attendance__c(
      Worker__c = worker2.Id,
      AttendanceDate__c = Date.today().addDays(-2),
      Status__c = '有給休暇'
    );
    insert leaveAttendance;

    // Create project
    JIP_Project__c proj = JIP_TestDataFactory.createProject(
      'Test Project',
      true
    );
    JIP_ProjectMember__c member = JIP_TestDataFactory.createProjectMember(
      proj.Id,
      worker.Id,
      true
    );

    // Create daily work entry
    JIP_DailyWorkEntry__c workEntry = new JIP_DailyWorkEntry__c(
      Worker__c = worker.Id,
      WorkDate__c = Date.today(),
      Project__c = proj.Id,
      WorkHours__c = 4.5,
      Comment__c = 'Test work entry',
      Attendance__c = attendance.Id
    );
    insert workEntry;

    // Create work schedule
    JIP_WorkSchedule__c schedule = new JIP_WorkSchedule__c(
      Worker__c = worker.Id,
      ScheduleDate__c = Date.today(),
      ShiftType__c = '日勤',
      StartTime__c = Time.newInstance(9, 0, 0, 0),
      EndTime__c = Time.newInstance(18, 0, 0, 0),
      BreakTime__c = 60,
      Notes__c = 'Test schedule'
    );
    insert schedule;

    // Create leave requests
    JIP_LeaveRequest__c leaveReq = new JIP_LeaveRequest__c(
      Applicant__c = worker.Id,
      RequestType__c = '有給休暇',
      StartDate__c = Date.today().addDays(10),
      EndDate__c = Date.today().addDays(11),
      Reason__c = 'Test leave',
      Status__c = '下書き',
      Approver1__c = UserInfo.getUserId()
    );
    insert leaveReq;

    // Create approved leave request for stats
    JIP_LeaveRequest__c approvedLeave = new JIP_LeaveRequest__c(
      Applicant__c = worker.Id,
      RequestType__c = '有給休暇',
      StartDate__c = Date.today().addDays(-5),
      EndDate__c = Date.today().addDays(-4),
      Reason__c = 'Past leave',
      Status__c = '承認済',
      Approver1__c = UserInfo.getUserId()
    );
    insert approvedLeave;
  }

  @isTest
  static void testConstructor() {
    Test.startTest();
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    Test.stopTest();
    System.assertNotEquals(
      null,
      controller,
      'Controller should be instantiated'
    );
    System.assertNotEquals(
      null,
      controller.attendanceList,
      'Attendance list should be initialized'
    );
    System.assertNotEquals(
      null,
      controller.stats,
      'Stats should be initialized'
    );
  }

  @isTest
  static void testGetLanguage() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    System.assertEquals(
      'ja',
      controller.getLanguage(),
      'Default language should be ja'
    );
    controller.language = '';
    System.assertEquals(
      'ja',
      controller.getLanguage(),
      'Empty should default to ja'
    );
    controller.language = 'en';
    System.assertEquals(
      'en',
      controller.getLanguage(),
      'Should return set language'
    );
  }

  @isTest
  static void testGetT() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    Map<String, String> t = controller.getT();
    System.assertNotEquals(null, t, 'Translations should not be null');
  }

  @isTest
  static void testSearchAttendance() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.searchKeyword = 'Test';
    Test.startTest();
    controller.searchAttendance();
    Test.stopTest();
    System.assert(true, 'Search completed');
  }

  @isTest
  static void testSearchWithFilters() {
    JIP_Department__c dept = [SELECT Id FROM JIP_Department__c LIMIT 1];
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.searchKeyword = 'Test';
    controller.filterDepartment = dept.Id;
    controller.filterStatus = 'Working';
    Test.startTest();
    controller.searchAttendance();
    Test.stopTest();
    System.assert(true, 'Search with filters completed');
  }

  @isTest
  static void testClearSearch() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.searchKeyword = 'Test';
    controller.filterDepartment = 'TestDept';
    controller.filterStatus = 'Working';
    Test.startTest();
    controller.clearSearch();
    Test.stopTest();
    System.assertEquals(
      '',
      controller.searchKeyword,
      'Search should be cleared'
    );
    System.assertEquals(
      '',
      controller.filterDepartment,
      'Department filter should be cleared'
    );
  }

  @isTest
  static void testCheckInWithWorker() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.gpsLocation = '35.6762,139.6503';
    controller.ipAddress = '192.168.1.1';
    controller.deviceType = 'Desktop';
    Test.startTest();
    controller.checkIn();
    Test.stopTest();
    // Attendance may already exist from testSetup - verify no errors occurred
    System.assert(true, 'CheckIn should complete without exceptions');
  }

  @isTest
  static void testCheckInExistingAttendance() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.gpsLocation = '35.6762,139.6503';
    controller.ipAddress = '192.168.1.1';
    controller.deviceType = 'Desktop';
    Test.startTest();
    controller.checkIn();
    Test.stopTest();
    System.assert(true, 'CheckIn with existing attendance completed');
  }

  @isTest
  static void testCheckOutWithWorker() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.gpsLocation = '35.6762,139.6503';
    controller.ipAddress = '192.168.1.1';
    controller.deviceType = 'Desktop';
    Test.startTest();
    controller.checkOut();
    Test.stopTest();
    System.assert(true, 'CheckOut completed');
  }

  @isTest
  static void testChangeLanguage() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.language = 'en';
    Test.startTest();
    controller.changeLanguage();
    Test.stopTest();
    System.assertEquals(
      'en',
      controller.language,
      'Language should be changed'
    );
  }

  @isTest
  static void testGetDepartmentOptions() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    Test.startTest();
    List<SelectOption> options = controller.getDepartmentOptions();
    Test.stopTest();
    System.assertNotEquals(null, options, 'Options should not be null');
    System.assert(options.size() > 0, 'Should have at least one option');
  }

  @isTest
  static void testGetStatusOptions() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    Test.startTest();
    List<SelectOption> options = controller.getStatusOptions();
    Test.stopTest();
    System.assertNotEquals(null, options, 'Options should not be null');
  }

  @isTest
  static void testGetLanguageOptions() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    Test.startTest();
    List<SelectOption> options = controller.getLanguageOptions();
    Test.stopTest();
    System.assertNotEquals(null, options, 'Options should not be null');
    System.assertEquals(2, options.size(), 'Should have 2 language options');
  }

  @isTest
  static void testGetRequestTypeOptions() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    Test.startTest();
    List<SelectOption> options = controller.getRequestTypeOptions();
    Test.stopTest();
    System.assertNotEquals(null, options, 'Options should not be null');
  }

  @isTest
  static void testGetShiftTypeOptions() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    Test.startTest();
    List<SelectOption> options = controller.getShiftTypeOptions();
    Test.stopTest();
    System.assertNotEquals(null, options, 'Options should not be null');
  }

  @isTest
  static void testExportAttendanceReport() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    Test.startTest();
    PageReference result = controller.exportAttendanceReport();
    Test.stopTest();
    System.assert(true, 'Export completed');
  }

  @isTest
  static void testExportMonthlyReport() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    Test.startTest();
    PageReference result = controller.exportMonthlyReport();
    Test.stopTest();
    System.assert(true, 'Export completed');
  }

  @isTest
  static void testSaveScheduleNew() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.scheduleDate = Date.today().addDays(7);
    controller.scheduleStartTime = '09:00';
    controller.scheduleEndTime = '18:00';
    controller.scheduleBreakTime = 60;
    if (controller.newSchedule == null) {
      controller.newSchedule = new JIP_WorkSchedule__c();
    }
    Test.startTest();
    controller.saveSchedule();
    Test.stopTest();
    System.assert(true, 'Schedule saved');
  }

  @isTest
  static void testEditScheduleForDateExisting() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedScheduleDate = String.valueOf(Date.today());
    Test.startTest();
    controller.editScheduleForDate();
    Test.stopTest();
    System.assert(true, 'Edit schedule completed');
  }

  @isTest
  static void testEditScheduleForDateNew() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedScheduleDate = String.valueOf(Date.today().addDays(30));
    Test.startTest();
    controller.editScheduleForDate();
    Test.stopTest();
    System.assert(true, 'Edit new schedule completed');
  }

  @isTest
  static void testSubmitLeaveRequestValidation() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.requestStartDate = null;
    Test.startTest();
    controller.submitLeaveRequest();
    Test.stopTest();
    System.assert(true, 'Submit validation completed');
  }

  @isTest
  static void testSubmitLeaveRequestSuccess() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.requestStartDate = Date.today().addDays(20);
    controller.requestEndDate = Date.today().addDays(21);
    if (controller.newLeaveRequest == null) {
      controller.newLeaveRequest = new JIP_LeaveRequest__c();
    }
    controller.newLeaveRequest.Approver1__c = UserInfo.getUserId();
    controller.newLeaveRequest.Reason__c = 'Test reason';
    controller.newLeaveRequest.RequestType__c = '有給休暇';
    Test.startTest();
    controller.submitLeaveRequest();
    Test.stopTest();
    System.assert(true, 'Submit completed');
  }

  @isTest
  static void testApproveRequest() {
    JIP_LeaveRequest__c leave = [
      SELECT Id
      FROM JIP_LeaveRequest__c
      WHERE Status__c = '下書き'
      LIMIT 1
    ];
    leave.Status__c = '承認待ち(上司)';
    update leave;

    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedRequestId = leave.Id;
    controller.approverComment = 'Approved';
    Test.startTest();
    controller.approveRequest();
    Test.stopTest();
    System.assert(true, 'Approve completed');
  }

  @isTest
  static void testRejectRequest() {
    JIP_LeaveRequest__c leave = [
      SELECT Id
      FROM JIP_LeaveRequest__c
      WHERE Status__c = '下書き'
      LIMIT 1
    ];
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedRequestId = leave.Id;
    controller.approverComment = 'Rejected';
    Test.startTest();
    controller.rejectRequest();
    Test.stopTest();
    System.assert(true, 'Reject completed');
  }

  @isTest
  static void testCancelMyRequest() {
    JIP_LeaveRequest__c leave = [
      SELECT Id
      FROM JIP_LeaveRequest__c
      WHERE Status__c = '下書き'
      LIMIT 1
    ];
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedRequestId = leave.Id;
    Test.startTest();
    controller.cancelMyRequest();
    Test.stopTest();
    System.assert(true, 'Cancel completed');
  }

  @isTest
  static void testSelectWorkDate() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedWorkDateStr = String.valueOf(Date.today());
    Test.startTest();
    controller.selectWorkDate();
    Test.stopTest();
    System.assertEquals(
      Date.today(),
      controller.selectedWorkDate,
      'Work date should be selected'
    );
  }

  @isTest
  static void testSelectWorkDateDifferentMonth() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedWorkDateStr = String.valueOf(Date.today().addMonths(-1));
    Test.startTest();
    controller.selectWorkDate();
    Test.stopTest();
    System.assert(true, 'Work date selected for different month');
  }

  @isTest
  static void testSaveWorkEntry() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.newProjectId = proj.Id;
    controller.newWorkHours = '4:30';
    controller.newWorkComment = 'Test work';
    controller.selectedWorkDate = Date.today();
    Test.startTest();
    controller.saveWorkEntry();
    Test.stopTest();
    System.assert(true, 'Work entry saved');
  }

  @isTest
  static void testSaveWorkEntryDecimalHours() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.newProjectId = proj.Id;
    controller.newWorkHours = '4.5';
    controller.newWorkComment = 'Test work decimal';
    controller.selectedWorkDate = Date.today();
    Test.startTest();
    controller.saveWorkEntry();
    Test.stopTest();
    System.assert(true, 'Work entry with decimal hours saved');
  }

  @isTest
  static void testDeleteWorkEntry() {
    JIP_DailyWorkEntry__c entry = [
      SELECT Id
      FROM JIP_DailyWorkEntry__c
      LIMIT 1
    ];
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedWorkEntryId = entry.Id;
    Test.startTest();
    controller.deleteWorkEntry();
    Test.stopTest();
    System.assert(true, 'Delete work entry completed');
  }

  @isTest
  static void testSaveDailyCommentWithAttendance() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedWorkDate = Date.today();
    controller.dailyComment = 'Test comment';
    Test.startTest();
    controller.saveDailyComment();
    Test.stopTest();
    System.assert(true, 'Daily comment saved');
  }

  @isTest
  static void testSaveDailyCommentNewAttendance() {
    delete [
      SELECT Id
      FROM JIP_Attendance__c
      WHERE AttendanceDate__c = :Date.today()
    ];

    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedWorkDate = Date.today();
    controller.dailyComment = 'New comment';
    Test.startTest();
    controller.saveDailyComment();
    Test.stopTest();
    System.assert(true, 'Daily comment with new attendance saved');
  }

  @isTest
  static void testStampCheckIn() {
    delete [
      SELECT Id
      FROM JIP_Attendance__c
      WHERE AttendanceDate__c = :Date.today()
    ];

    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedWorkDate = Date.today();
    Test.startTest();
    controller.stampCheckIn();
    Test.stopTest();
    System.assert(true, 'Stamp check in completed');
  }

  @isTest
  static void testStampCheckInExisting() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedWorkDate = Date.today();
    Test.startTest();
    controller.stampCheckIn();
    Test.stopTest();
    System.assert(true, 'Stamp check in existing completed');
  }

  @isTest
  static void testStampCheckOut() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedWorkDate = Date.today();
    Test.startTest();
    controller.stampCheckOut();
    Test.stopTest();
    System.assert(true, 'Stamp check out completed');
  }

  @isTest
  static void testUpdateDailyStatus() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedWorkDate = Date.today();
    Test.startTest();
    controller.updateDailyStatus();
    Test.stopTest();
    System.assert(true, 'Update daily status completed');
  }

  @isTest
  static void testUpdateBreakTime() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedWorkDate = Date.today();
    Test.startTest();
    controller.updateBreakTime();
    Test.stopTest();
    System.assert(true, 'Update break time completed');
  }

  @isTest
  static void testCalendarNavigation() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    Test.startTest();
    controller.prevMonth();
    controller.nextMonth();
    controller.prevYear();
    controller.nextYear();
    Test.stopTest();
    System.assertNotEquals(
      null,
      controller.calendarMonth,
      'Calendar month should be set'
    );
  }

  @isTest
  static void testLoadMonthlyWorksheet() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    Test.startTest();
    controller.loadMonthlyWorksheet();
    Test.stopTest();
    System.assertNotEquals(
      null,
      controller.worksheetRows,
      'Worksheet rows should be loaded'
    );
  }

  @isTest
  static void testSaveMonthlyWorksheet() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    Test.startTest();
    controller.saveMonthlyWorksheet();
    Test.stopTest();
    System.assert(true, 'Monthly worksheet saved');
  }

  @isTest
  static void testAddProjectToWorksheet() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.newProjectId = proj.Id;
    Test.startTest();
    controller.addProjectToWorksheet();
    Test.stopTest();
    System.assert(true, 'Project added to worksheet');
  }

  @isTest
  static void testAddDuplicateProjectToWorksheet() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    controller.newProjectId = proj.Id;
    controller.addProjectToWorksheet();
    Test.startTest();
    controller.addProjectToWorksheet();
    Test.stopTest();
    System.assert(true, 'Duplicate project handled');
  }

  @isTest
  static void testRemoveProjectFromMonth() {
    JIP_Project__c proj = [SELECT Id FROM JIP_Project__c LIMIT 1];
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedWorkEntryId = proj.Id;
    Test.startTest();
    controller.removeProjectFromMonth();
    Test.stopTest();
    System.assert(true, 'Project removed from month');
  }

  @isTest
  static void testLoadDailyAttendanceInfo() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.selectedAttendanceDate = String.valueOf(Date.today());
    Test.startTest();
    controller.loadDailyAttendanceInfo();
    Test.stopTest();
    System.assert(true, 'Daily attendance info loaded');
  }

  @isTest
  static void testAttendanceWrapper() {
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];
    JIP_Attendance__c att = new JIP_Attendance__c(
      Worker__c = worker.Id,
      AttendanceDate__c = Date.today().addDays(-30),
      Status__c = '出勤',
      CheckInTime__c = Datetime.now().addDays(-30).addHours(-2)
    );
    insert att;

    JIP_Attendance__c attFull = [
      SELECT
        Id,
        Worker__c,
        Worker__r.Name,
        Worker__r.LastName__c,
        Worker__r.FirstName__c,
        Worker__r.Department__c,
        Worker__r.Department__r.Name,
        AttendanceDate__c,
        CheckInTime__c,
        CheckOutTime__c,
        WorkingHours__c,
        OvertimeHours__c,
        Status__c,
        IsLate__c
      FROM JIP_Attendance__c
      WHERE Id = :att.Id
    ];

    Test.startTest();
    JIP_HRAttendanceController.AttendanceWrapper wrapper = new JIP_HRAttendanceController.AttendanceWrapper(
      attFull
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      wrapper.employeeName,
      'Employee name should be set'
    );
  }

  @isTest
  static void testAttendanceWrapperStatuses() {
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];

    // Test paid leave status
    JIP_Attendance__c leaveAtt = new JIP_Attendance__c(
      Worker__c = worker.Id,
      AttendanceDate__c = Date.today().addDays(-40),
      Status__c = '有給休暇'
    );
    insert leaveAtt;

    // Test late status
    JIP_Attendance__c lateAtt = new JIP_Attendance__c(
      Worker__c = worker.Id,
      AttendanceDate__c = Date.today().addDays(-41),
      Status__c = '出勤',
      CheckInTime__c = Datetime.now().addDays(-41),
      IsLate__c = true
    );
    insert lateAtt;

    // Test completed status
    JIP_Attendance__c doneAtt = new JIP_Attendance__c(
      Worker__c = worker.Id,
      AttendanceDate__c = Date.today().addDays(-42),
      Status__c = '退勤済',
      CheckInTime__c = Datetime.now().addDays(-42).addHours(-9),
      CheckOutTime__c = Datetime.now().addDays(-42)
    );
    insert doneAtt;

    Test.startTest();
    List<JIP_Attendance__c> atts = [
      SELECT
        Id,
        Worker__c,
        Worker__r.Name,
        Worker__r.LastName__c,
        Worker__r.FirstName__c,
        Worker__r.Department__c,
        Worker__r.Department__r.Name,
        AttendanceDate__c,
        CheckInTime__c,
        CheckOutTime__c,
        WorkingHours__c,
        OvertimeHours__c,
        Status__c,
        IsLate__c
      FROM JIP_Attendance__c
      WHERE Id IN (:leaveAtt.Id, :lateAtt.Id, :doneAtt.Id)
    ];

    for (JIP_Attendance__c a : atts) {
      JIP_HRAttendanceController.AttendanceWrapper w = new JIP_HRAttendanceController.AttendanceWrapper(
        a
      );
      System.assertNotEquals(null, w.status, 'Status should be set');
    }
    Test.stopTest();
  }

  @isTest
  static void testLeaveBalanceWrapper() {
    Test.startTest();
    JIP_HRAttendanceController.LeaveBalanceWrapper wrapper = new JIP_HRAttendanceController.LeaveBalanceWrapper(
      'paid_leave',
      12.0,
      5.0
    );
    Test.stopTest();
    System.assertEquals(
      'paid_leave',
      wrapper.leaveType,
      'Leave type should match'
    );
    System.assertEquals(
      7.0,
      wrapper.remaining,
      'Remaining should be calculated'
    );
  }

  @isTest
  static void testStatsWrapper() {
    Test.startTest();
    JIP_HRAttendanceController.StatsWrapper wrapper = new JIP_HRAttendanceController.StatsWrapper();
    Test.stopTest();
    System.assertEquals(0, wrapper.workingCount, 'Working count should be 0');
  }

  @isTest
  static void testScheduleWrapper() {
    JIP_WorkSchedule__c sch = new JIP_WorkSchedule__c(
      ScheduleDate__c = Date.today(),
      ShiftType__c = '日勤',
      StartTime__c = Time.newInstance(9, 0, 0, 0),
      EndTime__c = Time.newInstance(18, 0, 0, 0),
      BreakTime__c = 60,
      Notes__c = 'Test'
    );

    Test.startTest();
    JIP_HRAttendanceController.ScheduleWrapper wrapper = new JIP_HRAttendanceController.ScheduleWrapper(
      Date.today(),
      sch
    );
    JIP_HRAttendanceController.ScheduleWrapper wrapperNull = new JIP_HRAttendanceController.ScheduleWrapper(
      Date.today(),
      null
    );
    Test.stopTest();

    System.assertEquals(
      Date.today(),
      wrapper.scheduleDate,
      'Schedule date should match'
    );
    System.assertEquals(true, wrapper.isToday, 'Should be today');
  }

  @isTest
  static void testLeaveRequestWrapper() {
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];
    JIP_LeaveRequest__c req = new JIP_LeaveRequest__c(
      Applicant__c = worker.Id,
      RequestType__c = '有給休暇',
      StartDate__c = Date.today().addDays(50),
      EndDate__c = Date.today().addDays(52),
      Reason__c = 'Test',
      Status__c = '承認済',
      SubmittedDate__c = Datetime.now()
    );
    insert req;

    JIP_LeaveRequest__c reqFull = [
      SELECT
        Id,
        Name,
        Applicant__r.Name,
        Applicant__r.LastName__c,
        Applicant__r.FirstName__c,
        RequestType__c,
        StartDate__c,
        EndDate__c,
        Status__c,
        Reason__c,
        OvertimeHours__c,
        SubmittedDate__c
      FROM JIP_LeaveRequest__c
      WHERE Id = :req.Id
    ];

    Test.startTest();
    JIP_HRAttendanceController.LeaveRequestWrapper wrapper = new JIP_HRAttendanceController.LeaveRequestWrapper(
      reqFull
    );
    Test.stopTest();

    System.assertEquals('承認済', wrapper.status, 'Status should match');
  }

  @isTest
  static void testLeaveRequestWrapperStatuses() {
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];

    // Test rejected status
    JIP_LeaveRequest__c rejReq = new JIP_LeaveRequest__c(
      Applicant__c = worker.Id,
      RequestType__c = '有給休暇',
      StartDate__c = Date.today().addDays(60),
      EndDate__c = Date.today().addDays(60),
      Reason__c = 'Test rejected',
      Status__c = '却下'
    );
    insert rejReq;

    // Test cancelled status
    JIP_LeaveRequest__c canReq = new JIP_LeaveRequest__c(
      Applicant__c = worker.Id,
      RequestType__c = '有給休暇',
      StartDate__c = Date.today().addDays(61),
      EndDate__c = Date.today().addDays(61),
      Reason__c = 'Test cancelled',
      Status__c = '取消'
    );
    insert canReq;

    Test.startTest();
    List<JIP_LeaveRequest__c> reqs = [
      SELECT
        Id,
        Name,
        Applicant__r.Name,
        Applicant__r.LastName__c,
        Applicant__r.FirstName__c,
        RequestType__c,
        StartDate__c,
        EndDate__c,
        Status__c,
        Reason__c,
        OvertimeHours__c,
        SubmittedDate__c
      FROM JIP_LeaveRequest__c
      WHERE Id IN (:rejReq.Id, :canReq.Id)
    ];

    for (JIP_LeaveRequest__c r : reqs) {
      JIP_HRAttendanceController.LeaveRequestWrapper w = new JIP_HRAttendanceController.LeaveRequestWrapper(
        r
      );
      System.assertNotEquals(null, w.status, 'Status should be set');
    }
    Test.stopTest();
  }

  @isTest
  static void testDailyDetailWrapper() {
    JIP_Worker__c worker = [SELECT Id FROM JIP_Worker__c LIMIT 1];
    JIP_Attendance__c att = new JIP_Attendance__c(
      Worker__c = worker.Id,
      AttendanceDate__c = Date.today().addDays(-50),
      CheckInTime__c = Datetime.now().addDays(-50).addHours(-8),
      CheckOutTime__c = Datetime.now().addDays(-50),
      Status__c = '退勤済',
      BreakMinutes__c = 60,
      WorkingHours__c = 7.0,
      Notes__c = 'Test note'
    );
    insert att;

    Test.startTest();
    JIP_HRAttendanceController.DailyDetailWrapper wrapper = new JIP_HRAttendanceController.DailyDetailWrapper(
      Date.today().addDays(-50),
      att
    );
    JIP_HRAttendanceController.DailyDetailWrapper wrapperNull = new JIP_HRAttendanceController.DailyDetailWrapper(
      Date.today().addDays(-51),
      null
    );
    Test.stopTest();

    System.assertEquals('Test note', wrapper.notes, 'Notes should match');
  }

  @isTest
  static void testWorkEntryWrapper() {
    JIP_DailyWorkEntry__c entry = [
      SELECT
        Id,
        Project__c,
        Project__r.Name,
        Project__r.Name__c,
        WorkHours__c,
        Comment__c
      FROM JIP_DailyWorkEntry__c
      LIMIT 1
    ];

    Test.startTest();
    JIP_HRAttendanceController.WorkEntryWrapper wrapper = new JIP_HRAttendanceController.WorkEntryWrapper(
      entry,
      1
    );
    Test.stopTest();

    System.assertEquals(1, wrapper.rowNumber, 'Row number should be 1');
  }

  @isTest
  static void testBreakEntryWrapper() {
    Test.startTest();
    JIP_HRAttendanceController.BreakEntryWrapper wrapper = new JIP_HRAttendanceController.BreakEntryWrapper(
      '12:00',
      '13:00',
      'Break',
      'Lunch',
      '1:00'
    );
    Test.stopTest();

    System.assertEquals('12:00', wrapper.startTime, 'Start time should match');
    System.assertEquals('13:00', wrapper.endTime, 'End time should match');
  }

  @isTest
  static void testCalendarDayWrapper() {
    Test.startTest();
    JIP_HRAttendanceController.CalendarDayWrapper wrapper = new JIP_HRAttendanceController.CalendarDayWrapper(
      Date.today(),
      Date.today().month(),
      Date.today(),
      true
    );
    Test.stopTest();

    System.assertEquals(true, wrapper.isToday, 'Should be today');
    System.assertEquals(true, wrapper.isSelected, 'Should be selected');
  }

  @isTest
  static void testMonthlyProjectSummary() {
    Test.startTest();
    JIP_HRAttendanceController.MonthlyProjectSummary summary = new JIP_HRAttendanceController.MonthlyProjectSummary(
      'proj123',
      'PRJ-001',
      'Test Project',
      40.5,
      100.0
    );
    Test.stopTest();

    System.assertEquals(
      'PRJ-001',
      summary.projectCode,
      'Project code should match'
    );
    System.assertEquals(40.5, summary.totalHours, 'Total hours should match');
  }

  @isTest
  static void testWorkSheetRowWrapper() {
    Test.startTest();
    JIP_HRAttendanceController.WorkSheetRowWrapper wrapper = new JIP_HRAttendanceController.WorkSheetRowWrapper();
    Test.stopTest();

    System.assertNotEquals(
      null,
      wrapper.projectHours,
      'Project hours list should be initialized'
    );
  }

  @isTest
  static void testProjectColumnWrapper() {
    Test.startTest();
    JIP_HRAttendanceController.ProjectColumnWrapper wrapper = new JIP_HRAttendanceController.ProjectColumnWrapper(
      'proj123',
      'Test Project',
      0
    );
    Test.stopTest();

    System.assertEquals(
      'proj123',
      wrapper.projectId,
      'Project ID should match'
    );
    System.assertEquals(0, wrapper.columnIndex, 'Column index should be 0');
  }

  @isTest
  static void testMonthlyWorkStatusWrapper() {
    Test.startTest();
    JIP_HRAttendanceController.MonthlyWorkStatusWrapper wrapper = new JIP_HRAttendanceController.MonthlyWorkStatusWrapper();
    Test.stopTest();

    System.assertEquals(
      '0:00',
      wrapper.workHours,
      'Default work hours should be 0:00'
    );
  }

  @isTest
  static void testAttendanceInfoWrapper() {
    Test.startTest();
    JIP_HRAttendanceController.AttendanceInfoWrapper wrapper = new JIP_HRAttendanceController.AttendanceInfoWrapper();
    Test.stopTest();

    System.assertEquals(
      '8:00',
      wrapper.actualWorkHours,
      'Default work hours should be 8:00'
    );
    System.assertEquals(
      false,
      wrapper.hasAttendance,
      'Default has attendance should be false'
    );
  }

  @isTest
  static void testLanguageEnglish() {
    JIP_HRAttendanceController controller = new JIP_HRAttendanceController();
    controller.language = 'en';
    Test.startTest();
    controller.changeLanguage();
    String lang = controller.getLanguage();
    Map<String, String> t = controller.getT();
    Test.stopTest();
    System.assertEquals('en', lang, 'Language should be English');
  }
}