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
public with sharing class JIP_HRSecurityController {
  // ===== Properties =====
  public String language { get; set; }
  public String searchKeyword { get; set; }
  public String filterLogType { get; set; }
  public String filterDateRange { get; set; }
  public String selectedTab { get; set; }

  // Data lists
  public List<AuditLogWrapper> auditLogs { get; set; }
  public List<AccessLogWrapper> accessLogs { get; set; }
  public List<ComplianceCheckWrapper> complianceChecks { get; set; }
  public List<SecurityAlertWrapper> securityAlerts { get; set; }

  // Statistics
  public Integer totalLogsToday { get; set; }
  public Integer failedAccessAttempts { get; set; }
  public Integer activeAlerts { get; set; }
  public Integer complianceScore { get; set; }

  // Date filters
  public Date startDate { get; set; }
  public Date endDate { get; set; }

  // ===== Constructor =====
  public JIP_HRSecurityController() {
    language = 'ja';
    searchKeyword = '';
    filterLogType = '';
    filterDateRange = 'today';
    selectedTab = 'audit_logs';
    startDate = Date.today();
    endDate = Date.today();

    loadStatistics();
    loadAuditLogs();
    loadAccessLogs();
    loadComplianceChecks();
    loadSecurityAlerts();
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

    totalLogsToday = [
      SELECT COUNT()
      FROM JIP_AuditLog__c
      WHERE DAY_ONLY(CreatedDate) = :today
    ];

    failedAccessAttempts = [
      SELECT COUNT()
      FROM JIP_AccessLog__c
      WHERE DAY_ONLY(CreatedDate) = :today AND Status__c = 'Failed'
    ];

    activeAlerts = [
      SELECT COUNT()
      FROM JIP_SecurityAlert__c
      WHERE Status__c = 'Active'
    ];

    // Calculate compliance score based on checks
    Integer totalChecks = [SELECT COUNT() FROM JIP_ComplianceCheck__c];
    Integer passedChecks = [
      SELECT COUNT()
      FROM JIP_ComplianceCheck__c
      WHERE Status__c = 'Passed'
    ];
    complianceScore = totalChecks > 0
      ? (passedChecks * 100 / totalChecks)
      : 100;
  }

  private void loadAuditLogs() {
    auditLogs = new List<AuditLogWrapper>();

    Date queryStartDate = getQueryStartDate();
    Date queryEndDate = endDate != null ? endDate : Date.today();

    String query =
      'SELECT Id, Name, Action__c, ObjectType__c, RecordId__c, ' +
      'User__c, User__r.Name, OldValue__c, NewValue__c, IPAddress__c, CreatedDate ' +
      'FROM JIP_AuditLog__c WHERE DAY_ONLY(CreatedDate) >= :queryStartDate ' +
      'AND DAY_ONLY(CreatedDate) <= :queryEndDate';

    if (String.isNotBlank(filterLogType)) {
      query += ' AND Action__c = :filterLogType';
    }

    if (String.isNotBlank(searchKeyword)) {
      String safeKeyword =
        '%' +
        String.escapeSingleQuotes(searchKeyword.trim()) +
        '%';
      query += ' AND (ObjectType__c LIKE :safeKeyword OR User__r.Name LIKE :safeKeyword)';
    }

    query += ' ORDER BY CreatedDate DESC LIMIT 500';

    for (JIP_AuditLog__c log : Database.query(query)) {
      auditLogs.add(new AuditLogWrapper(log, getT()));
    }
  }

  private void loadAccessLogs() {
    accessLogs = new List<AccessLogWrapper>();

    Date queryStartDate = getQueryStartDate();
    Date queryEndDate = endDate != null ? endDate : Date.today();

    for (JIP_AccessLog__c log : [
      SELECT
        Id,
        Name,
        User__c,
        User__r.Name,
        LoginTime__c,
        LogoutTime__c,
        IPAddress__c,
        UserAgent__c,
        Location__c,
        Status__c
      FROM JIP_AccessLog__c
      WHERE
        DAY_ONLY(LoginTime__c) >= :queryStartDate
        AND DAY_ONLY(LoginTime__c) <= :queryEndDate
      ORDER BY LoginTime__c DESC
      LIMIT 500
    ]) {
      accessLogs.add(new AccessLogWrapper(log, getT()));
    }
  }

  private void loadComplianceChecks() {
    complianceChecks = new List<ComplianceCheckWrapper>();

    for (JIP_ComplianceCheck__c check : [
      SELECT
        Id,
        Name,
        CheckType__c,
        Description__c,
        Status__c,
        LastCheckDate__c,
        NextCheckDate__c,
        AssignedTo__r.Name,
        Findings__c
      FROM JIP_ComplianceCheck__c
      ORDER BY NextCheckDate__c ASC NULLS LAST
      LIMIT 100
    ]) {
      complianceChecks.add(new ComplianceCheckWrapper(check, getT()));
    }
  }

  private void loadSecurityAlerts() {
    securityAlerts = new List<SecurityAlertWrapper>();

    for (JIP_SecurityAlert__c alert : [
      SELECT
        Id,
        Name,
        AlertType__c,
        Severity__c,
        Description__c,
        Status__c,
        DetectedDate__c,
        ResolvedDate__c,
        AffectedUser__r.Name
      FROM JIP_SecurityAlert__c
      WHERE Status__c IN ('Active', 'Investigating')
      ORDER BY Severity__c DESC, DetectedDate__c DESC
      LIMIT 100
    ]) {
      securityAlerts.add(new SecurityAlertWrapper(alert, getT()));
    }
  }

  private Date getQueryStartDate() {
    if (filterDateRange == 'today')
      return Date.today();
    if (filterDateRange == 'week')
      return Date.today().addDays(-7);
    if (filterDateRange == 'month')
      return Date.today().addDays(-30);
    if (filterDateRange == 'custom')
      return startDate != null ? startDate : Date.today();
    return Date.today();
  }

  // ===== Action Methods =====
  public void search() {
    loadAuditLogs();
    loadAccessLogs();
  }

  public void clearSearch() {
    searchKeyword = '';
    filterLogType = '';
    filterDateRange = 'today';
    loadAuditLogs();
    loadAccessLogs();
  }

  public void applyDateFilter() {
    loadStatistics();
    loadAuditLogs();
    loadAccessLogs();
  }

  public void changeTab() {
    // Tab bound via property
  }

  public void runComplianceCheck() {
    try {
      Id checkId = ApexPages.currentPage().getParameters().get('checkId');
      if (checkId != null) {
        JIP_ComplianceCheck__c check = [
          SELECT Id, Status__c, LastCheckDate__c
          FROM JIP_ComplianceCheck__c
          WHERE Id = :checkId
          LIMIT 1
        ];
        check.LastCheckDate__c = Date.today();
        update check;

        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            getT().get('compliance_check_complete')
          )
        );

        loadComplianceChecks();
      }
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0))
      );
    }
  }

  public void resolveAlert() {
    try {
      Id alertId = ApexPages.currentPage().getParameters().get('alertId');
      if (alertId != null) {
        JIP_SecurityAlert__c alert = [
          SELECT Id, Status__c
          FROM JIP_SecurityAlert__c
          WHERE Id = :alertId
          LIMIT 1
        ];
        alert.Status__c = 'Resolved';
        alert.ResolvedDate__c = Date.today();
        update alert;

        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            getT().get('alert_resolved')
          )
        );

        loadStatistics();
        loadSecurityAlerts();
      }
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0))
      );
    }
  }

  public void exportLogs() {
    ApexPages.addMessage(
      new ApexPages.Message(
        ApexPages.Severity.INFO,
        getT().get('export') + ': ' + getT().get('in_progress')
      )
    );
  }

  public void changeLanguage() {
    loadAuditLogs();
    loadAccessLogs();
    loadComplianceChecks();
    loadSecurityAlerts();
  }

  // ===== Select Options =====
  public List<SelectOption> getLogTypeOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', getT().get('all')));
    options.add(new SelectOption('Create', getT().get('create')));
    options.add(new SelectOption('Update', getT().get('edit')));
    options.add(new SelectOption('Delete', getT().get('delete')));
    options.add(new SelectOption('View', getT().get('view')));
    options.add(new SelectOption('Export', getT().get('export')));
    options.add(new SelectOption('Login', getT().get('login')));
    options.add(new SelectOption('Logout', getT().get('logout')));
    return options;
  }

  public List<SelectOption> getDateRangeOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('today', getT().get('today')));
    options.add(new SelectOption('week', getT().get('last_7_days')));
    options.add(new SelectOption('month', getT().get('last_30_days')));
    options.add(new SelectOption('custom', getT().get('custom_range')));
    return options;
  }

  public List<SelectOption> getTabOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('audit_logs', getT().get('audit_log')));
    options.add(new SelectOption('access_logs', getT().get('access_log')));
    options.add(new SelectOption('compliance', getT().get('compliance_check')));
    options.add(new SelectOption('alerts', getT().get('security_alerts')));
    return options;
  }

  public List<SelectOption> getLanguageOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('ja', '日本語'));
    options.add(new SelectOption('en', 'English'));
    return options;
  }

  // ===== Wrapper Classes =====
  public class AuditLogWrapper {
    public JIP_AuditLog__c record { get; set; }
    public String logId { get; set; }
    public String action { get; set; }
    public String actionLabel { get; set; }
    public String actionClass { get; set; }
    public String objectType { get; set; }
    public String recordId { get; set; }
    public String userName { get; set; }
    public String oldValue { get; set; }
    public String newValue { get; set; }
    public String ipAddress { get; set; }
    public Datetime timestamp { get; set; }

    public AuditLogWrapper(JIP_AuditLog__c log, Map<String, String> t) {
      this.record = log;
      this.logId = log.Name;
      this.action = log.Action__c;
      this.objectType = log.ObjectType__c;
      this.recordId = log.RecordId__c;
      this.userName = log.User__r != null ? log.User__r.Name : '-';
      this.oldValue = log.OldValue__c;
      this.newValue = log.NewValue__c;
      this.ipAddress = log.IPAddress__c;
      this.timestamp = log.CreatedDate;

      // Action label with styling
      if (log.Action__c == 'Create') {
        this.actionLabel = t.get('create');
        this.actionClass = 'slds-badge slds-badge_success';
      } else if (log.Action__c == 'Update') {
        this.actionLabel = t.get('edit');
        this.actionClass = 'slds-badge slds-badge_info';
      } else if (log.Action__c == 'Delete') {
        this.actionLabel = t.get('delete');
        this.actionClass = 'slds-badge slds-badge_error';
      } else if (log.Action__c == 'View') {
        this.actionLabel = t.get('view');
        this.actionClass = 'slds-badge';
      } else {
        this.actionLabel = log.Action__c;
        this.actionClass = 'slds-badge';
      }
    }
  }

  public class AccessLogWrapper {
    public JIP_AccessLog__c record { get; set; }
    public String userName { get; set; }
    public Datetime loginTime { get; set; }
    public Datetime logoutTime { get; set; }
    public String sessionDuration { get; set; }
    public String ipAddress { get; set; }
    public String userAgent { get; set; }
    public String location { get; set; }
    public String status { get; set; }
    public String statusClass { get; set; }

    public AccessLogWrapper(JIP_AccessLog__c log, Map<String, String> t) {
      this.record = log;
      this.userName = log.User__r != null ? log.User__r.Name : '-';
      this.loginTime = log.LoginTime__c;
      this.logoutTime = log.LogoutTime__c;
      this.ipAddress = log.IPAddress__c;
      this.userAgent = log.UserAgent__c;
      this.location = log.Location__c;

      // Calculate session duration
      if (log.LoginTime__c != null && log.LogoutTime__c != null) {
        Long durationMs =
          log.LogoutTime__c.getTime() - log.LoginTime__c.getTime();
        Long durationMins = durationMs / 1000 / 60;
        if (durationMins < 60) {
          this.sessionDuration = durationMins + ' ' + t.get('minutes');
        } else {
          this.sessionDuration =
            (durationMins / 60) +
            ' ' +
            t.get('hours') +
            ' ' +
            Math.mod(durationMins, 60) +
            ' ' +
            t.get('minutes');
        }
      } else {
        this.sessionDuration = t.get('active');
      }

      // Status styling
      if (log.Status__c == 'Success') {
        this.status = t.get('success');
        this.statusClass = 'slds-badge slds-badge_success';
      } else if (log.Status__c == 'Failed') {
        this.status = t.get('failed');
        this.statusClass = 'slds-badge slds-badge_error';
      } else {
        this.status = log.Status__c;
        this.statusClass = 'slds-badge';
      }
    }
  }

  public class ComplianceCheckWrapper {
    public JIP_ComplianceCheck__c record { get; set; }
    public String checkName { get; set; }
    public String checkType { get; set; }
    public String description { get; set; }
    public String status { get; set; }
    public String statusClass { get; set; }
    public Date lastCheckDate { get; set; }
    public Date nextCheckDate { get; set; }
    public String assignedTo { get; set; }
    public String findings { get; set; }
    public Boolean isOverdue { get; set; }

    public ComplianceCheckWrapper(
      JIP_ComplianceCheck__c check,
      Map<String, String> t
    ) {
      this.record = check;
      this.checkName = check.Name;
      this.checkType = check.CheckType__c;
      this.description = check.Description__c;
      this.lastCheckDate = check.LastCheckDate__c;
      this.nextCheckDate = check.NextCheckDate__c;
      this.assignedTo = check.AssignedTo__r != null
        ? check.AssignedTo__r.Name
        : '-';
      this.findings = check.Findings__c;

      this.isOverdue =
        check.NextCheckDate__c != null &&
        check.NextCheckDate__c < Date.today();

      // Status styling
      if (check.Status__c == 'Passed') {
        this.status = t.get('passed');
        this.statusClass = 'slds-badge slds-badge_success';
      } else if (check.Status__c == 'Failed') {
        this.status = t.get('failed');
        this.statusClass = 'slds-badge slds-badge_error';
      } else if (check.Status__c == 'Pending') {
        this.status = t.get('pending');
        this.statusClass = 'slds-badge slds-badge_warning';
      } else {
        this.status = check.Status__c;
        this.statusClass = 'slds-badge';
      }
    }
  }

  public class SecurityAlertWrapper {
    public JIP_SecurityAlert__c record { get; set; }
    public String alertId { get; set; }
    public String alertType { get; set; }
    public String severity { get; set; }
    public String severityClass { get; set; }
    public String description { get; set; }
    public String status { get; set; }
    public String statusClass { get; set; }
    public Datetime detectedDate { get; set; }
    public Datetime resolvedDate { get; set; }
    public String affectedUser { get; set; }

    public SecurityAlertWrapper(
      JIP_SecurityAlert__c alert,
      Map<String, String> t
    ) {
      this.record = alert;
      this.alertId = alert.Name;
      this.alertType = alert.AlertType__c;
      this.description = alert.Description__c;
      this.detectedDate = alert.DetectedDate__c;
      this.resolvedDate = alert.ResolvedDate__c;
      this.affectedUser = alert.AffectedUser__r != null
        ? alert.AffectedUser__r.Name
        : '-';

      // Severity styling
      if (alert.Severity__c == 'Critical') {
        this.severity = t.get('critical');
        this.severityClass = 'slds-badge slds-badge_error';
      } else if (alert.Severity__c == 'High') {
        this.severity = t.get('high');
        this.severityClass = 'slds-badge slds-badge_warning';
      } else if (alert.Severity__c == 'Medium') {
        this.severity = t.get('medium');
        this.severityClass = 'slds-badge slds-badge_info';
      } else {
        this.severity = t.get('low');
        this.severityClass = 'slds-badge';
      }

      // Status styling
      if (alert.Status__c == 'Active') {
        this.status = t.get('active');
        this.statusClass = 'slds-text-color_error';
      } else if (alert.Status__c == 'Investigating') {
        this.status = t.get('investigating');
        this.statusClass = 'slds-text-color_warning';
      } else if (alert.Status__c == 'Resolved') {
        this.status = t.get('resolved');
        this.statusClass = 'slds-text-color_success';
      } else {
        this.status = alert.Status__c;
        this.statusClass = '';
      }
    }
  }
}