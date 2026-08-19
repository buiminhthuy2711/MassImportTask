/**
 * Copyright (c) 2023-2026 JIP Academy (Tokyo, Japan).
 * Developed by JIP Academy R&D Team / Nguyen Minh Phuong.
 * All rights reserved.
 *
 * Unauthorized copying, modification, distribution, or use of this source code,
 * in whole or in part, is strictly prohibited without prior written permission.
 *
 * @see https://www.jip-academy.com/
 */
public with sharing class JIP_HRAttendanceController {
  // ===== Properties =====
  public String language { get; set; }
  public String searchKeyword { get; set; }
  public String filterDepartment { get; set; }
  public String filterStatus { get; set; }
  public Date selectedDate { get; set; }
  public Date viewMonth { get; set; }

  // Stats
  public Integer workingCount { get; set; }
  public Integer notCheckedInCount { get; set; }
  public Decimal paidLeaveCount { get; set; }
  public Integer lateCount { get; set; }
  public Decimal totalOvertimeHours { get; set; }
  public StatsWrapper stats { get; set; }

  // Data lists
  public List<AttendanceWrapper> attendanceList { get; set; }
  public List<LeaveBalanceWrapper> leaveBalances { get; set; }

  // Current user attendance
  public JIP_Attendance__c currentUserAttendance { get; set; }
  public String currentCheckInTime { get; set; }
  public String currentCheckOutTime { get; set; }
  public Boolean isCheckedIn { get; set; }

  // GPS, IP, Device for attendance tracking
  public String gpsLocation { get; set; }
  public String ipAddress { get; set; }
  public String deviceType { get; set; }

  // ===== Schedule Management =====
  public List<ScheduleWrapper> weeklySchedule { get; set; }
  public JIP_WorkSchedule__c newSchedule { get; set; }
  public Date scheduleDate { get; set; }
  public String scheduleStartTime { get; set; }
  public String scheduleEndTime { get; set; }
  public Decimal scheduleBreakTime { get; set; }
  public String currentTab { get; set; }

  // ===== Leave Request Management =====
  public List<LeaveRequestWrapper> pendingRequests { get; set; }
  public List<LeaveRequestWrapper> myRequests { get; set; }
  public JIP_LeaveRequest__c newLeaveRequest { get; set; }
  public Date requestStartDate { get; set; }
  public Date requestEndDate { get; set; }
  public Decimal requestOvertimeHours { get; set; }
  public String selectedRequestId { get; set; }
  public String approverComment { get; set; }
  public List<SelectOption> approverOptions { get; set; }
  public String selectedScheduleDate { get; set; }

  // ===== Daily Work Detail Management =====
  public Date selectedWorkDate { get; set; }
  public String selectedWorkDateStr { get; set; }
  public DailyDetailWrapper dailyDetail { get; set; }
  public List<WorkEntryWrapper> workEntries { get; set; }
  public List<BreakEntryWrapper> breakEntries { get; set; }
  public String dailyComment { get; set; }
  public String selectedWorkEntryId { get; set; }
  public List<SelectOption> projectOptions { get; set; }
  public List<SelectOption> statusOptions { get; set; }

  // Monthly project summary
  public List<MonthlyProjectSummary> monthlyProjectSummaries { get; set; }
  public Decimal monthlyTotalHours { get; set; }

  // Monthly work status
  public MonthlyWorkStatusWrapper monthlyWorkStatus { get; set; }
  public AttendanceInfoWrapper attendanceInfo { get; set; }
  public String selectedAttendanceDate { get; set; }
  public String selectedAttendanceDateLabel { get; set; }

  // New work entry input
  public String newProjectId { get; set; }
  public String newWorkHours { get; set; }
  public String newWorkComment { get; set; }

  // ===== Calendar Properties =====
  public Date calendarMonth { get; set; }
  public List<List<CalendarDayWrapper>> calendarWeeks { get; set; }
  public String calendarMonthLabel { get; set; }

  // ===== Monthly Worksheet Properties =====
  public List<WorkSheetRowWrapper> worksheetRows { get; set; }
  public List<ProjectColumnWrapper> worksheetProjects { get; set; }
  public Boolean hasWorksheetProjects { get; set; }

  // ===== Constructor =====
  public JIP_HRAttendanceController() {
    language = 'ja';
    searchKeyword = '';
    filterDepartment = '';
    filterStatus = '';
    selectedDate = Date.today();
    viewMonth = Date.today().toStartOfMonth();
    isCheckedIn = false;
    currentTab = 'attendance';
    approverComment = '';
    selectedWorkDate = Date.today();
    dailyComment = '';
    workEntries = new List<WorkEntryWrapper>();
    breakEntries = new List<BreakEntryWrapper>();
    calendarMonth = Date.today().toStartOfMonth();

    loadStatistics();
    loadAttendanceList();
    loadLeaveBalances();
    loadCurrentUserAttendance();
    loadWeeklySchedule();
    loadPendingRequests();
    loadMyRequests();
    initNewLeaveRequest();
    initNewSchedule();
    loadApproverOptions();
    loadProjectOptions();
    loadStatusOptions();
    loadDailyDetail();
    loadCalendar();
    loadMonthlyProjectSummary();
    loadMonthlyWorksheet();
    loadMonthlyWorkStatus();
  }

  // ===== Multi-language Support =====
  public String getLanguage() {
    return String.isBlank(language) ? 'ja' : language;
  }

  public Map<String, String> getT() {
    return JIP_TranslationHelper.getAllTranslations(getLanguage());
  }

  // ===== Data Loading Methods =====
  private void loadStatistics() {
    Date today = Date.today();

    // Count working employees
    workingCount = [
      SELECT COUNT()
      FROM JIP_Attendance__c
      WHERE
        AttendanceDate__c = :today
        AND CheckInTime__c != NULL
        AND CheckOutTime__c = NULL
    ];

    // Count employees not checked in (simplified - would need Worker__c object)
    Integer totalEmployees = [
      SELECT COUNT()
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職中'
    ];
    Integer checkedInToday = [
      SELECT COUNT()
      FROM JIP_Attendance__c
      WHERE AttendanceDate__c = :today AND CheckInTime__c != NULL
    ];
    notCheckedInCount = totalEmployees - checkedInToday;
    if (notCheckedInCount < 0)
      notCheckedInCount = 0;

    // Count late arrivals
    lateCount = [
      SELECT COUNT()
      FROM JIP_Attendance__c
      WHERE AttendanceDate__c = :today AND IsLate__c = TRUE
    ];

    // Sum overtime hours for this month
    AggregateResult[] otResults = [
      SELECT SUM(OvertimeHours__c) total
      FROM JIP_Attendance__c
      WHERE AttendanceDate__c >= :viewMonth AND AttendanceDate__c <= :today
    ];
    totalOvertimeHours = otResults[0].get('total') != null
      ? (Decimal) otResults[0].get('total')
      : 0;

    // Paid leave count (simplified)
    paidLeaveCount = [
      SELECT COUNT()
      FROM JIP_Attendance__c
      WHERE AttendanceDate__c = :today AND Status__c = '有給休暇'
    ];

    // Populate stats wrapper
    stats = new StatsWrapper();
    stats.workingCount = workingCount;
    stats.notCheckedInCount = notCheckedInCount;
    stats.onLeaveCount = Integer.valueOf(paidLeaveCount);
    stats.lateCount = lateCount;
    stats.monthlyOvertimeHours = totalOvertimeHours;
  }

  private void loadAttendanceList() {
    attendanceList = new List<AttendanceWrapper>();

    String query =
      'SELECT Id, Worker__c, Worker__r.Name, Worker__r.LastName__c, Worker__r.FirstName__c, ' +
      'Worker__r.Department__c, Worker__r.Department__r.Name, AttendanceDate__c, CheckInTime__c, CheckOutTime__c, ' +
      'WorkingHours__c, OvertimeHours__c, Status__c, IsLate__c, GPS_Location__c, IP_Address__c, Device__c ' +
      'FROM JIP_Attendance__c WHERE AttendanceDate__c = :selectedDate';

    List<String> conditions = new List<String>();

    if (String.isNotBlank(searchKeyword)) {
      String safeKeyword =
        '%' +
        String.escapeSingleQuotes(searchKeyword.trim()) +
        '%';
      conditions.add(
        '(Worker__r.Name LIKE :safeKeyword OR Worker__r.LastName__c LIKE :safeKeyword OR Worker__r.FirstName__c LIKE :safeKeyword)'
      );
    }

    if (String.isNotBlank(filterDepartment)) {
      conditions.add('Worker__r.Department__c = :filterDepartment');
    }

    if (String.isNotBlank(filterStatus)) {
      conditions.add('Status__c = :filterStatus');
    }

    if (!conditions.isEmpty()) {
      query += ' AND ' + String.join(conditions, ' AND ');
    }

    query += ' ORDER BY Worker__r.Name ASC LIMIT 200';

    for (JIP_Attendance__c att : Database.query(query)) {
      attendanceList.add(new AttendanceWrapper(att));
    }
  }

  private void loadLeaveBalances() {
    leaveBalances = new List<LeaveBalanceWrapper>();

    // Sample data - in real implementation, this would come from a Leave Balance object
    leaveBalances.add(new LeaveBalanceWrapper('paid_leave', 12.0, 8.0));
    leaveBalances.add(new LeaveBalanceWrapper('summer_leave', 3.0, 2.0));
    leaveBalances.add(new LeaveBalanceWrapper('sick_leave', 5.0, 1.0));
  }

  private void loadCurrentUserAttendance() {
    Date today = Date.today();
    Id currentUserId = UserInfo.getUserId();

    // Find worker linked to current user
    List<JIP_Worker__c> workers = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE User__c = :currentUserId
      LIMIT 1
    ];

    if (!workers.isEmpty()) {
      List<JIP_Attendance__c> attendances = [
        SELECT Id, CheckInTime__c, CheckOutTime__c, Status__c
        FROM JIP_Attendance__c
        WHERE Worker__c = :workers[0].Id AND AttendanceDate__c = :today
        LIMIT 1
      ];

      if (!attendances.isEmpty()) {
        currentUserAttendance = attendances[0];
        isCheckedIn =
          currentUserAttendance.CheckInTime__c != null &&
          currentUserAttendance.CheckOutTime__c == null;
        currentCheckInTime = currentUserAttendance.CheckInTime__c != null
          ? String.valueOf(currentUserAttendance.CheckInTime__c).substring(0, 5)
          : '';
        currentCheckOutTime = currentUserAttendance.CheckOutTime__c != null
          ? String.valueOf(currentUserAttendance.CheckOutTime__c)
              .substring(0, 5)
          : '';
      }
    }
  }

  // ===== Action Methods =====
  public void searchAttendance() {
    loadAttendanceList();
  }

  public void clearSearch() {
    searchKeyword = '';
    filterDepartment = '';
    filterStatus = '';
    loadAttendanceList();
  }

  public void checkIn() {
    try {
      Date today = Date.today();
      Id currentUserId = UserInfo.getUserId();

      List<JIP_Worker__c> workers = [
        SELECT Id
        FROM JIP_Worker__c
        WHERE User__c = :currentUserId
        LIMIT 1
      ];

      if (!workers.isEmpty()) {
        // Check if attendance record exists
        List<JIP_Attendance__c> existingAtt = [
          SELECT Id, AuditLog__c
          FROM JIP_Attendance__c
          WHERE Worker__c = :workers[0].Id AND AttendanceDate__c = :today
          LIMIT 1
        ];

        String auditEntry =
          'CheckIn: ' +
          String.valueOf(Datetime.now()) +
          ' | GPS: ' +
          gpsLocation +
          ' | IP: ' +
          ipAddress +
          ' | Device: ' +
          deviceType;

        JIP_Attendance__c att;
        if (existingAtt.isEmpty()) {
          att = new JIP_Attendance__c(
            Worker__c = workers[0].Id,
            AttendanceDate__c = today,
            CheckInTime__c = Datetime.now(),
            Status__c = '出勤',
            GPS_Location__c = gpsLocation,
            IP_Address__c = ipAddress,
            Device__c = deviceType,
            AuditLog__c = auditEntry
          );
          insert att;
        } else {
          att = existingAtt[0];
          att.CheckInTime__c = Datetime.now();
          att.Status__c = '出勤';
          att.GPS_Location__c = gpsLocation;
          att.IP_Address__c = ipAddress;
          att.Device__c = deviceType;
          att.AuditLog__c =
            (att.AuditLog__c == null ? '' : att.AuditLog__c + '\n') +
            auditEntry;
          update att;
        }

        loadCurrentUserAttendance();
        loadStatistics();
        loadAttendanceList();

        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            getT().get('check_in') + ' ' + getT().get('completed')
          )
        );
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            '社員情報が見つかりません。管理者にWorkerレコードの作成を依頼してください。'
          )
        );
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void checkOut() {
    try {
      Date today = Date.today();
      Id currentUserId = UserInfo.getUserId();

      List<JIP_Worker__c> workers = [
        SELECT Id
        FROM JIP_Worker__c
        WHERE User__c = :currentUserId
        LIMIT 1
      ];

      if (!workers.isEmpty()) {
        List<JIP_Attendance__c> existingAtt = [
          SELECT Id, CheckInTime__c, AuditLog__c, BreakMinutes__c
          FROM JIP_Attendance__c
          WHERE Worker__c = :workers[0].Id AND AttendanceDate__c = :today
          LIMIT 1
        ];

        if (!existingAtt.isEmpty()) {
          Datetime checkOutTime = Datetime.now();
          String auditEntry =
            'CheckOut: ' +
            String.valueOf(checkOutTime) +
            ' | GPS: ' +
            gpsLocation +
            ' | IP: ' +
            ipAddress +
            ' | Device: ' +
            deviceType;

          existingAtt[0].CheckOutTime__c = checkOutTime;
          existingAtt[0].GPS_Location__c = gpsLocation;
          existingAtt[0].IP_Address__c = ipAddress;
          existingAtt[0].Device__c = deviceType;
          existingAtt[0].AuditLog__c =
            (existingAtt[0].AuditLog__c == null
              ? ''
              : existingAtt[0].AuditLog__c + '\n') + auditEntry;

          // Calculate working hours and overtime
          if (existingAtt[0].CheckInTime__c != null) {
            Decimal breakMinutes = existingAtt[0].BreakMinutes__c != null
              ? existingAtt[0].BreakMinutes__c
              : 60;
            Long diffMs =
              checkOutTime.getTime() - existingAtt[0].CheckInTime__c.getTime();
            Decimal totalMinutes = diffMs / 60000;
            Decimal netMinutes = totalMinutes - breakMinutes;
            Decimal workingHours = netMinutes / 60;
            existingAtt[0].WorkingHours__c = workingHours.setScale(2);

            // Overtime calculation (標準8時間超過分)
            Decimal standardHours = 8.0;
            if (workingHours > standardHours) {
              existingAtt[0].OvertimeHours__c = (workingHours - standardHours)
                .setScale(2);
            } else {
              existingAtt[0].OvertimeHours__c = 0;
            }

            // Update status
            existingAtt[0].Status__c = '退勤済';
          }

          update existingAtt[0];

          loadCurrentUserAttendance();
          loadStatistics();
          loadAttendanceList();

          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.CONFIRM,
              getT().get('check_out') + ' ' + getT().get('completed')
            )
          );
        }
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void changeLanguage() {
    // Language is already bound to the property
  }

  // ===== Select Options =====
  public List<SelectOption> getDepartmentOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', getT().get('all')));

    // Get unique departments
    Set<String> departments = new Set<String>();
    for (JIP_Worker__c w : [
      SELECT Department__c
      FROM JIP_Worker__c
      WHERE Department__c != NULL
    ]) {
      departments.add(w.Department__c);
    }

    for (String dept : departments) {
      options.add(new SelectOption(dept, dept));
    }

    return options;
  }

  public List<SelectOption> getStatusOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', getT().get('all')));
    options.add(new SelectOption('出勤', getT().get('working')));
    options.add(new SelectOption('有給休暇', getT().get('paid_leave')));
    options.add(new SelectOption('遅刻', getT().get('late')));
    return options;
  }

  public List<SelectOption> getLanguageOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('ja', '日本語'));
    options.add(new SelectOption('en', 'English'));
    return options;
  }

  // ===== Export Attendance Report (CSV) =====
  public PageReference exportAttendanceReport() {
    return Page.JIP_AttendanceExport;
  }

  // ===== Export Monthly Report (Excel) =====
  public PageReference exportMonthlyReport() {
    return Page.JIP_AttendanceMonthlyReport;
  }

  // ===== Schedule Management Methods =====
  private void loadWeeklySchedule() {
    weeklySchedule = new List<ScheduleWrapper>();
    Id currentUserId = UserInfo.getUserId();

    List<JIP_Worker__c> workers = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE User__c = :currentUserId
      LIMIT 1
    ];
    if (workers.isEmpty())
      return;

    Date weekStart = Date.today().toStartOfWeek();
    Date weekEnd = weekStart.addDays(6);

    List<JIP_WorkSchedule__c> schedules = [
      SELECT
        Id,
        ScheduleDate__c,
        ShiftType__c,
        StartTime__c,
        EndTime__c,
        BreakTime__c,
        Notes__c
      FROM JIP_WorkSchedule__c
      WHERE
        Worker__c = :workers[0].Id
        AND ScheduleDate__c >= :weekStart
        AND ScheduleDate__c <= :weekEnd
      ORDER BY ScheduleDate__c ASC
    ];

    // Create map for quick lookup
    Map<Date, JIP_WorkSchedule__c> scheduleMap = new Map<Date, JIP_WorkSchedule__c>();
    for (JIP_WorkSchedule__c sch : schedules) {
      scheduleMap.put(sch.ScheduleDate__c, sch);
    }

    // Build weekly schedule (always 7 days)
    for (Integer i = 0; i < 7; i++) {
      Date d = weekStart.addDays(i);
      JIP_WorkSchedule__c sch = scheduleMap.get(d);
      weeklySchedule.add(new ScheduleWrapper(d, sch));
    }
  }

  public void saveSchedule() {
    try {
      // Copy values from properties
      newSchedule.ScheduleDate__c = scheduleDate;
      newSchedule.BreakTime__c = scheduleBreakTime;

      // Convert String time to Time object
      if (String.isNotBlank(scheduleStartTime)) {
        List<String> parts = scheduleStartTime.split(':');
        if (parts.size() >= 2) {
          newSchedule.StartTime__c = Time.newInstance(
            Integer.valueOf(parts[0]),
            Integer.valueOf(parts[1]),
            0,
            0
          );
        }
      }
      if (String.isNotBlank(scheduleEndTime)) {
        List<String> parts = scheduleEndTime.split(':');
        if (parts.size() >= 2) {
          newSchedule.EndTime__c = Time.newInstance(
            Integer.valueOf(parts[0]),
            Integer.valueOf(parts[1]),
            0,
            0
          );
        }
      }

      if (newSchedule != null && newSchedule.ScheduleDate__c != null) {
        Id currentUserId = UserInfo.getUserId();
        List<JIP_Worker__c> workers = [
          SELECT Id
          FROM JIP_Worker__c
          WHERE User__c = :currentUserId
          LIMIT 1
        ];

        if (!workers.isEmpty()) {
          newSchedule.Worker__c = workers[0].Id;
          upsert newSchedule;
          loadWeeklySchedule();
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.CONFIRM,
              'スケジュールを保存しました'
            )
          );
        }
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  // ===== Schedule Edit Methods =====
  private void initNewSchedule() {
    newSchedule = new JIP_WorkSchedule__c();
    newSchedule.ShiftType__c = '日勤';
    newSchedule.BreakTime__c = 60;
    scheduleDate = null;
    scheduleStartTime = '09:00';
    scheduleEndTime = '18:00';
    scheduleBreakTime = 60;
  }

  public void editScheduleForDate() {
    try {
      if (String.isNotBlank(selectedScheduleDate)) {
        Date schedDate = Date.valueOf(selectedScheduleDate);
        scheduleDate = schedDate;
        Id currentUserId = UserInfo.getUserId();
        List<JIP_Worker__c> workers = [
          SELECT Id
          FROM JIP_Worker__c
          WHERE User__c = :currentUserId
          LIMIT 1
        ];

        if (!workers.isEmpty()) {
          List<JIP_WorkSchedule__c> existing = [
            SELECT
              Id,
              ScheduleDate__c,
              ShiftType__c,
              StartTime__c,
              EndTime__c,
              BreakTime__c,
              Notes__c
            FROM JIP_WorkSchedule__c
            WHERE Worker__c = :workers[0].Id AND ScheduleDate__c = :schedDate
            LIMIT 1
          ];

          if (!existing.isEmpty()) {
            newSchedule = existing[0];
            scheduleDate = newSchedule.ScheduleDate__c;
            // Convert Time to String for display
            if (newSchedule.StartTime__c != null) {
              Integer hours = newSchedule.StartTime__c.hour();
              Integer mins = newSchedule.StartTime__c.minute();
              scheduleStartTime =
                String.valueOf(hours).leftPad(2, '0') +
                ':' +
                String.valueOf(mins).leftPad(2, '0');
            }
            if (newSchedule.EndTime__c != null) {
              Integer hours = newSchedule.EndTime__c.hour();
              Integer mins = newSchedule.EndTime__c.minute();
              scheduleEndTime =
                String.valueOf(hours).leftPad(2, '0') +
                ':' +
                String.valueOf(mins).leftPad(2, '0');
            }
            scheduleBreakTime = newSchedule.BreakTime__c;
          } else {
            initNewSchedule();
            scheduleDate = schedDate;
            newSchedule.ScheduleDate__c = schedDate;
          }
        }
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  // ===== Leave Request Methods =====
  private void initNewLeaveRequest() {
    newLeaveRequest = new JIP_LeaveRequest__c();
    newLeaveRequest.RequestType__c = '有給休暇';
    newLeaveRequest.Status__c = '下書き';
    requestStartDate = null;
    requestEndDate = null;
    requestOvertimeHours = null;
  }

  private void loadApproverOptions() {
    approverOptions = new List<SelectOption>();
    approverOptions.add(new SelectOption('', '-- 承認者を選択 --'));

    // Get managers and HR staff as potential approvers
    for (User u : [
      SELECT Id, Name
      FROM User
      WHERE
        IsActive = TRUE
        AND (Profile.Name LIKE '%Manager%'
        OR Profile.Name LIKE '%Admin%'
        OR Profile.Name LIKE '%HR%')
      ORDER BY Name
      LIMIT 50
    ]) {
      approverOptions.add(new SelectOption(u.Id, u.Name));
    }

    // If no managers found, get all active users
    if (approverOptions.size() == 1) {
      for (User u : [
        SELECT Id, Name
        FROM User
        WHERE IsActive = TRUE
        ORDER BY Name
        LIMIT 50
      ]) {
        approverOptions.add(new SelectOption(u.Id, u.Name));
      }
    }
  }

  private void loadPendingRequests() {
    pendingRequests = new List<LeaveRequestWrapper>();
    Id currentUserId = UserInfo.getUserId();

    // Check if current user is an approver for any requests
    List<JIP_LeaveRequest__c> requests = [
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
      WHERE
        (Approver1__c = :currentUserId
        OR Approver2__c = :currentUserId)
        AND Status__c IN ('申請中', '承認待ち(上司)', '承認待ち(管理者)')
      ORDER BY SubmittedDate__c DESC
      LIMIT 50
    ];

    for (JIP_LeaveRequest__c req : requests) {
      pendingRequests.add(new LeaveRequestWrapper(req));
    }
  }

  private void loadMyRequests() {
    myRequests = new List<LeaveRequestWrapper>();
    Id currentUserId = UserInfo.getUserId();

    List<JIP_Worker__c> workers = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE User__c = :currentUserId
      LIMIT 1
    ];
    if (workers.isEmpty())
      return;

    List<JIP_LeaveRequest__c> requests = [
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
        SubmittedDate__c,
        ApprovalDate1__c,
        ApprovalDate2__c,
        ApproverComment1__c,
        ApproverComment2__c
      FROM JIP_LeaveRequest__c
      WHERE Applicant__c = :workers[0].Id
      ORDER BY CreatedDate DESC
      LIMIT 50
    ];

    for (JIP_LeaveRequest__c req : requests) {
      myRequests.add(new LeaveRequestWrapper(req));
    }
  }

  public void submitLeaveRequest() {
    try {
      if (newLeaveRequest == null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            '申請内容を入力してください'
          )
        );
        return;
      }

      // Copy date values from input properties
      newLeaveRequest.StartDate__c = requestStartDate;
      newLeaveRequest.EndDate__c = requestEndDate;
      newLeaveRequest.OvertimeHours__c = requestOvertimeHours;

      // Validation
      if (newLeaveRequest.StartDate__c == null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            '開始日を入力してください'
          )
        );
        return;
      }
      if (newLeaveRequest.Approver1__c == null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            '承認者を選択してください'
          )
        );
        return;
      }
      if (String.isBlank(newLeaveRequest.Reason__c)) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            '理由を入力してください'
          )
        );
        return;
      }

      Id currentUserId = UserInfo.getUserId();
      List<JIP_Worker__c> workers = [
        SELECT Id, Department__c
        FROM JIP_Worker__c
        WHERE User__c = :currentUserId
        LIMIT 1
      ];

      if (workers.isEmpty()) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            '社員情報が見つかりません。管理者に連絡してください。'
          )
        );
        return;
      }

      newLeaveRequest.Applicant__c = workers[0].Id;
      newLeaveRequest.Status__c = '承認待ち(上司)';
      newLeaveRequest.SubmittedDate__c = Datetime.now();

      // If second approver is set, will go to them after first approval
      // Approver1__c is already set from the form

      insert newLeaveRequest;

      initNewLeaveRequest();
      loadMyRequests();
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.CONFIRM, '申請を提出しました')
      );
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void approveRequest() {
    try {
      if (String.isBlank(selectedRequestId))
        return;

      JIP_LeaveRequest__c req = [
        SELECT
          Id,
          Status__c,
          Approver1__c,
          Approver2__c,
          ApprovalDate1__c,
          ApprovalDate2__c
        FROM JIP_LeaveRequest__c
        WHERE Id = :selectedRequestId
        LIMIT 1
      ];

      Id currentUserId = UserInfo.getUserId();

      if (
        req.Status__c == '承認待ち(上司)' &&
        req.Approver1__c == currentUserId
      ) {
        req.ApprovalDate1__c = Datetime.now();
        req.ApproverComment1__c = approverComment;

        // Check if needs second level approval
        if (req.Approver2__c != null) {
          req.Status__c = '承認待ち(管理者)';
        } else {
          req.Status__c = '承認済';
        }
      } else if (
        req.Status__c == '承認待ち(管理者)' &&
        req.Approver2__c == currentUserId
      ) {
        req.ApprovalDate2__c = Datetime.now();
        req.ApproverComment2__c = approverComment;
        req.Status__c = '承認済';
      }

      update req;
      approverComment = '';
      loadPendingRequests();
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.CONFIRM, '承認しました')
      );
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void rejectRequest() {
    try {
      if (String.isBlank(selectedRequestId))
        return;

      JIP_LeaveRequest__c req = [
        SELECT Id, Status__c, Approver1__c, Approver2__c
        FROM JIP_LeaveRequest__c
        WHERE Id = :selectedRequestId
        LIMIT 1
      ];

      Id currentUserId = UserInfo.getUserId();

      if (req.Approver1__c == currentUserId) {
        req.ApproverComment1__c = approverComment;
      } else if (req.Approver2__c == currentUserId) {
        req.ApproverComment2__c = approverComment;
      }

      req.Status__c = '却下';
      update req;

      approverComment = '';
      loadPendingRequests();
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.WARNING, '申請を却下しました')
      );
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void cancelMyRequest() {
    try {
      if (String.isBlank(selectedRequestId))
        return;

      JIP_LeaveRequest__c req = [
        SELECT Id, Status__c
        FROM JIP_LeaveRequest__c
        WHERE Id = :selectedRequestId
        LIMIT 1
      ];

      if (
        req.Status__c == '下書き' ||
        req.Status__c == '申請中' ||
        req.Status__c.startsWith('承認待ち')
      ) {
        req.Status__c = '取消';
        update req;
        loadMyRequests();
        ApexPages.addMessage(
          new ApexPages.Message(ApexPages.Severity.INFO, '申請を取消しました')
        );
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'この申請は取消できません'
          )
        );
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public List<SelectOption> getRequestTypeOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('有給休暇', '有給休暇'));
    options.add(new SelectOption('半休(午前)', '半休(午前)'));
    options.add(new SelectOption('半休(午後)', '半休(午後)'));
    options.add(new SelectOption('特別休暇', '特別休暇'));
    options.add(new SelectOption('欠勤', '欠勤'));
    options.add(new SelectOption('残業申請', '残業申請'));
    options.add(new SelectOption('休日出勤', '休日出勤'));
    options.add(new SelectOption('遅刻', '遅刻'));
    options.add(new SelectOption('早退', '早退'));
    options.add(new SelectOption('打刻修正', '打刻修正'));
    return options;
  }

  public List<SelectOption> getShiftTypeOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('日勤', '日勤'));
    options.add(new SelectOption('夜勤', '夜勤'));
    options.add(new SelectOption('早番', '早番'));
    options.add(new SelectOption('遅番', '遅番'));
    options.add(new SelectOption('フレックス', 'フレックス'));
    options.add(new SelectOption('休日', '休日'));
    return options;
  }

  // ===== Wrapper Classes =====
  public class AttendanceWrapper {
    public JIP_Attendance__c record { get; set; }
    public String employeeName { get; set; }
    public String departmentName { get; set; }
    public String checkInTime { get; set; }
    public String checkOutTime { get; set; }
    public Decimal workingHours { get; set; }
    public Decimal overtimeHours { get; set; }
    public String status { get; set; }
    public String statusClass { get; set; }

    public AttendanceWrapper(JIP_Attendance__c att) {
      this.record = att;
      this.employeeName = att.Worker__r != null
        ? (att.Worker__r.LastName__c != null
            ? att.Worker__r.LastName__c + ' '
            : '') +
          (att.Worker__r.FirstName__c != null
            ? att.Worker__r.FirstName__c
            : att.Worker__r.Name)
        : '';
      this.departmentName = att.Worker__r != null &&
        att.Worker__r.Department__r != null
        ? att.Worker__r.Department__r.Name
        : '-';
      this.checkInTime = att.CheckInTime__c != null
        ? att.CheckInTime__c.format('HH:mm')
        : '-';
      this.checkOutTime = att.CheckOutTime__c != null
        ? att.CheckOutTime__c.format('HH:mm')
        : '-';
      this.workingHours = att.WorkingHours__c != null ? att.WorkingHours__c : 0;
      this.overtimeHours = att.OvertimeHours__c != null
        ? att.OvertimeHours__c
        : 0;

      if (att.Status__c == '有給休暇') {
        this.status = '有給';
        this.statusClass = 'status-leave';
      } else if (att.IsLate__c == true) {
        this.status = '遅刻';
        this.statusClass = 'status-late';
      } else if (att.CheckInTime__c != null && att.CheckOutTime__c == null) {
        this.status = '出勤中';
        this.statusClass = 'status-working';
      } else if (att.CheckOutTime__c != null) {
        this.status = '退勤済';
        this.statusClass = 'status-completed';
      } else {
        this.status = '未出勤';
        this.statusClass = 'status-absent';
      }
    }
  }

  public class LeaveBalanceWrapper {
    public String leaveType { get; set; }
    public Decimal total { get; set; }
    public Decimal totalDays { get; set; }
    public Decimal used { get; set; }
    public Decimal usedDays { get; set; }
    public Decimal remaining { get; set; }
    public Decimal usagePercent { get; set; }

    public LeaveBalanceWrapper(String leaveType, Decimal total, Decimal used) {
      this.leaveType = leaveType;
      this.total = total;
      this.totalDays = total;
      this.used = used;
      this.usedDays = used;
      this.remaining = total - used;
      this.usagePercent = total > 0 ? (used / total) * 100 : 0;
    }
  }

  public class StatsWrapper {
    public Integer workingCount { get; set; }
    public Integer notCheckedInCount { get; set; }
    public Integer onLeaveCount { get; set; }
    public Integer lateCount { get; set; }
    public Decimal monthlyOvertimeHours { get; set; }

    public StatsWrapper() {
      this.workingCount = 0;
      this.notCheckedInCount = 0;
      this.onLeaveCount = 0;
      this.lateCount = 0;
      this.monthlyOvertimeHours = 0;
    }
  }

  public class ScheduleWrapper {
    public Date scheduleDate { get; set; }
    public String dayOfWeek { get; set; }
    public String shiftType { get; set; }
    public String startTime { get; set; }
    public String endTime { get; set; }
    public Integer breakMinutes { get; set; }
    public String notes { get; set; }
    public Boolean isToday { get; set; }
    public Boolean isWeekend { get; set; }
    public Id scheduleId { get; set; }

    public ScheduleWrapper(Date d, JIP_WorkSchedule__c sch) {
      this.scheduleDate = d;
      this.isToday = d == Date.today();

      // Get day of week (Japanese)
      Integer dow = Math.mod(Date.newInstance(1900, 1, 7).daysBetween(d), 7);
      List<String> weekDays = new List<String>{
        '日',
        '月',
        '火',
        '水',
        '木',
        '金',
        '土'
      };
      this.dayOfWeek = weekDays[dow];
      this.isWeekend = (dow == 0 || dow == 6);

      if (sch != null) {
        this.scheduleId = sch.Id;
        this.shiftType = sch.ShiftType__c;
        this.startTime = sch.StartTime__c != null
          ? String.valueOf(sch.StartTime__c).substring(0, 5)
          : '-';
        this.endTime = sch.EndTime__c != null
          ? String.valueOf(sch.EndTime__c).substring(0, 5)
          : '-';
        this.breakMinutes = sch.BreakTime__c != null
          ? Integer.valueOf(sch.BreakTime__c)
          : 60;
        this.notes = sch.Notes__c;
      } else {
        this.shiftType = isWeekend ? '休日' : '-';
        this.startTime = '-';
        this.endTime = '-';
        this.breakMinutes = 60;
        this.notes = '';
      }
    }
  }

  public class LeaveRequestWrapper {
    public JIP_LeaveRequest__c record { get; set; }
    public String applicantName { get; set; }
    public String requestType { get; set; }
    public String dateRange { get; set; }
    public String status { get; set; }
    public String statusClass { get; set; }
    public String reason { get; set; }
    public Decimal overtimeHours { get; set; }
    public String submittedDate { get; set; }

    public LeaveRequestWrapper(JIP_LeaveRequest__c req) {
      this.record = req;

      if (req.Applicant__r != null) {
        this.applicantName =
          (req.Applicant__r.LastName__c != null
            ? req.Applicant__r.LastName__c + ' '
            : '') +
          (req.Applicant__r.FirstName__c != null
            ? req.Applicant__r.FirstName__c
            : req.Applicant__r.Name);
      } else {
        this.applicantName = '-';
      }

      this.requestType = req.RequestType__c;
      this.reason = req.Reason__c != null ? req.Reason__c : '';
      this.overtimeHours = req.OvertimeHours__c;

      // Format date range
      if (
        req.StartDate__c != null &&
        req.EndDate__c != null &&
        req.StartDate__c != req.EndDate__c
      ) {
        this.dateRange =
          String.valueOf(req.StartDate__c) +
          ' ～ ' +
          String.valueOf(req.EndDate__c);
      } else if (req.StartDate__c != null) {
        this.dateRange = String.valueOf(req.StartDate__c);
      } else {
        this.dateRange = '-';
      }

      this.submittedDate = req.SubmittedDate__c != null
        ? req.SubmittedDate__c.format('yyyy/MM/dd HH:mm')
        : '-';
      this.status = req.Status__c;

      // Status styling
      if (req.Status__c == '承認済') {
        this.statusClass = 'status-approved';
      } else if (req.Status__c == '却下') {
        this.statusClass = 'status-rejected';
      } else if (req.Status__c == '取消') {
        this.statusClass = 'status-cancelled';
      } else if (req.Status__c.startsWith('承認待ち')) {
        this.statusClass = 'status-pending';
      } else {
        this.statusClass = 'status-draft';
      }
    }
  }

  // ===== Daily Work Detail Wrappers =====
  public class DailyDetailWrapper {
    public Date workDate { get; set; }
    public String workDateFormatted { get; set; }
    public String status { get; set; }
    public String checkInTime { get; set; }
    public String checkOutTime { get; set; }
    public Decimal breakMinutes { get; set; }
    public Decimal workingHours { get; set; }
    public String notes { get; set; }
    public Id attendanceId { get; set; }

    public DailyDetailWrapper(Date d, JIP_Attendance__c att) {
      this.workDate = d;
      this.workDateFormatted = d.format();
      if (att != null) {
        this.attendanceId = att.Id;
        this.status = att.Status__c != null ? att.Status__c : '未出勤';
        this.checkInTime = att.CheckInTime__c != null
          ? att.CheckInTime__c.format('HH:mm')
          : '';
        this.checkOutTime = att.CheckOutTime__c != null
          ? att.CheckOutTime__c.format('HH:mm')
          : '';
        this.breakMinutes = att.BreakMinutes__c != null
          ? att.BreakMinutes__c
          : 60;
        this.workingHours = att.WorkingHours__c != null
          ? att.WorkingHours__c
          : 0;
        this.notes = att.Notes__c != null ? att.Notes__c : '';
      } else {
        this.status = '未出勤';
        this.checkInTime = '';
        this.checkOutTime = '';
        this.breakMinutes = 60;
        this.workingHours = 0;
        this.notes = '';
      }
    }
  }

  public class WorkEntryWrapper {
    public Id entryId { get; set; }
    public Integer rowNumber { get; set; }
    public String projectCode { get; set; }
    public String projectName { get; set; }
    public Id projectId { get; set; }
    public String workHours { get; set; }
    public Decimal workHoursDecimal { get; set; }
    public String comment { get; set; }

    public WorkEntryWrapper(JIP_DailyWorkEntry__c entry, Integer num) {
      this.entryId = entry.Id;
      this.rowNumber = num;
      this.projectId = entry.Project__c;
      this.projectCode = entry.Project__r != null &&
        entry.Project__r.Name != null
        ? entry.Project__r.Name
        : '-';
      this.projectName = entry.Project__r != null &&
        entry.Project__r.Name__c != null
        ? entry.Project__r.Name__c
        : '-';
      this.workHoursDecimal = entry.WorkHours__c != null
        ? entry.WorkHours__c
        : 0;
      // Format hours as HH:mm
      Integer hours = (Integer) Math.floor(this.workHoursDecimal);
      Integer mins = (Integer) Math.round((this.workHoursDecimal - hours) * 60);
      this.workHours =
        String.valueOf(hours) +
        ':' +
        String.valueOf(mins).leftPad(2, '0');
      this.comment = entry.Comment__c != null ? entry.Comment__c : '';
    }
  }

  public class BreakEntryWrapper {
    public String startTime { get; set; }
    public String endTime { get; set; }
    public String breakType { get; set; }
    public String reason { get; set; }
    public String duration { get; set; }

    public BreakEntryWrapper(
      String startVal,
      String endVal,
      String bType,
      String rsn,
      String dur
    ) {
      this.startTime = startVal;
      this.endTime = endVal;
      this.breakType = bType;
      this.reason = rsn;
      this.duration = dur;
    }
  }

  // ===== Daily Work Methods =====
  private void loadProjectOptions() {
    projectOptions = new List<SelectOption>();
    projectOptions.add(new SelectOption('', '-- 案件を選択 --'));

    // Load all active projects from database
    for (JIP_Project__c proj : [
      SELECT Id, Name, Name__c
      FROM JIP_Project__c
      WHERE Status__c IN ('Active', 'New', '進行中')
      ORDER BY Name__c ASC
      LIMIT 100
    ]) {
      String label =
        proj.Name + (proj.Name__c != null ? ' - ' + proj.Name__c : '');
      projectOptions.add(new SelectOption(proj.Id, label));
    }
  }

  private void loadStatusOptions() {
    statusOptions = new List<SelectOption>();
    statusOptions.add(new SelectOption('出勤', '出勤'));
    statusOptions.add(new SelectOption('退勤済', '退勤済'));
    statusOptions.add(new SelectOption('有給休暇', '有給休暇'));
    statusOptions.add(new SelectOption('欠勤', '欠勤'));
    statusOptions.add(new SelectOption('遅刻', '遅刻'));
    statusOptions.add(new SelectOption('早退', '早退'));
  }

  private void loadDailyDetail() {
    if (selectedWorkDate == null) {
      selectedWorkDate = Date.today();
    }

    Id currentUserId = UserInfo.getUserId();
    List<JIP_Worker__c> workers = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE User__c = :currentUserId
      LIMIT 1
    ];

    if (workers.isEmpty()) {
      dailyDetail = new DailyDetailWrapper(selectedWorkDate, null);
      workEntries = new List<WorkEntryWrapper>();
      breakEntries = new List<BreakEntryWrapper>();
      return;
    }

    Id workerId = workers[0].Id;

    // Load attendance for selected date
    List<JIP_Attendance__c> attendances = [
      SELECT
        Id,
        Status__c,
        CheckInTime__c,
        CheckOutTime__c,
        BreakMinutes__c,
        WorkingHours__c,
        Notes__c
      FROM JIP_Attendance__c
      WHERE Worker__c = :workerId AND AttendanceDate__c = :selectedWorkDate
      LIMIT 1
    ];

    JIP_Attendance__c att = attendances.isEmpty() ? null : attendances[0];
    dailyDetail = new DailyDetailWrapper(selectedWorkDate, att);
    dailyComment = dailyDetail.notes;

    // Load work entries for selected date
    workEntries = new List<WorkEntryWrapper>();
    Integer rowNum = 1;
    for (JIP_DailyWorkEntry__c entry : [
      SELECT
        Id,
        Project__c,
        Project__r.Name,
        Project__r.Name__c,
        WorkHours__c,
        Comment__c
      FROM JIP_DailyWorkEntry__c
      WHERE Worker__c = :workerId AND WorkDate__c = :selectedWorkDate
      ORDER BY CreatedDate ASC
    ]) {
      workEntries.add(new WorkEntryWrapper(entry, rowNum++));
    }

    // Load break entries (dummy/standard for now)
    breakEntries = new List<BreakEntryWrapper>();
    breakEntries.add(
      new BreakEntryWrapper('12:00', '13:00', '休憩', '規定の休憩', '1:00')
    );
  }

  public void selectWorkDate() {
    // Convert string to Date
    if (String.isNotBlank(selectedWorkDateStr)) {
      try {
        selectedWorkDate = Date.valueOf(selectedWorkDateStr);
      } catch (Exception e) {
        // Keep current date if conversion fails
      }
    }

    // Update calendar month if selected date is in a different month
    if (selectedWorkDate != null) {
      Date selectedMonth = selectedWorkDate.toStartOfMonth();
      if (selectedMonth != calendarMonth) {
        calendarMonth = selectedMonth;
      }
    }
    loadDailyDetail();
    loadCalendar();
  }

  public void saveWorkEntry() {
    try {
      if (String.isBlank(newProjectId)) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            '案件を選択してください'
          )
        );
        return;
      }

      Id currentUserId = UserInfo.getUserId();
      List<JIP_Worker__c> workers = [
        SELECT Id
        FROM JIP_Worker__c
        WHERE User__c = :currentUserId
        LIMIT 1
      ];

      if (workers.isEmpty()) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            '社員情報が見つかりません'
          )
        );
        return;
      }

      // Parse work hours (format: HH:mm or decimal)
      Decimal hours = 0;
      if (String.isNotBlank(newWorkHours)) {
        if (newWorkHours.contains(':')) {
          List<String> parts = newWorkHours.split(':');
          hours = Decimal.valueOf(parts[0]) + (Decimal.valueOf(parts[1]) / 60);
        } else {
          hours = Decimal.valueOf(newWorkHours);
        }
      }

      JIP_DailyWorkEntry__c entry = new JIP_DailyWorkEntry__c(
        Worker__c = workers[0].Id,
        WorkDate__c = selectedWorkDate,
        Project__c = newProjectId,
        WorkHours__c = hours,
        Comment__c = newWorkComment
      );

      // Link to attendance if exists
      if (dailyDetail != null && dailyDetail.attendanceId != null) {
        entry.Attendance__c = dailyDetail.attendanceId;
      }

      insert entry;

      // Clear inputs
      newProjectId = '';
      newWorkHours = '';
      newWorkComment = '';

      loadDailyDetail();
      loadCalendar();
      loadMonthlyProjectSummary();
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          '作業実績を保存しました'
        )
      );
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void deleteWorkEntry() {
    try {
      if (String.isNotBlank(selectedWorkEntryId)) {
        delete [
          SELECT Id
          FROM JIP_DailyWorkEntry__c
          WHERE Id = :selectedWorkEntryId
        ];
        loadDailyDetail();
        loadCalendar();
        loadMonthlyProjectSummary();
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            '作業実績を削除しました'
          )
        );
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void saveDailyComment() {
    try {
      if (dailyDetail != null && dailyDetail.attendanceId != null) {
        JIP_Attendance__c att = [
          SELECT Id, Notes__c
          FROM JIP_Attendance__c
          WHERE Id = :dailyDetail.attendanceId
        ];
        att.Notes__c = dailyComment;
        update att;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            'コメントを保存しました'
          )
        );
      } else {
        // Create attendance record if not exists
        Id currentUserId = UserInfo.getUserId();
        List<JIP_Worker__c> workers = [
          SELECT Id
          FROM JIP_Worker__c
          WHERE User__c = :currentUserId
          LIMIT 1
        ];
        if (!workers.isEmpty()) {
          JIP_Attendance__c att = new JIP_Attendance__c(
            Worker__c = workers[0].Id,
            AttendanceDate__c = selectedWorkDate,
            Notes__c = dailyComment
          );
          insert att;
          loadDailyDetail();
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.CONFIRM,
              'コメントを保存しました'
            )
          );
        }
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void stampCheckIn() {
    try {
      Id currentUserId = UserInfo.getUserId();
      List<JIP_Worker__c> workers = [
        SELECT Id
        FROM JIP_Worker__c
        WHERE User__c = :currentUserId
        LIMIT 1
      ];

      if (workers.isEmpty()) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            '社員情報が見つかりません'
          )
        );
        return;
      }

      // Check existing
      List<JIP_Attendance__c> existing = [
        SELECT Id, AuditLog__c
        FROM JIP_Attendance__c
        WHERE
          Worker__c = :workers[0].Id
          AND AttendanceDate__c = :selectedWorkDate
        LIMIT 1
      ];

      JIP_Attendance__c att;
      if (existing.isEmpty()) {
        att = new JIP_Attendance__c(
          Worker__c = workers[0].Id,
          AttendanceDate__c = selectedWorkDate,
          CheckInTime__c = Datetime.now(),
          Status__c = '出勤'
        );
        insert att;
      } else {
        att = existing[0];
        att.CheckInTime__c = Datetime.now();
        att.Status__c = '出勤';
        update att;
      }

      loadDailyDetail();
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.CONFIRM, '出勤を打刻しました')
      );
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void stampCheckOut() {
    try {
      if (dailyDetail == null || dailyDetail.attendanceId == null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            '出勤記録がありません'
          )
        );
        return;
      }

      JIP_Attendance__c att = [
        SELECT Id, CheckInTime__c, BreakMinutes__c
        FROM JIP_Attendance__c
        WHERE Id = :dailyDetail.attendanceId
      ];
      att.CheckOutTime__c = Datetime.now();
      att.Status__c = '退勤済';

      // Calculate working hours
      if (att.CheckInTime__c != null) {
        Decimal breakMins = att.BreakMinutes__c != null
          ? att.BreakMinutes__c
          : 60;
        Long diffMs = Datetime.now().getTime() - att.CheckInTime__c.getTime();
        Decimal totalMins = diffMs / 60000;
        Decimal netMins = totalMins - breakMins;
        att.WorkingHours__c = (netMins / 60).setScale(2);
      }

      update att;
      loadDailyDetail();
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.CONFIRM, '退勤を打刻しました')
      );
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void updateDailyStatus() {
    try {
      if (dailyDetail != null && dailyDetail.attendanceId != null) {
        JIP_Attendance__c att = [
          SELECT Id
          FROM JIP_Attendance__c
          WHERE Id = :dailyDetail.attendanceId
        ];
        att.Status__c = dailyDetail.status;
        update att;
        loadDailyDetail();
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void updateBreakTime() {
    try {
      if (dailyDetail != null && dailyDetail.attendanceId != null) {
        JIP_Attendance__c att = [
          SELECT Id
          FROM JIP_Attendance__c
          WHERE Id = :dailyDetail.attendanceId
        ];
        att.BreakMinutes__c = dailyDetail.breakMinutes;
        update att;
        loadDailyDetail();
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  // ===== Calendar Methods =====
  private void loadCalendar() {
    calendarWeeks = new List<List<CalendarDayWrapper>>();

    // Format month label (e.g., "2026年03月")
    calendarMonthLabel =
      calendarMonth.year() +
      '年' +
      String.valueOf(calendarMonth.month()).leftPad(2, '0') +
      '月';

    // Get first day of month
    Date firstOfMonth = calendarMonth.toStartOfMonth();

    // Find Sunday of the week containing the first day
    Integer dayOfWeek = Math.mod(
      Date.newInstance(1900, 1, 7).daysBetween(firstOfMonth),
      7
    );
    Date calendarStart = firstOfMonth.addDays(-dayOfWeek);

    // Get dates with work entries for current user
    Set<Date> datesWithEntries = new Set<Date>();
    Id currentUserId = UserInfo.getUserId();
    List<JIP_Worker__c> workers = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE User__c = :currentUserId
      LIMIT 1
    ];
    if (!workers.isEmpty()) {
      Date monthStart = calendarMonth.toStartOfMonth();
      Date monthEnd = monthStart.addMonths(1).addDays(-1);
      for (JIP_DailyWorkEntry__c entry : [
        SELECT WorkDate__c
        FROM JIP_DailyWorkEntry__c
        WHERE
          Worker__c = :workers[0].Id
          AND WorkDate__c >= :monthStart
          AND WorkDate__c <= :monthEnd
      ]) {
        datesWithEntries.add(entry.WorkDate__c);
      }
    }

    // Build 6 weeks of calendar
    Date currentDate = calendarStart;
    for (Integer week = 0; week < 6; week++) {
      List<CalendarDayWrapper> weekDays = new List<CalendarDayWrapper>();
      for (Integer day = 0; day < 7; day++) {
        Boolean hasEntry = datesWithEntries.contains(currentDate);
        weekDays.add(
          new CalendarDayWrapper(
            currentDate,
            calendarMonth.month(),
            selectedWorkDate,
            hasEntry
          )
        );
        currentDate = currentDate.addDays(1);
      }
      calendarWeeks.add(weekDays);

      // Stop if we've passed the month
      if (currentDate.month() != calendarMonth.month() && week > 3) {
        break;
      }
    }
  }

  public void prevMonth() {
    calendarMonth = calendarMonth.addMonths(-1);
    loadCalendar();
    loadMonthlyProjectSummary();
    loadMonthlyWorksheet();
    loadMonthlyWorkStatus();
  }

  public void nextMonth() {
    calendarMonth = calendarMonth.addMonths(1);
    loadCalendar();
    loadMonthlyProjectSummary();
    loadMonthlyWorksheet();
    loadMonthlyWorkStatus();
  }

  public void prevYear() {
    calendarMonth = calendarMonth.addYears(-1);
    loadCalendar();
    loadMonthlyProjectSummary();
    loadMonthlyWorksheet();
    loadMonthlyWorkStatus();
  }

  public void nextYear() {
    calendarMonth = calendarMonth.addYears(1);
    loadCalendar();
    loadMonthlyProjectSummary();
    loadMonthlyWorksheet();
    loadMonthlyWorkStatus();
  }

  // ===== Calendar Day Wrapper =====
  public class CalendarDayWrapper {
    public Date dayDate { get; set; }
    public Integer dayNumber { get; set; }
    public Boolean isCurrentMonth { get; set; }
    public Boolean isToday { get; set; }
    public Boolean isSelected { get; set; }
    public Boolean isSunday { get; set; }
    public Boolean isSaturday { get; set; }
    public String dateStr { get; set; }
    public Boolean hasWorkEntries { get; set; }

    public CalendarDayWrapper(
      Date d,
      Integer currentMonth,
      Date selected,
      Boolean hasEntries
    ) {
      this.dayDate = d;
      this.dayNumber = d.day();
      this.isCurrentMonth = d.month() == currentMonth;
      this.isToday = d == Date.today();
      this.isSelected = d == selected;
      this.dateStr = String.valueOf(d);
      this.hasWorkEntries = hasEntries;

      // Calculate day of week (0=Sunday, 6=Saturday)
      Integer dow = Math.mod(Date.newInstance(1900, 1, 7).daysBetween(d), 7);
      this.isSunday = dow == 0;
      this.isSaturday = dow == 6;
    }
  }

  // ===== Monthly Project Summary =====
  public class MonthlyProjectSummary {
    public String projectId { get; set; }
    public String projectCode { get; set; }
    public String projectName { get; set; }
    public Decimal totalHours { get; set; }
    public String totalHoursFormatted { get; set; }
    public Decimal percentage { get; set; }

    public MonthlyProjectSummary(
      String pId,
      String pCode,
      String pName,
      Decimal hours,
      Decimal totalMonthlyHours
    ) {
      this.projectId = pId;
      this.projectCode = pCode;
      this.projectName = pName;
      this.totalHours = hours;

      // Format hours as HH:mm
      Integer h = (Integer) Math.floor(hours);
      Integer m = (Integer) Math.round((hours - h) * 60);
      this.totalHoursFormatted =
        String.valueOf(h) +
        ':' +
        String.valueOf(m).leftPad(2, '0');

      // Calculate percentage
      if (totalMonthlyHours > 0) {
        this.percentage = (hours / totalMonthlyHours * 100).setScale(0);
      } else {
        this.percentage = 0;
      }
    }
  }

  private void loadMonthlyProjectSummary() {
    monthlyProjectSummaries = new List<MonthlyProjectSummary>();
    monthlyTotalHours = 0;

    Id currentUserId = UserInfo.getUserId();
    List<JIP_Worker__c> workers = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE User__c = :currentUserId
      LIMIT 1
    ];

    if (workers.isEmpty()) {
      return;
    }

    Date monthStart = calendarMonth.toStartOfMonth();
    Date monthEnd = monthStart.addMonths(1).addDays(-1);

    // Aggregate hours by project
    Map<Id, Decimal> projectHoursMap = new Map<Id, Decimal>();
    Map<Id, JIP_Project__c> projectMap = new Map<Id, JIP_Project__c>();

    for (JIP_DailyWorkEntry__c entry : [
      SELECT Project__c, Project__r.Name, Project__r.Name__c, WorkHours__c
      FROM JIP_DailyWorkEntry__c
      WHERE
        Worker__c = :workers[0].Id
        AND WorkDate__c >= :monthStart
        AND WorkDate__c <= :monthEnd
    ]) {
      if (entry.Project__c != null) {
        Decimal currentHours = projectHoursMap.containsKey(entry.Project__c)
          ? projectHoursMap.get(entry.Project__c)
          : 0;
        projectHoursMap.put(
          entry.Project__c,
          currentHours + (entry.WorkHours__c != null ? entry.WorkHours__c : 0)
        );

        if (!projectMap.containsKey(entry.Project__c)) {
          projectMap.put(entry.Project__c, entry.Project__r);
        }

        monthlyTotalHours += (entry.WorkHours__c != null
          ? entry.WorkHours__c
          : 0);
      }
    }

    // Build summary list
    for (Id projectId : projectHoursMap.keySet()) {
      JIP_Project__c proj = projectMap.get(projectId);
      String code = proj.Name;
      String pName = proj.Name__c != null ? proj.Name__c : '';
      Decimal hours = projectHoursMap.get(projectId);

      monthlyProjectSummaries.add(
        new MonthlyProjectSummary(
          projectId,
          code,
          pName,
          hours,
          monthlyTotalHours
        )
      );
    }
  }

  public void removeProjectFromMonth() {
    try {
      if (String.isNotBlank(selectedWorkEntryId)) {
        Id currentUserId = UserInfo.getUserId();
        List<JIP_Worker__c> workers = [
          SELECT Id
          FROM JIP_Worker__c
          WHERE User__c = :currentUserId
          LIMIT 1
        ];

        if (!workers.isEmpty()) {
          Date monthStart = calendarMonth.toStartOfMonth();
          Date monthEnd = monthStart.addMonths(1).addDays(-1);

          // Delete all entries for this project in current month
          delete [
            SELECT Id
            FROM JIP_DailyWorkEntry__c
            WHERE
              Worker__c = :workers[0].Id
              AND Project__c = :selectedWorkEntryId
              AND WorkDate__c >= :monthStart
              AND WorkDate__c <= :monthEnd
          ];

          loadMonthlyProjectSummary();
          loadCalendar();
          loadDailyDetail();
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.CONFIRM,
              'プロジェクトの登録を削除しました'
            )
          );
        }
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  // ===== Monthly Worksheet Methods =====
  public void loadMonthlyWorksheet() {
    worksheetRows = new List<WorkSheetRowWrapper>();
    worksheetProjects = new List<ProjectColumnWrapper>();
    hasWorksheetProjects = false;

    Id currentUserId = UserInfo.getUserId();
    List<JIP_Worker__c> workers = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE User__c = :currentUserId
      LIMIT 1
    ];

    if (workers.isEmpty()) {
      return;
    }

    Id workerId = workers[0].Id;
    Date monthStart = calendarMonth.toStartOfMonth();
    Date monthEnd = monthStart.addMonths(1).addDays(-1);

    // Get all projects with entries this month + active projects
    Set<Id> projectIds = new Set<Id>();
    Map<String, Decimal> dateProjectHours = new Map<String, Decimal>(); // key: date_projectId -> hours
    Map<String, String> dateProjectComments = new Map<String, String>(); // key: date_projectId -> comment
    Map<String, String> dateComments = new Map<String, String>(); // key: date -> comment (first non-empty)
    Map<String, String> dateStatus = new Map<String, String>(); // key: date -> status
    Map<String, String> dateCheckIn = new Map<String, String>(); // key: date -> check-in time
    Map<String, String> dateCheckOut = new Map<String, String>(); // key: date -> check-out time

    // Load existing work entries
    for (JIP_DailyWorkEntry__c entry : [
      SELECT WorkDate__c, Project__c, WorkHours__c, Comment__c
      FROM JIP_DailyWorkEntry__c
      WHERE
        Worker__c = :workerId
        AND WorkDate__c >= :monthStart
        AND WorkDate__c <= :monthEnd
    ]) {
      projectIds.add(entry.Project__c);
      String key = String.valueOf(entry.WorkDate__c) + '_' + entry.Project__c;
      dateProjectHours.put(key, entry.WorkHours__c);
      if (String.isNotBlank(entry.Comment__c)) {
        dateProjectComments.put(key, entry.Comment__c);
        dateComments.put(String.valueOf(entry.WorkDate__c), entry.Comment__c);
      }
    }

    // Load attendance records for status and check-in/out times
    for (JIP_Attendance__c att : [
      SELECT AttendanceDate__c, Status__c, CheckInTime__c, CheckOutTime__c
      FROM JIP_Attendance__c
      WHERE
        Worker__c = :workerId
        AND AttendanceDate__c >= :monthStart
        AND AttendanceDate__c <= :monthEnd
    ]) {
      String dateKey = String.valueOf(att.AttendanceDate__c);
      dateStatus.put(dateKey, att.Status__c);
      if (att.CheckInTime__c != null) {
        dateCheckIn.put(dateKey, att.CheckInTime__c.format('HH:mm'));
      }
      if (att.CheckOutTime__c != null) {
        dateCheckOut.put(dateKey, att.CheckOutTime__c.format('HH:mm'));
      }
    }

    // Build project columns from existing entries
    if (!projectIds.isEmpty()) {
      hasWorksheetProjects = true;
      Integer colIdx = 0;
      for (JIP_Project__c proj : [
        SELECT Id, Name, Name__c
        FROM JIP_Project__c
        WHERE Id IN :projectIds
        ORDER BY Name
      ]) {
        String colName = proj.Name;
        if (proj.Name__c != null && proj.Name__c.length() > 0) {
          colName +=
            ':' +
            (proj.Name__c.length() > 10
              ? proj.Name__c.substring(0, 10) + '...'
              : proj.Name__c);
        }
        worksheetProjects.add(
          new ProjectColumnWrapper(proj.Id, colName, colIdx)
        );
        colIdx++;
      }
    }

    // Build worksheet rows for each day
    Date currentDate = monthStart;
    while (currentDate <= monthEnd) {
      WorkSheetRowWrapper row = new WorkSheetRowWrapper();
      row.rowDate = currentDate;
      row.dateStr = String.valueOf(currentDate);
      row.dateLabel =
        String.valueOf(currentDate.month()).leftPad(2, '0') +
        '/' +
        String.valueOf(currentDate.day()).leftPad(2, '0');

      // Day of week
      Integer dow = Math.mod(
        Date.newInstance(1900, 1, 7).daysBetween(currentDate),
        7
      );
      String[] dowNames = new List<String>{
        '日',
        '月',
        '火',
        '水',
        '木',
        '金',
        '土'
      };
      row.dayOfWeek = dowNames[dow];
      row.isSunday = dow == 0;
      row.isSaturday = dow == 6;
      row.isWeekend = dow == 0 || dow == 6;

      // Check-in and Check-out times
      String dateKey = String.valueOf(currentDate);
      row.checkInTime = dateCheckIn.containsKey(dateKey)
        ? dateCheckIn.get(dateKey)
        : '';
      row.checkOutTime = dateCheckOut.containsKey(dateKey)
        ? dateCheckOut.get(dateKey)
        : '';

      // Status
      String attStatus = dateStatus.get(String.valueOf(currentDate));
      if (attStatus != null) {
        if (attStatus == '出勤' || attStatus == '勤務中') {
          row.statusIcon = '●';
          row.statusLabel = '入力済';
        } else {
          row.statusIcon = '';
          row.statusLabel = '';
        }
      } else {
        row.statusIcon = '';
        row.statusLabel = '';
      }

      // Calculate total work hours for this day
      Decimal totalHours = 0;
      row.projectHours = new List<String>();
      row.projectComments = new List<String>();

      for (ProjectColumnWrapper proj : worksheetProjects) {
        String key = String.valueOf(currentDate) + '_' + proj.projectId;
        Decimal hours = dateProjectHours.get(key);
        String projComment = dateProjectComments.get(key);
        if (hours != null && hours > 0) {
          Integer h = (Integer) Math.floor(hours);
          Integer m = (Integer) Math.round((hours - h) * 60);
          row.projectHours.add(
            String.valueOf(h) + ':' + String.valueOf(m).leftPad(2, '0')
          );
          totalHours += hours;
        } else {
          row.projectHours.add('');
        }
        row.projectComments.add(projComment != null ? projComment : '');
      }

      // Total hours
      if (totalHours > 0) {
        Integer th = (Integer) Math.floor(totalHours);
        Integer tm = (Integer) Math.round((totalHours - th) * 60);
        row.totalHours =
          String.valueOf(th) +
          ':' +
          String.valueOf(tm).leftPad(2, '0');
      } else {
        row.totalHours = '';
      }

      // Comment
      row.comment = dateComments.get(String.valueOf(currentDate));
      if (row.comment == null) {
        row.comment = '';
      }

      row.approvalRecord = '';
      row.isSelected = false;
      row.dateStr = String.valueOf(currentDate);

      worksheetRows.add(row);
      currentDate = currentDate.addDays(1);
    }
  }

  public void saveMonthlyWorksheet() {
    try {
      Id currentUserId = UserInfo.getUserId();
      List<JIP_Worker__c> workers = [
        SELECT Id
        FROM JIP_Worker__c
        WHERE User__c = :currentUserId
        LIMIT 1
      ];

      if (workers.isEmpty()) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            '作業員情報が見つかりません'
          )
        );
        return;
      }

      Id workerId = workers[0].Id;
      Date monthStart = calendarMonth.toStartOfMonth();
      Date monthEnd = monthStart.addMonths(1).addDays(-1);

      // Get existing entries to update/delete
      Map<String, JIP_DailyWorkEntry__c> existingEntries = new Map<String, JIP_DailyWorkEntry__c>();
      for (JIP_DailyWorkEntry__c entry : [
        SELECT Id, WorkDate__c, Project__c, WorkHours__c, Comment__c
        FROM JIP_DailyWorkEntry__c
        WHERE
          Worker__c = :workerId
          AND WorkDate__c >= :monthStart
          AND WorkDate__c <= :monthEnd
      ]) {
        String key = String.valueOf(entry.WorkDate__c) + '_' + entry.Project__c;
        existingEntries.put(key, entry);
      }

      // Get existing attendance records for check-in/out times
      Map<Date, JIP_Attendance__c> existingAttendance = new Map<Date, JIP_Attendance__c>();
      for (JIP_Attendance__c att : [
        SELECT Id, AttendanceDate__c, CheckInTime__c, CheckOutTime__c, Status__c
        FROM JIP_Attendance__c
        WHERE
          Worker__c = :workerId
          AND AttendanceDate__c >= :monthStart
          AND AttendanceDate__c <= :monthEnd
      ]) {
        existingAttendance.put(att.AttendanceDate__c, att);
      }

      List<JIP_DailyWorkEntry__c> toUpsert = new List<JIP_DailyWorkEntry__c>();
      List<JIP_DailyWorkEntry__c> toDelete = new List<JIP_DailyWorkEntry__c>();
      List<JIP_Attendance__c> attendanceToUpsert = new List<JIP_Attendance__c>();

      for (WorkSheetRowWrapper row : worksheetRows) {
        // Save check-in/out times to JIP_Attendance__c
        if (!row.isWeekend) {
          JIP_Attendance__c att = existingAttendance.get(row.rowDate);
          Boolean hasCheckInOut =
            String.isNotBlank(row.checkInTime) ||
            String.isNotBlank(row.checkOutTime);

          if (hasCheckInOut || att != null) {
            if (att == null) {
              att = new JIP_Attendance__c();
              att.Worker__c = workerId;
              att.AttendanceDate__c = row.rowDate;
              att.Status__c = '出勤';
            }

            // Parse and set check-in time (or clear if empty)
            if (String.isNotBlank(row.checkInTime)) {
              att.CheckInTime__c = parseTimeString(
                row.rowDate,
                row.checkInTime
              );
            } else {
              att.CheckInTime__c = null;
            }

            // Parse and set check-out time (or clear if empty)
            if (String.isNotBlank(row.checkOutTime)) {
              att.CheckOutTime__c = parseTimeString(
                row.rowDate,
                row.checkOutTime
              );
            } else {
              att.CheckOutTime__c = null;
            }

            attendanceToUpsert.add(att);
          }
        }

        Integer projIdx = 0;
        for (ProjectColumnWrapper proj : worksheetProjects) {
          String hoursStr = '';
          if (projIdx < row.projectHours.size()) {
            hoursStr = row.projectHours[projIdx];
          }

          String key = String.valueOf(row.rowDate) + '_' + proj.projectId;
          JIP_DailyWorkEntry__c existing = existingEntries.get(key);

          // Get project-specific comment
          String projComment = '';
          if (projIdx < row.projectComments.size()) {
            projComment = row.projectComments[projIdx];
          }

          if (String.isNotBlank(hoursStr)) {
            Decimal hours = parseHoursString(hoursStr);
            if (hours != null && hours > 0) {
              JIP_DailyWorkEntry__c entry;
              if (existing != null) {
                entry = existing;
              } else {
                entry = new JIP_DailyWorkEntry__c();
                entry.Worker__c = workerId;
                entry.WorkDate__c = row.rowDate;
                entry.Project__c = proj.projectId;
              }
              entry.WorkHours__c = hours;
              entry.Comment__c = projComment;
              toUpsert.add(entry);
            } else if (existing != null) {
              toDelete.add(existing);
            }
          } else if (existing != null) {
            toDelete.add(existing);
          }

          projIdx++;
        }
      }

      // Save attendance records (check-in/out times)
      if (!attendanceToUpsert.isEmpty()) {
        upsert attendanceToUpsert;
      }

      if (!toUpsert.isEmpty()) {
        upsert toUpsert;
      }
      if (!toDelete.isEmpty()) {
        delete toDelete;
      }

      loadMonthlyWorksheet();
      loadMonthlyProjectSummary();
      loadCalendar();
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.CONFIRM, '登録しました')
      );
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'エラー: ' + e.getMessage()
        )
      );
    }
  }

  private Datetime parseTimeString(Date d, String timeStr) {
    if (String.isBlank(timeStr)) {
      return null;
    }
    try {
      timeStr = timeStr.trim();
      String[] parts = timeStr.split(':');
      Integer h = Integer.valueOf(parts[0].trim());
      Integer m = parts.size() > 1 ? Integer.valueOf(parts[1].trim()) : 0;
      return Datetime.newInstance(d.year(), d.month(), d.day(), h, m, 0);
    } catch (Exception e) {
      return null;
    }
  }

  private Decimal parseHoursString(String hoursStr) {
    if (String.isBlank(hoursStr)) {
      return null;
    }
    try {
      hoursStr = hoursStr.trim();
      if (hoursStr.contains(':')) {
        String[] parts = hoursStr.split(':');
        Integer h = Integer.valueOf(parts[0].trim());
        Integer m = parts.size() > 1 ? Integer.valueOf(parts[1].trim()) : 0;
        return h + (m / 60.0);
      } else {
        return Decimal.valueOf(hoursStr);
      }
    } catch (Exception e) {
      return null;
    }
  }

  public void addProjectToWorksheet() {
    if (String.isNotBlank(newProjectId)) {
      // Check if project already exists in worksheet
      for (ProjectColumnWrapper proj : worksheetProjects) {
        if (proj.projectId == newProjectId) {
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.WARNING,
              'このプロジェクトは既に追加されています'
            )
          );
          return;
        }
      }

      JIP_Project__c proj = [
        SELECT Id, Name, Name__c
        FROM JIP_Project__c
        WHERE Id = :newProjectId
        LIMIT 1
      ];
      String colName = proj.Name;
      if (proj.Name__c != null && proj.Name__c.length() > 0) {
        colName +=
          ':' +
          (proj.Name__c.length() > 10
            ? proj.Name__c.substring(0, 10) + '...'
            : proj.Name__c);
      }

      worksheetProjects.add(
        new ProjectColumnWrapper(proj.Id, colName, worksheetProjects.size())
      );
      hasWorksheetProjects = true;

      // Add empty column to all rows
      for (WorkSheetRowWrapper row : worksheetRows) {
        row.projectHours.add('');
        row.projectComments.add('');
      }

      newProjectId = '';
    }
  }

  // ===== Worksheet Wrapper Classes =====
  public class WorkSheetRowWrapper {
    public Date rowDate { get; set; }
    public String dateStr { get; set; }
    public String dateLabel { get; set; }
    public String dayOfWeek { get; set; }
    public Boolean isSunday { get; set; }
    public Boolean isSaturday { get; set; }
    public Boolean isWeekend { get; set; }
    public String checkInTime { get; set; }
    public String checkOutTime { get; set; }
    public String statusIcon { get; set; }
    public String statusLabel { get; set; }
    public String totalHours { get; set; }
    public List<String> projectHours { get; set; }
    public List<String> projectComments { get; set; }
    public String comment { get; set; }
    public String approvalRecord { get; set; }
    public Boolean isSelected { get; set; }

    public WorkSheetRowWrapper() {
      projectHours = new List<String>();
      projectComments = new List<String>();
      checkInTime = '';
      checkOutTime = '';
    }
  }

  public class ProjectColumnWrapper {
    public String projectId { get; set; }
    public String projectName { get; set; }
    public Integer columnIndex { get; set; }

    public ProjectColumnWrapper(String pId, String pName, Integer idx) {
      this.projectId = pId;
      this.projectName = pName;
      this.columnIndex = idx;
    }
  }

  // ===== Monthly Work Status Wrapper =====
  public class MonthlyWorkStatusWrapper {
    public String workHours { get; set; }
    public String scheduledHours { get; set; }
    public String overtimeHours { get; set; }
    public Decimal paidLeaveDays { get; set; }
    public String paidLeaveHours { get; set; }
    public Decimal compensatoryDays { get; set; }
    public Decimal substituteHolidayDays { get; set; }

    public MonthlyWorkStatusWrapper() {
      this.workHours = '0:00';
      this.scheduledHours = '168:00';
      this.overtimeHours = '0:00';
      this.paidLeaveDays = 0.0;
      this.paidLeaveHours = '0:00';
      this.compensatoryDays = 0.0;
      this.substituteHolidayDays = 0.0;
    }
  }

  // ===== Attendance Info Wrapper =====
  public class AttendanceInfoWrapper {
    public String actualWorkHours { get; set; }
    public String leaveHours { get; set; }
    public String outsideScheduledHours { get; set; }
    public String lateHours { get; set; }
    public String breakHours { get; set; }
    public String earlyLeaveHours { get; set; }

    // Timeline properties (percentage positions, 0-100% for 24 hours, each hour = 4.1667%)
    public Decimal checkInPosition { get; set; } // Position where check-in starts
    public Decimal workBlockWidth { get; set; } // Total work block width
    public Decimal lateWidth { get; set; } // Late arrival width
    public Decimal standardStartPosition { get; set; } // 9:00 position (37.5%)
    public Decimal breakPosition { get; set; } // Break start position (12:00 = 50%)
    public Decimal breakWidth { get; set; } // Break width (1 hour = 4.1667%)
    public Decimal earlyLeaveWidth { get; set; } // Early leave width
    public Decimal earlyLeavePosition { get; set; } // Early leave start position
    public Decimal overtimeWidth { get; set; } // Overtime after 18:00
    public Decimal overtimePosition { get; set; } // Overtime start position (18:00 = 75%)
    public Boolean hasAttendance { get; set; } // Whether has attendance record
    // Keep for backward compatibility
    public Decimal morningWorkWidth { get; set; }
    public Decimal afternoonWorkWidth { get; set; }

    public AttendanceInfoWrapper() {
      this.actualWorkHours = '8:00';
      this.leaveHours = '0:00';
      this.outsideScheduledHours = '0:00';
      this.lateHours = '0:00';
      this.breakHours = '1:00';
      this.earlyLeaveHours = '0:00';

      // Default timeline (24-hour scale: each hour = 100/24 = 4.1667%)
      // Standard work: 9:00-18:00
      this.checkInPosition = 37.5; // 9:00 = 9 * 4.1667
      this.workBlockWidth = 37.5; // 9 hours = 9 * 4.1667
      this.lateWidth = 0;
      this.standardStartPosition = 37.5; // 9:00
      this.breakPosition = 50; // 12:00 = 12 * 4.1667
      this.breakWidth = 4.1667; // 1 hour
      this.earlyLeaveWidth = 0;
      this.earlyLeavePosition = 75; // 18:00 = 18 * 4.1667
      this.overtimeWidth = 0;
      this.overtimePosition = 75; // 18:00
      this.hasAttendance = false;
      this.morningWorkWidth = 0;
      this.afternoonWorkWidth = 0;
    }
  }

  // ===== Load Monthly Work Status =====
  private void loadMonthlyWorkStatus() {
    monthlyWorkStatus = new MonthlyWorkStatusWrapper();
    attendanceInfo = new AttendanceInfoWrapper();

    Id currentUserId = UserInfo.getUserId();
    List<JIP_Worker__c> workers = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE User__c = :currentUserId
      LIMIT 1
    ];

    if (workers.isEmpty()) {
      return;
    }

    Date monthStart = calendarMonth.toStartOfMonth();
    Date monthEnd = monthStart.addMonths(1).addDays(-1);

    // Calculate total work hours for the month from attendance records
    Decimal totalWorkMinutes = 0;
    Decimal totalBreakMinutes = 0;
    Decimal lateMinutes = 0;
    Decimal earlyLeaveMinutes = 0;
    Integer workDaysCount = 0;

    // Standard work start/end times (9:00 - 18:00)
    Time standardStartTime = Time.newInstance(9, 0, 0, 0);
    Time standardEndTime = Time.newInstance(18, 0, 0, 0);

    for (JIP_Attendance__c att : [
      SELECT CheckInTime__c, CheckOutTime__c, Status__c, AttendanceDate__c
      FROM JIP_Attendance__c
      WHERE
        Worker__c = :workers[0].Id
        AND AttendanceDate__c >= :monthStart
        AND AttendanceDate__c <= :monthEnd
      ORDER BY AttendanceDate__c
    ]) {
      if (att.CheckInTime__c != null && att.CheckOutTime__c != null) {
        workDaysCount++;

        // Calculate work duration
        Long diffMs =
          att.CheckOutTime__c.getTime() - att.CheckInTime__c.getTime();
        Decimal diffMinutes = diffMs / 1000.0 / 60.0;
        totalWorkMinutes += diffMinutes;

        // Calculate late minutes (compare check-in with 9:00)
        Datetime checkInDt = att.CheckInTime__c;
        Time checkInTime = Time.newInstance(
          checkInDt.hour(),
          checkInDt.minute(),
          0,
          0
        );
        if (checkInTime > standardStartTime) {
          Integer lateMins = (checkInDt.hour() - 9) * 60 + checkInDt.minute();
          if (lateMins > 0) {
            lateMinutes += lateMins;
          }
        }

        // Calculate early leave minutes (compare check-out with 18:00)
        Datetime checkOutDt = att.CheckOutTime__c;
        Time checkOutTime = Time.newInstance(
          checkOutDt.hour(),
          checkOutDt.minute(),
          0,
          0
        );
        if (checkOutTime < standardEndTime) {
          Integer earlyMins =
            (18 - checkOutDt.hour()) * 60 - checkOutDt.minute();
          if (earlyMins > 0) {
            earlyLeaveMinutes += earlyMins;
          }
        }
      }
    }

    // Break time: 1 hour per work day
    totalBreakMinutes = workDaysCount * 60;

    // Calculate actual work hours (total - breaks)
    Decimal actualMinutes = totalWorkMinutes - totalBreakMinutes;
    if (actualMinutes < 0) {
      actualMinutes = 0;
    }

    // Format work hours
    Integer workH = (Integer) Math.floor(totalWorkMinutes / 60);
    Integer workM = (Integer) Math.mod(
      (Integer) Math.round(totalWorkMinutes),
      60
    );
    monthlyWorkStatus.workHours =
      workH +
      ':' +
      String.valueOf(workM).leftPad(2, '0');

    // Scheduled hours (8h * working days in month, approx 21 days = 168h)
    // Count actual working days in this month (exclude weekends)
    Integer workingDaysInMonth = 0;
    Date d = monthStart;
    while (d <= monthEnd) {
      // Get day of week (1=Sunday, 7=Saturday)
      Date startOfWeek = d.toStartOfWeek();
      Integer dayOfWeek = startOfWeek.daysBetween(d);
      // 0=Sunday, 6=Saturday in this calculation
      if (dayOfWeek != 0 && dayOfWeek != 6) {
        workingDaysInMonth++;
      }
      d = d.addDays(1);
    }
    Integer scheduledMinutes = workingDaysInMonth * 8 * 60;
    Integer schedH = (Integer) Math.floor(scheduledMinutes / 60);
    Integer schedM = (Integer) Math.mod(scheduledMinutes, 60);
    monthlyWorkStatus.scheduledHours =
      schedH +
      ':' +
      String.valueOf(schedM).leftPad(2, '0');

    // Overtime (work hours exceeding scheduled hours)
    Decimal overtimeMinutes = actualMinutes - scheduledMinutes;
    if (overtimeMinutes < 0) {
      overtimeMinutes = 0;
    }
    Integer otH = (Integer) Math.floor(overtimeMinutes / 60);
    Integer otM = (Integer) Math.mod((Integer) Math.round(overtimeMinutes), 60);
    monthlyWorkStatus.overtimeHours =
      otH +
      ':' +
      String.valueOf(otM).leftPad(2, '0');

    // Query leave requests for the month
    Decimal paidLeaveDays = 0;
    Decimal paidLeaveMinutes = 0;
    Decimal compensatoryDays = 0;
    Decimal substituteHolidayDays = 0;

    for (JIP_LeaveRequest__c lr : [
      SELECT RequestType__c, StartDate__c, EndDate__c, Status__c
      FROM JIP_LeaveRequest__c
      WHERE
        Applicant__c = :workers[0].Id
        AND Status__c = '承認済'
        AND ((StartDate__c >= :monthStart
        AND StartDate__c <= :monthEnd)
        OR (EndDate__c >= :monthStart
        AND EndDate__c <= :monthEnd))
    ]) {
      // Calculate days in this month
      Date effectiveStart = lr.StartDate__c < monthStart
        ? monthStart
        : lr.StartDate__c;
      Date effectiveEnd = lr.EndDate__c > monthEnd ? monthEnd : lr.EndDate__c;
      Integer leaveDays = effectiveStart.daysBetween(effectiveEnd) + 1;

      // 有給休暇, 半休(午前), 半休(午後)
      if (lr.RequestType__c == '有給休暇') {
        paidLeaveDays += leaveDays;
        paidLeaveMinutes += leaveDays * 8 * 60;
      } else if (
        lr.RequestType__c == '半休(午前)' ||
        lr.RequestType__c == '半休(午後)'
      ) {
        paidLeaveDays += leaveDays * 0.5;
        paidLeaveMinutes += leaveDays * 4 * 60;
      } else if (lr.RequestType__c == '特別休暇') {
        compensatoryDays += leaveDays;
      } else if (lr.RequestType__c == '休日出勤') {
        // 休日出勤 can generate substitute holiday
        substituteHolidayDays += leaveDays;
      }
    }

    monthlyWorkStatus.paidLeaveDays = paidLeaveDays;
    Integer plH = (Integer) Math.floor(paidLeaveMinutes / 60);
    Integer plM = (Integer) Math.mod(
      (Integer) Math.round(paidLeaveMinutes),
      60
    );
    monthlyWorkStatus.paidLeaveHours =
      plH +
      ':' +
      String.valueOf(plM).leftPad(2, '0');
    monthlyWorkStatus.compensatoryDays = compensatoryDays;
    monthlyWorkStatus.substituteHolidayDays = substituteHolidayDays;

    // Attendance info
    Integer actH = (Integer) Math.floor(actualMinutes / 60);
    Integer actM = (Integer) Math.mod((Integer) Math.round(actualMinutes), 60);
    attendanceInfo.actualWorkHours =
      actH +
      ':' +
      String.valueOf(actM).leftPad(2, '0');

    // Break hours
    Integer breakH = (Integer) Math.floor(totalBreakMinutes / 60);
    Integer breakM = (Integer) Math.mod((Integer) totalBreakMinutes, 60);
    attendanceInfo.breakHours =
      breakH +
      ':' +
      String.valueOf(breakM).leftPad(2, '0');

    // Leave hours (from paid leave)
    attendanceInfo.leaveHours = monthlyWorkStatus.paidLeaveHours;

    // Outside scheduled hours (overtime)
    attendanceInfo.outsideScheduledHours = monthlyWorkStatus.overtimeHours;

    // Late hours
    Integer lateH = (Integer) Math.floor(lateMinutes / 60);
    Integer lateM = (Integer) Math.mod((Integer) Math.round(lateMinutes), 60);
    attendanceInfo.lateHours =
      lateH +
      ':' +
      String.valueOf(lateM).leftPad(2, '0');

    // Early leave hours
    Integer earlyH = (Integer) Math.floor(earlyLeaveMinutes / 60);
    Integer earlyM = (Integer) Math.mod(
      (Integer) Math.round(earlyLeaveMinutes),
      60
    );
    attendanceInfo.earlyLeaveHours =
      earlyH +
      ':' +
      String.valueOf(earlyM).leftPad(2, '0');
  }

  // ===== Load Daily Attendance Info =====
  public void loadDailyAttendanceInfo() {
    if (String.isBlank(selectedAttendanceDate)) {
      return;
    }

    Date targetDate = Date.valueOf(selectedAttendanceDate);
    selectedAttendanceDateLabel =
      String.valueOf(targetDate.month()).leftPad(2, '0') +
      '/' +
      String.valueOf(targetDate.day()).leftPad(2, '0');

    // Get day of week
    Integer dow = Math.mod(
      Date.newInstance(1900, 1, 7).daysBetween(targetDate),
      7
    );
    String[] dowNames = new List<String>{
      '日',
      '月',
      '火',
      '水',
      '木',
      '金',
      '土'
    };
    selectedAttendanceDateLabel += ' (' + dowNames[dow] + ')';

    attendanceInfo = new AttendanceInfoWrapper();

    Id currentUserId = UserInfo.getUserId();
    List<JIP_Worker__c> workers = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE User__c = :currentUserId
      LIMIT 1
    ];

    if (workers.isEmpty()) {
      return;
    }

    // Get attendance record for this specific date
    List<JIP_Attendance__c> attendances = [
      SELECT CheckInTime__c, CheckOutTime__c, Status__c
      FROM JIP_Attendance__c
      WHERE Worker__c = :workers[0].Id AND AttendanceDate__c = :targetDate
      LIMIT 1
    ];

    if (attendances.isEmpty()) {
      attendanceInfo.actualWorkHours = '0:00';
      attendanceInfo.breakHours = '0:00';
      attendanceInfo.lateHours = '0:00';
      attendanceInfo.earlyLeaveHours = '0:00';
      attendanceInfo.leaveHours = '0:00';
      attendanceInfo.outsideScheduledHours = '0:00';
      // Reset timeline to show nothing when no attendance
      attendanceInfo.hasAttendance = false;
      attendanceInfo.checkInPosition = 37.5;
      attendanceInfo.workBlockWidth = 0;
      attendanceInfo.lateWidth = 0;
      attendanceInfo.breakWidth = 0;
      attendanceInfo.earlyLeaveWidth = 0;
      attendanceInfo.earlyLeavePosition = 75;
      attendanceInfo.overtimeWidth = 0;
      attendanceInfo.standardStartPosition = 37.5;
      attendanceInfo.overtimePosition = 75;
      return;
    }

    JIP_Attendance__c att = attendances[0];

    // Standard work times
    Time standardStartTime = Time.newInstance(9, 0, 0, 0);
    Time standardEndTime = Time.newInstance(18, 0, 0, 0);

    Decimal totalWorkMinutes = 0;
    Decimal breakMinutes = 60; // 1 hour break
    Decimal lateMinutes = 0;
    Decimal earlyLeaveMinutes = 0;

    if (att.CheckInTime__c != null && att.CheckOutTime__c != null) {
      // Calculate work duration
      Long diffMs =
        att.CheckOutTime__c.getTime() - att.CheckInTime__c.getTime();
      totalWorkMinutes = diffMs / 1000.0 / 60.0;

      // Calculate late minutes
      Datetime checkInDt = att.CheckInTime__c;
      Time checkInTime = Time.newInstance(
        checkInDt.hour(),
        checkInDt.minute(),
        0,
        0
      );
      if (checkInTime > standardStartTime) {
        Integer lateMins = (checkInDt.hour() - 9) * 60 + checkInDt.minute();
        if (lateMins > 0) {
          lateMinutes = lateMins;
        }
      }

      // Calculate early leave minutes
      Datetime checkOutDt = att.CheckOutTime__c;
      Time checkOutTime = Time.newInstance(
        checkOutDt.hour(),
        checkOutDt.minute(),
        0,
        0
      );
      if (checkOutTime < standardEndTime) {
        Integer earlyMins = (18 - checkOutDt.hour()) * 60 - checkOutDt.minute();
        if (earlyMins > 0) {
          earlyLeaveMinutes = earlyMins;
        }
      }
    }

    // Actual work (total - break)
    Decimal actualMinutes = totalWorkMinutes - breakMinutes;
    if (actualMinutes < 0) {
      actualMinutes = 0;
    }
    Integer actH = (Integer) Math.floor(actualMinutes / 60);
    Integer actM = (Integer) Math.mod((Integer) Math.round(actualMinutes), 60);
    attendanceInfo.actualWorkHours =
      actH +
      ':' +
      String.valueOf(actM).leftPad(2, '0');

    // Break hours
    Integer breakH = (Integer) Math.floor(breakMinutes / 60);
    Integer breakM = (Integer) Math.mod((Integer) breakMinutes, 60);
    attendanceInfo.breakHours =
      breakH +
      ':' +
      String.valueOf(breakM).leftPad(2, '0');

    // Late hours
    Integer lateH = (Integer) Math.floor(lateMinutes / 60);
    Integer lateM = (Integer) Math.mod((Integer) Math.round(lateMinutes), 60);
    attendanceInfo.lateHours =
      lateH +
      ':' +
      String.valueOf(lateM).leftPad(2, '0');

    // Early leave hours
    Integer earlyH = (Integer) Math.floor(earlyLeaveMinutes / 60);
    Integer earlyM = (Integer) Math.mod(
      (Integer) Math.round(earlyLeaveMinutes),
      60
    );
    attendanceInfo.earlyLeaveHours =
      earlyH +
      ':' +
      String.valueOf(earlyM).leftPad(2, '0');

    // Overtime (work beyond 8 hours)
    Decimal overtimeMinutes = actualMinutes - (8 * 60);
    if (overtimeMinutes < 0) {
      overtimeMinutes = 0;
    }
    Integer otH = (Integer) Math.floor(overtimeMinutes / 60);
    Integer otM = (Integer) Math.mod((Integer) Math.round(overtimeMinutes), 60);
    attendanceInfo.outsideScheduledHours =
      otH +
      ':' +
      String.valueOf(otM).leftPad(2, '0');

    // Calculate timeline positions (24-hour scale: 0:00 = 0%, 24:00 = 100%, each hour = 4.1667%)
    attendanceInfo.hasAttendance = (att.CheckInTime__c != null &&
    att.CheckOutTime__c != null);
    attendanceInfo.standardStartPosition = 37.5; // 9:00 = 9 * 4.1667%
    attendanceInfo.overtimePosition = 75; // 18:00 = 18 * 4.1667%

    if (attendanceInfo.hasAttendance) {
      Datetime checkInDt = att.CheckInTime__c;
      Datetime checkOutDt = att.CheckOutTime__c;

      Integer checkInHour = checkInDt.hour();
      Integer checkInMin = checkInDt.minute();
      Integer checkOutHour = checkOutDt.hour();
      Integer checkOutMin = checkOutDt.minute();

      // Calculate positions (24-hour scale: each hour = 100/24 = 4.1667%)
      Decimal hourPercent = 100.0 / 24.0;
      Decimal checkInPos = (checkInHour * 60 + checkInMin) * hourPercent / 60.0;
      Decimal checkOutPos =
        (checkOutHour * 60 + checkOutMin) *
        hourPercent /
        60.0;

      attendanceInfo.checkInPosition = checkInPos;
      attendanceInfo.workBlockWidth = checkOutPos - checkInPos;

      // Late: if check-in after 9:00 (37.5%)
      if (checkInPos > 37.5) {
        attendanceInfo.lateWidth = checkInPos - 37.5;
      } else {
        attendanceInfo.lateWidth = 0;
      }

      // Break: 12:00-13:00 (50% to 54.17%)
      attendanceInfo.breakPosition = 50; // 12:00
      if (checkInPos <= 50 && checkOutPos >= 50) {
        Decimal breakEnd = Math.min(54.1667, checkOutPos);
        attendanceInfo.breakWidth = breakEnd - 50;
      } else {
        attendanceInfo.breakWidth = 0;
      }

      // Early leave: if check-out before 18:00 (75%)
      if (checkOutPos < 75) {
        attendanceInfo.earlyLeavePosition = checkOutPos;
        attendanceInfo.earlyLeaveWidth = 75 - checkOutPos;
      } else {
        attendanceInfo.earlyLeavePosition = 75;
        attendanceInfo.earlyLeaveWidth = 0;
      }

      // Overtime: after 18:00 (75%)
      if (checkOutPos > 75) {
        attendanceInfo.overtimePosition = 75;
        attendanceInfo.overtimeWidth = checkOutPos - 75;
      } else {
        attendanceInfo.overtimeWidth = 0;
      }
    }

    // Leave hours (check if this date has leave request)
    Decimal leaveMinutes = 0;
    for (JIP_LeaveRequest__c lr : [
      SELECT RequestType__c
      FROM JIP_LeaveRequest__c
      WHERE
        Applicant__c = :workers[0].Id
        AND Status__c = '承認済'
        AND StartDate__c <= :targetDate
        AND EndDate__c >= :targetDate
    ]) {
      if (lr.RequestType__c == '有給休暇') {
        leaveMinutes += 8 * 60;
      } else if (
        lr.RequestType__c == '半休(午前)' ||
        lr.RequestType__c == '半休(午後)'
      ) {
        leaveMinutes += 4 * 60;
      }
    }
    Integer leaveH = (Integer) Math.floor(leaveMinutes / 60);
    Integer leaveM = (Integer) Math.mod((Integer) Math.round(leaveMinutes), 60);
    attendanceInfo.leaveHours =
      leaveH +
      ':' +
      String.valueOf(leaveM).leftPad(2, '0');
  }
}