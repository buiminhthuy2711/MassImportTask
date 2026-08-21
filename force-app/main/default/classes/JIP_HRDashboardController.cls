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
public with sharing class JIP_HRDashboardController {
  // ===== Properties =====
  public String language { get; set; }
  public String filterDepartment { get; set; }
  public String filterPeriod { get; set; }
  public String selectedTab { get; set; }

  // Statistics
  public Integer totalEmployees { get; set; }
  public Integer newHiresThisMonth { get; set; }
  public Integer terminationsThisMonth { get; set; }
  public Decimal turnoverRate { get; set; }
  public Decimal avgTenure { get; set; }
  public Decimal avgAge { get; set; }
  public Integer maleCount { get; set; }
  public Integer femaleCount { get; set; }

  // Chart data
  public String headcountTrendJson { get; set; }
  public String departmentDistributionJson { get; set; }
  public String ageDistributionJson { get; set; }
  public String tenureDistributionJson { get; set; }

  // Lists
  public List<DepartmentStatWrapper> departmentStats { get; set; }
  public List<RecentActivityWrapper> recentActivities { get; set; }
  public List<UpcomingEventWrapper> upcomingEvents { get; set; }

  // ===== Constructor =====
  public JIP_HRDashboardController() {
    language = 'ja';
    filterDepartment = '';
    filterPeriod = 'year';
    selectedTab = 'overview';

    loadStatistics();
    loadDepartmentStats();
    loadChartData();
    loadRecentActivities();
    loadUpcomingEvents();
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
    Date startOfMonth = Date.today().toStartOfMonth();
    Date startOfYear = Date.newInstance(Date.today().year(), 1, 1);

    // Total active employees
    totalEmployees = [
      SELECT COUNT()
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職'
    ];

    // New hires this month
    newHiresThisMonth = [
      SELECT COUNT()
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職' AND HireDate__c >= :startOfMonth
    ];

    // Terminations this month
    terminationsThisMonth = [
      SELECT COUNT()
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '退職済' AND EndDate__c >= :startOfMonth
    ];

    // Turnover rate (annual)
    Integer totalTerminationsYear = [
      SELECT COUNT()
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '退職済' AND EndDate__c >= :startOfYear
    ];
    Integer avgHeadcount = totalEmployees > 0 ? totalEmployees : 1;
    turnoverRate = (Decimal.valueOf(totalTerminationsYear) /
      avgHeadcount *
      100)
      .setScale(1);

    // Gender distribution
    maleCount = [
      SELECT COUNT()
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職' AND Gender__c = '男性'
    ];
    femaleCount = [
      SELECT COUNT()
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職' AND Gender__c = '女性'
    ];

    // Average tenure and age
    AggregateResult[] avgResults = [
      SELECT AVG(Age__c) avgAge
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職'
    ];

    if (!avgResults.isEmpty() && avgResults[0].get('avgAge') != null) {
      avgAge = ((Decimal) avgResults[0].get('avgAge')).setScale(1);
    } else {
      avgAge = 0;
    }

    // Calculate average tenure
    List<JIP_Worker__c> workers = [
      SELECT HireDate__c
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職' AND HireDate__c != NULL
    ];

    if (!workers.isEmpty()) {
      Decimal totalDays = 0;
      for (JIP_Worker__c w : workers) {
        totalDays += w.HireDate__c.daysBetween(Date.today());
      }
      avgTenure = (totalDays / workers.size() / 365).setScale(1);
    } else {
      avgTenure = 0;
    }
  }

  private void loadDepartmentStats() {
    departmentStats = new List<DepartmentStatWrapper>();

    Map<Id, DepartmentStatWrapper> deptMap = new Map<Id, DepartmentStatWrapper>();

    for (AggregateResult ar : [
      SELECT Department__c deptId, Department__r.Name deptName, COUNT(Id) cnt
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職' AND Department__c != NULL
      GROUP BY Department__c, Department__r.Name
      ORDER BY COUNT(Id) DESC
      LIMIT 20
    ]) {
      DepartmentStatWrapper stat = new DepartmentStatWrapper();
      stat.departmentId = (Id) ar.get('deptId');
      stat.departmentName = (String) ar.get('deptName');
      stat.employeeCount = (Integer) ar.get('cnt');
      stat.percentage = totalEmployees > 0
        ? (Decimal.valueOf(stat.employeeCount) /
            totalEmployees *
            100)
            .setScale(1)
        : 0;
      deptMap.put(stat.departmentId, stat);
    }

    // Get new hires per department
    for (AggregateResult ar : [
      SELECT Department__c deptId, COUNT(Id) cnt
      FROM JIP_Worker__c
      WHERE
        EmploymentStatus__c = '在職'
        AND HireDate__c >= :Date.today().toStartOfMonth()
        AND Department__c != NULL
      GROUP BY Department__c
    ]) {
      Id deptId = (Id) ar.get('deptId');
      if (deptMap.containsKey(deptId)) {
        deptMap.get(deptId).newHires = (Integer) ar.get('cnt');
      }
    }

    departmentStats.addAll(deptMap.values());
  }

  private void loadChartData() {
    // Headcount trend (last 12 months)
    List<Map<String, Object>> headcountData = new List<Map<String, Object>>();
    for (Integer i = 11; i >= 0; i--) {
      Date monthStart = Date.today().addMonths(-i).toStartOfMonth();
      Date monthEnd = monthStart.addMonths(1).addDays(-1);

      Integer count = [
        SELECT COUNT()
        FROM JIP_Worker__c
        WHERE
          EmploymentStatus__c = '在職'
          AND HireDate__c <= :monthEnd
          AND (EndDate__c = NULL
          OR EndDate__c > :monthEnd)
      ];

      Map<String, Object> dataPoint = new Map<String, Object>();
      dataPoint.put('month', monthStart.month() + '/' + monthStart.year());
      dataPoint.put('count', count);
      headcountData.add(dataPoint);
    }
    headcountTrendJson = JSON.serialize(headcountData);

    // Department distribution
    List<Map<String, Object>> deptData = new List<Map<String, Object>>();
    for (DepartmentStatWrapper ds : departmentStats) {
      Map<String, Object> dataPoint = new Map<String, Object>();
      dataPoint.put('name', ds.departmentName);
      dataPoint.put('value', ds.employeeCount);
      deptData.add(dataPoint);
    }
    departmentDistributionJson = JSON.serialize(deptData);

    // Age distribution
    List<Map<String, Object>> ageData = new List<Map<String, Object>>();
    Map<String, Integer> ageGroups = new Map<String, Integer>{
      '20-29' => 0,
      '30-39' => 0,
      '40-49' => 0,
      '50-59' => 0,
      '60+' => 0
    };

    for (JIP_Worker__c w : [
      SELECT Age__c
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職' AND Age__c != NULL
    ]) {
      Integer age = Integer.valueOf(w.Age__c);
      if (age < 30)
        ageGroups.put('20-29', ageGroups.get('20-29') + 1);
      else if (age < 40)
        ageGroups.put('30-39', ageGroups.get('30-39') + 1);
      else if (age < 50)
        ageGroups.put('40-49', ageGroups.get('40-49') + 1);
      else if (age < 60)
        ageGroups.put('50-59', ageGroups.get('50-59') + 1);
      else
        ageGroups.put('60+', ageGroups.get('60+') + 1);
    }

    for (String ageGroup : ageGroups.keySet()) {
      Map<String, Object> dataPoint = new Map<String, Object>();
      dataPoint.put('group', ageGroup);
      dataPoint.put('count', ageGroups.get(ageGroup));
      ageData.add(dataPoint);
    }
    ageDistributionJson = JSON.serialize(ageData);
  }

  private void loadRecentActivities() {
    recentActivities = new List<RecentActivityWrapper>();

    // Recent hires
    for (JIP_Worker__c w : [
      SELECT
        Id,
        Name,
        LastName__c,
        FirstName__c,
        Department__r.Name,
        HireDate__c
      FROM JIP_Worker__c
      WHERE HireDate__c >= :Date.today().addDays(-30)
      ORDER BY HireDate__c DESC
      LIMIT 5
    ]) {
      RecentActivityWrapper activity = new RecentActivityWrapper();
      activity.activityType = 'hire';
      activity.activityIcon = 'utility:add_user';
      activity.description = getT().get('new_hire') + ': ';
      activity.description += w.LastName__c != null ? w.LastName__c + ' ' : '';
      activity.description += w.FirstName__c != null ? w.FirstName__c : w.Name;
      activity.departmentName = w.Department__r != null
        ? w.Department__r.Name
        : '';
      activity.activityDate = w.HireDate__c;
      recentActivities.add(activity);
    }

    // Recent terminations
    for (JIP_Worker__c w : [
      SELECT Id, Name, LastName__c, FirstName__c, Department__r.Name, EndDate__c
      FROM JIP_Worker__c
      WHERE EndDate__c >= :Date.today().addDays(-30)
      ORDER BY EndDate__c DESC
      LIMIT 5
    ]) {
      RecentActivityWrapper activity = new RecentActivityWrapper();
      activity.activityType = 'termination';
      activity.activityIcon = 'utility:ban';
      activity.description = getT().get('termination') + ': ';
      activity.description += w.LastName__c != null ? w.LastName__c + ' ' : '';
      activity.description += w.FirstName__c != null ? w.FirstName__c : w.Name;
      activity.departmentName = w.Department__r != null
        ? w.Department__r.Name
        : '';
      activity.activityDate = w.EndDate__c;
      recentActivities.add(activity);
    }

    // Sort by date
    recentActivities.sort();
  }

  private void loadUpcomingEvents() {
    upcomingEvents = new List<UpcomingEventWrapper>();

    // Contract expirations
    for (JIP_Contract__c c : [
      SELECT
        Id,
        Worker__r.Name,
        Worker__r.LastName__c,
        Worker__r.FirstName__c,
        ExpirationDate__c
      FROM JIP_Contract__c
      WHERE
        Status__c = 'Active'
        AND ExpirationDate__c >= :Date.today()
        AND ExpirationDate__c <= :Date.today().addDays(30)
      ORDER BY ExpirationDate__c
      LIMIT 5
    ]) {
      UpcomingEventWrapper event = new UpcomingEventWrapper();
      event.eventType = 'contract';
      event.eventIcon = 'utility:file';
      event.title = getT().get('contract_expiring');
      String empName = c.Worker__r.LastName__c != null
        ? c.Worker__r.LastName__c + ' '
        : '';
      empName += c.Worker__r.FirstName__c != null
        ? c.Worker__r.FirstName__c
        : c.Worker__r.Name;
      event.description = empName;
      event.eventDate = c.ExpirationDate__c;
      event.daysRemaining = Date.today().daysBetween(c.ExpirationDate__c);
      upcomingEvents.add(event);
    }

    // Certification expirations
    for (JIP_Certification__c cert : [
      SELECT
        Id,
        Worker__r.Name,
        Worker__r.LastName__c,
        CertificationName__c,
        ExpirationDate__c
      FROM JIP_Certification__c
      WHERE
        Status__c = 'Active'
        AND ExpirationDate__c >= :Date.today()
        AND ExpirationDate__c <= :Date.today().addDays(90)
      ORDER BY ExpirationDate__c
      LIMIT 5
    ]) {
      UpcomingEventWrapper event = new UpcomingEventWrapper();
      event.eventType = 'certification';
      event.eventIcon = 'utility:ribbon';
      event.title = getT().get('cert_expiring');
      event.description =
        cert.CertificationName__c +
        ' - ' +
        cert.Worker__r.Name;
      event.eventDate = cert.ExpirationDate__c;
      event.daysRemaining = Date.today().daysBetween(cert.ExpirationDate__c);
      upcomingEvents.add(event);
    }

    // Sort by date
    upcomingEvents.sort();
  }

  // ===== Action Methods =====
  public void applyFilters() {
    loadStatistics();
    loadDepartmentStats();
    loadChartData();
  }

  public void exportReport() {
    ApexPages.addMessage(
      new ApexPages.Message(
        ApexPages.Severity.INFO,
        getT().get('export') + ': ' + getT().get('in_progress')
      )
    );
  }

  public void changeTab() {
    // Tab bound via property
  }

  public void changeLanguage() {
    loadRecentActivities();
    loadUpcomingEvents();
  }

  // ===== Select Options =====
  public List<SelectOption> getPeriodOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('month', getT().get('this_month')));
    options.add(new SelectOption('quarter', getT().get('this_quarter')));
    options.add(new SelectOption('year', getT().get('this_year')));
    return options;
  }

  public List<SelectOption> getDepartmentOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', getT().get('all')));

    for (JIP_Department__c dept : [
      SELECT Id, Name
      FROM JIP_Department__c
      WHERE IsActive__c = TRUE
      ORDER BY Name
    ]) {
      options.add(new SelectOption(dept.Id, dept.Name));
    }

    return options;
  }

  public List<SelectOption> getTabOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('overview', getT().get('overview')));
    options.add(new SelectOption('headcount', getT().get('headcount_trend')));
    options.add(new SelectOption('demographics', getT().get('demographics')));
    options.add(new SelectOption('turnover', getT().get('turnover_rate')));
    return options;
  }

  public List<SelectOption> getLanguageOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('ja', '日本語'));
    options.add(new SelectOption('en', 'English'));
    return options;
  }

  // ===== Wrapper Classes =====
  public class DepartmentStatWrapper {
    public Id departmentId { get; set; }
    public String departmentName { get; set; }
    public Integer employeeCount { get; set; }
    public Decimal percentage { get; set; }
    public Integer newHires { get; set; }
    public Integer terminations { get; set; }

    public DepartmentStatWrapper() {
      newHires = 0;
      terminations = 0;
    }
  }

  public class RecentActivityWrapper implements Comparable {
    public String activityType { get; set; }
    public String activityIcon { get; set; }
    public String description { get; set; }
    public String departmentName { get; set; }
    public Date activityDate { get; set; }

    public Integer compareTo(Object compareTo) {
      RecentActivityWrapper other = (RecentActivityWrapper) compareTo;
      if (this.activityDate > other.activityDate)
        return -1;
      if (this.activityDate < other.activityDate)
        return 1;
      return 0;
    }
  }

  public class UpcomingEventWrapper implements Comparable {
    public String eventType { get; set; }
    public String eventIcon { get; set; }
    public String title { get; set; }
    public String description { get; set; }
    public Date eventDate { get; set; }
    public Integer daysRemaining { get; set; }
    public String urgencyClass {
      get {
        if (daysRemaining <= 7)
          return 'slds-text-color_error';
        if (daysRemaining <= 14)
          return 'slds-text-color_warning';
        return '';
      }
    }

    public Integer compareTo(Object compareTo) {
      UpcomingEventWrapper other = (UpcomingEventWrapper) compareTo;
      if (this.eventDate < other.eventDate)
        return -1;
      if (this.eventDate > other.eventDate)
        return 1;
      return 0;
    }
  }
}