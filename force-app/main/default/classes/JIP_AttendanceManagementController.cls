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
public with sharing class JIP_AttendanceManagementController {
  // Worker
  public Id selectedWorkerId { get; set; }
  public List<JIP_Worker__c> workerList { get; set; }

  // Date navigation
  public Date selectedDate { get; set; }
  public String selectedDateStr { get; set; }

  // Current record for selected date
  public JIP_Attendance__c currentRecord { get; set; }
  public String checkInTimeStr { get; set; }
  public String checkOutTimeStr { get; set; }

  // Month view
  public Integer viewYear { get; set; }
  public Integer viewMonth { get; set; }
  public List<JIP_Attendance__c> monthlyRecords { get; set; }
  public String calendarDataJson { get; set; }

  // Monthly totals
  public Decimal totalWorkingHours { get; set; }
  public Decimal totalOvertimeHours { get; set; }
  public Integer totalDaysWorked { get; set; }
  public Decimal scheduledMonthlyHours { get; set; }

  public JIP_AttendanceManagementController() {
    workerList = [
      SELECT Id, Name, LastName__c, FirstName__c, Worker_Code__c
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c != '退職済'
      ORDER BY Worker_Code__c ASC
      LIMIT 500
    ];
    selectedDate = Date.today();
    viewYear = selectedDate.year();
    viewMonth = selectedDate.month();
    checkInTimeStr = '';
    checkOutTimeStr = '';
    if (!workerList.isEmpty()) {
      selectedWorkerId = workerList[0].Id;
    }
    loadAll();
  }

  public List<SelectOption> getWorkerOptions() {
    List<SelectOption> options = new List<SelectOption>();
    for (JIP_Worker__c w : workerList) {
      String label = '';
      if (w.Worker_Code__c != null)
        label += w.Worker_Code__c + ' : ';
      if (w.LastName__c != null)
        label += w.LastName__c;
      if (w.FirstName__c != null)
        label += ' ' + w.FirstName__c;
      else
        label += ' ' + w.Name;
      options.add(new SelectOption(w.Id, label));
    }
    return options;
  }

  public String getSelectedWorkerDisplay() {
    if (selectedWorkerId == null)
      return '';
    for (JIP_Worker__c w : workerList) {
      if (w.Id == selectedWorkerId) {
        String d = '';
        if (w.Worker_Code__c != null)
          d += w.Worker_Code__c + ' : ';
        if (w.LastName__c != null)
          d += w.LastName__c;
        if (w.FirstName__c != null)
          d += ' ' + w.FirstName__c;
        return d;
      }
    }
    return '';
  }

  // Date display: 2026年03月17日(火)
  public String getSelectedDateDisplay() {
    if (selectedDate == null)
      return '';
    String[] dayNames = new List<String>{
      '日',
      '月',
      '火',
      '水',
      '木',
      '金',
      '土'
    };
    Integer dow = getDayOfWeek(selectedDate);
    return selectedDate.year() +
      '年' +
      String.valueOf(selectedDate.month()).leftPad(2, '0') +
      '月' +
      String.valueOf(selectedDate.day()).leftPad(2, '0') +
      '日' +
      '(' +
      dayNames[dow] +
      ')';
  }

  public String getSelectedDateIso() {
    return selectedDate != null ? String.valueOf(selectedDate) : '';
  }

  public String getRecordStatusLabel() {
    if (currentRecord == null || currentRecord.Id == null)
      return '未入力';
    if (currentRecord.Status__c != null)
      return currentRecord.Status__c;
    return '入力済';
  }

  public String getCurrentMonth() {
    return viewYear + '年' + String.valueOf(viewMonth).leftPad(2, '0') + '月';
  }

  // Format helpers for display
  public String getTotalWorkingHoursFmt() {
    return formatHM(totalWorkingHours);
  }
  public String getTotalOvertimeHoursFmt() {
    return formatHM(totalOvertimeHours);
  }
  public String getScheduledHoursFmt() {
    return formatHM(scheduledMonthlyHours);
  }

  public String getDailyWorkHoursFmt() {
    return currentRecord != null &&
      currentRecord.WorkingHours__c != null
      ? formatHM(currentRecord.WorkingHours__c)
      : '0:00';
  }

  public String getDailyBreakFmt() {
    return currentRecord != null &&
      currentRecord.BreakMinutes__c != null
      ? formatMinHM(currentRecord.BreakMinutes__c)
      : '0:00';
  }

  public String getDailyOvertimeFmt() {
    return currentRecord != null &&
      currentRecord.OvertimeHours__c != null
      ? formatHM(currentRecord.OvertimeHours__c)
      : '0:00';
  }

  // Day of week: 0=Sun..6=Sat
  private Integer getDayOfWeek(Date d) {
    Date refSunday = Date.newInstance(2023, 1, 1);
    Integer diff = Math.mod(refSunday.daysBetween(d), 7);
    if (diff < 0)
      diff += 7;
    return diff;
  }

  // Navigation
  public void prevDate() {
    selectedDate = selectedDate.addDays(-1);
    syncViewMonth();
    loadDateRecord();
  }

  public void nextDate() {
    selectedDate = selectedDate.addDays(1);
    syncViewMonth();
    loadDateRecord();
  }

  public void goToDate() {
    if (String.isNotBlank(selectedDateStr)) {
      try {
        selectedDate = Date.valueOf(selectedDateStr);
        syncViewMonth();
        loadDateRecord();
      } catch (Exception e) {
        /* ignore */
      }
    }
  }

  public void selectWorker() {
    loadAll();
  }

  public void prevMonth() {
    viewMonth--;
    if (viewMonth < 1) {
      viewMonth = 12;
      viewYear--;
    }
    Integer maxDay = Date.daysInMonth(viewYear, viewMonth);
    selectedDate = Date.newInstance(
      viewYear,
      viewMonth,
      Math.min(selectedDate.day(), maxDay)
    );
    loadAll();
  }

  public void nextMonth() {
    viewMonth++;
    if (viewMonth > 12) {
      viewMonth = 1;
      viewYear++;
    }
    Integer maxDay = Date.daysInMonth(viewYear, viewMonth);
    selectedDate = Date.newInstance(
      viewYear,
      viewMonth,
      Math.min(selectedDate.day(), maxDay)
    );
    loadAll();
  }

  private void syncViewMonth() {
    if (selectedDate.year() != viewYear || selectedDate.month() != viewMonth) {
      viewYear = selectedDate.year();
      viewMonth = selectedDate.month();
      loadMonthlyRecords();
    }
  }

  // CRUD
  public void saveRecord() {
    if (selectedWorkerId == null) {
      addError('社員を選択してください。');
      return;
    }
    try {
      currentRecord.Worker__c = selectedWorkerId;
      currentRecord.AttendanceDate__c = selectedDate;

      if (String.isNotBlank(checkInTimeStr)) {
        currentRecord.CheckInTime__c = parseTimeToDateTime(
          selectedDate,
          checkInTimeStr
        );
      } else {
        currentRecord.CheckInTime__c = null;
      }
      if (String.isNotBlank(checkOutTimeStr)) {
        currentRecord.CheckOutTime__c = parseTimeToDateTime(
          selectedDate,
          checkOutTimeStr
        );
      } else {
        currentRecord.CheckOutTime__c = null;
      }

      calculateHours();

      if (currentRecord.Id != null) {
        update currentRecord;
        addSuccess('勤務実績を更新しました。');
      } else {
        insert currentRecord;
        addSuccess('勤務実績を登録しました。');
      }
      loadDateRecord();
      loadMonthlyRecords();
    } catch (Exception e) {
      addError('エラー: ' + e.getMessage());
    }
  }

  public void saveDraft() {
    if (selectedWorkerId == null) {
      addError('社員を選択してください。');
      return;
    }
    try {
      currentRecord.Worker__c = selectedWorkerId;
      currentRecord.AttendanceDate__c = selectedDate;

      if (String.isNotBlank(checkInTimeStr)) {
        currentRecord.CheckInTime__c = parseTimeToDateTime(
          selectedDate,
          checkInTimeStr
        );
      }
      if (String.isNotBlank(checkOutTimeStr)) {
        currentRecord.CheckOutTime__c = parseTimeToDateTime(
          selectedDate,
          checkOutTimeStr
        );
      }

      if (currentRecord.Id != null) {
        update currentRecord;
      } else {
        insert currentRecord;
      }
      addSuccess('下書きを保存しました。');
      loadDateRecord();
      loadMonthlyRecords();
    } catch (Exception e) {
      addError('エラー: ' + e.getMessage());
    }
  }

  public void clearRecord() {
    currentRecord = new JIP_Attendance__c(
      Worker__c = selectedWorkerId,
      AttendanceDate__c = selectedDate,
      Status__c = '出勤',
      BreakMinutes__c = 60
    );
    checkInTimeStr = '';
    checkOutTimeStr = '';
  }

  public void deleteRecord() {
    if (currentRecord != null && currentRecord.Id != null) {
      try {
        delete currentRecord;
        addSuccess('勤務実績を削除しました。');
        clearRecord();
        loadMonthlyRecords();
      } catch (Exception e) {
        addError('削除エラー: ' + e.getMessage());
      }
    }
  }

  // Quick punch (current time)
  public void quickCheckIn() {
    if (selectedWorkerId == null) {
      addError('社員を選択してください。');
      return;
    }
    DateTime nowDt = DateTime.now();
    currentRecord.Worker__c = selectedWorkerId;
    currentRecord.AttendanceDate__c = selectedDate;
    currentRecord.CheckInTime__c = nowDt;
    if (currentRecord.Status__c == null)
      currentRecord.Status__c = '出勤';
    if (currentRecord.BreakMinutes__c == null)
      currentRecord.BreakMinutes__c = 60;
    try {
      if (currentRecord.Id != null) {
        update currentRecord;
      } else {
        insert currentRecord;
      }
      checkInTimeStr = nowDt.format('HH:mm', 'Asia/Tokyo');
      addSuccess('出勤を打刻しました。(' + checkInTimeStr + ')');
      loadDateRecord();
      loadMonthlyRecords();
    } catch (Exception e) {
      addError('エラー: ' + e.getMessage());
    }
  }

  public void quickCheckOut() {
    if (currentRecord == null || currentRecord.CheckInTime__c == null) {
      addError('出勤打刻がありません。');
      return;
    }
    DateTime nowDt = DateTime.now();
    currentRecord.CheckOutTime__c = nowDt;
    currentRecord.Status__c = '退勤済';
    calculateHours();
    try {
      update currentRecord;
      checkOutTimeStr = nowDt.format('HH:mm', 'Asia/Tokyo');
      addSuccess('退勤を打刻しました。(' + checkOutTimeStr + ')');
      loadDateRecord();
      loadMonthlyRecords();
    } catch (Exception e) {
      addError('エラー: ' + e.getMessage());
    }
  }

  // Private helpers
  private void calculateHours() {
    if (
      currentRecord.CheckInTime__c != null &&
      currentRecord.CheckOutTime__c != null
    ) {
      Decimal totalMin =
        (Decimal) (currentRecord.CheckOutTime__c.getTime() -
        currentRecord.CheckInTime__c.getTime()) / 60000;
      Decimal breakMin = currentRecord.BreakMinutes__c != null
        ? currentRecord.BreakMinutes__c
        : 60;
      Decimal netMin = totalMin - breakMin;
      if (netMin < 0)
        netMin = 0;
      currentRecord.WorkingHours__c = (netMin / 60)
        .setScale(2, RoundingMode.HALF_UP);
      currentRecord.OvertimeHours__c = currentRecord.WorkingHours__c > 8
        ? (currentRecord.WorkingHours__c - 8).setScale(2, RoundingMode.HALF_UP)
        : 0;
      if (currentRecord.Status__c == '出勤') {
        currentRecord.Status__c = '退勤済';
      }
    }
  }

  private void loadAll() {
    loadDateRecord();
    loadMonthlyRecords();
  }

  private void loadDateRecord() {
    if (selectedWorkerId == null || selectedDate == null) {
      clearRecord();
      return;
    }
    List<JIP_Attendance__c> recs = [
      SELECT
        Id,
        Worker__c,
        AttendanceDate__c,
        CheckInTime__c,
        CheckOutTime__c,
        WorkingHours__c,
        OvertimeHours__c,
        BreakMinutes__c,
        Status__c,
        Notes__c
      FROM JIP_Attendance__c
      WHERE Worker__c = :selectedWorkerId AND AttendanceDate__c = :selectedDate
      LIMIT 1
    ];
    if (!recs.isEmpty()) {
      currentRecord = recs[0];
      checkInTimeStr = currentRecord.CheckInTime__c != null
        ? currentRecord.CheckInTime__c.format('HH:mm', 'Asia/Tokyo')
        : '';
      checkOutTimeStr = currentRecord.CheckOutTime__c != null
        ? currentRecord.CheckOutTime__c.format('HH:mm', 'Asia/Tokyo')
        : '';
    } else {
      currentRecord = new JIP_Attendance__c(
        Worker__c = selectedWorkerId,
        AttendanceDate__c = selectedDate,
        Status__c = '出勤',
        BreakMinutes__c = 60
      );
      checkInTimeStr = '';
      checkOutTimeStr = '';
    }
  }

  private void loadMonthlyRecords() {
    if (selectedWorkerId == null) {
      monthlyRecords = new List<JIP_Attendance__c>();
      calendarDataJson = '{}';
      totalWorkingHours = 0;
      totalOvertimeHours = 0;
      totalDaysWorked = 0;
      scheduledMonthlyHours = 0;
      return;
    }
    Date startDate = Date.newInstance(viewYear, viewMonth, 1);
    Date endDate = startDate.addMonths(1).addDays(-1);

    monthlyRecords = [
      SELECT
        Id,
        AttendanceDate__c,
        CheckInTime__c,
        CheckOutTime__c,
        WorkingHours__c,
        OvertimeHours__c,
        BreakMinutes__c,
        Status__c,
        Notes__c
      FROM JIP_Attendance__c
      WHERE
        Worker__c = :selectedWorkerId
        AND AttendanceDate__c >= :startDate
        AND AttendanceDate__c <= :endDate
      ORDER BY AttendanceDate__c ASC
    ];

    totalWorkingHours = 0;
    totalOvertimeHours = 0;
    totalDaysWorked = 0;
    Map<String, String> calMap = new Map<String, String>();

    for (JIP_Attendance__c a : monthlyRecords) {
      if (a.WorkingHours__c != null)
        totalWorkingHours += a.WorkingHours__c;
      if (a.OvertimeHours__c != null)
        totalOvertimeHours += a.OvertimeHours__c;
      if (a.Status__c == '退勤済' || a.Status__c == '出勤')
        totalDaysWorked++;
      calMap.put(
        String.valueOf(a.AttendanceDate__c),
        a.Status__c != null ? a.Status__c : ''
      );
    }

    // Count weekdays for scheduled hours
    Integer weekdays = 0;
    Date d = startDate;
    while (d <= endDate) {
      Integer dow = getDayOfWeek(d);
      if (dow >= 1 && dow <= 5)
        weekdays++;
      d = d.addDays(1);
    }
    scheduledMonthlyHours = weekdays * 8;
    calendarDataJson = JSON.serialize(calMap);
  }

  private DateTime parseTimeToDateTime(Date d, String timeStr) {
    if (String.isBlank(timeStr))
      return null;
    try {
      String[] parts = timeStr.trim().split(':');
      Integer h = Integer.valueOf(parts[0]);
      Integer m = parts.size() > 1 ? Integer.valueOf(parts[1]) : 0;
      return DateTime.newInstance(d, Time.newInstance(h, m, 0, 0));
    } catch (Exception e) {
      return null;
    }
  }

  private String formatHM(Decimal hours) {
    if (hours == null)
      return '0:00';
    Integer h = hours.intValue();
    Integer m = Math.mod(((hours - h).abs() * 60).intValue(), 60);
    return h + ':' + String.valueOf(m).leftPad(2, '0');
  }

  private String formatMinHM(Decimal minutes) {
    if (minutes == null)
      return '0:00';
    Integer h = (minutes / 60).intValue();
    Integer m = Math.mod(minutes.intValue(), 60);
    return h + ':' + String.valueOf(m).leftPad(2, '0');
  }

  private void addSuccess(String msg) {
    ApexPages.addMessage(
      new ApexPages.Message(ApexPages.Severity.CONFIRM, msg)
    );
  }

  private void addError(String msg) {
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
  }
}