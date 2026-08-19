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
public with sharing class JIP_HRSalaryController {
  // ===== Properties =====
  public String language { get; set; }
  public String searchKeyword { get; set; }
  public String filterDepartment { get; set; }
  public String filterYear { get; set; }
  public String filterMonth { get; set; }
  public String selectedTab { get; set; }

  // Data lists
  public List<PayslipWrapper> payslips { get; set; }
  public List<EvaluationWrapper> evaluations { get; set; }
  public List<SalaryStatWrapper> salaryStats { get; set; }

  // Statistics
  public Decimal totalPayroll { get; set; }
  public Decimal averageSalary { get; set; }
  public Integer processedCount { get; set; }
  public Integer pendingCount { get; set; }

  // ===== Constructor =====
  public JIP_HRSalaryController() {
    language = 'ja';
    searchKeyword = '';
    filterDepartment = '';
    filterYear = String.valueOf(Date.today().year());
    filterMonth = String.valueOf(Date.today().month()).leftPad(2, '0');
    selectedTab = 'payslip';

    loadStatistics();
    loadPayslips();
    loadEvaluations();
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
    // Calculate payroll statistics
    AggregateResult[] results = [
      SELECT
        SUM(TotalPayment__c) sumTotal,
        AVG(TotalPayment__c) avgTotal,
        COUNT(Id) cnt
      FROM JIP_Payslip__c
      WHERE
        CALENDAR_YEAR(PaymentDate__c) = :Integer.valueOf(filterYear)
        AND CALENDAR_MONTH(PaymentDate__c) = :Integer.valueOf(filterMonth)
        AND Status__c = 'Paid'
    ];

    if (!results.isEmpty()) {
      totalPayroll = (Decimal) results[0].get('sumTotal');
      averageSalary = (Decimal) results[0].get('avgTotal');
      processedCount = (Integer) results[0].get('cnt');
    } else {
      totalPayroll = 0;
      averageSalary = 0;
      processedCount = 0;
    }

    if (totalPayroll == null)
      totalPayroll = 0;
    if (averageSalary == null)
      averageSalary = 0;

    // Count pending
    pendingCount = [
      SELECT COUNT()
      FROM JIP_Payslip__c
      WHERE
        CALENDAR_YEAR(PaymentDate__c) = :Integer.valueOf(filterYear)
        AND CALENDAR_MONTH(PaymentDate__c) = :Integer.valueOf(filterMonth)
        AND Status__c = 'Pending'
    ];
  }

  private void loadPayslips() {
    payslips = new List<PayslipWrapper>();

    String query =
      'SELECT Id, Name, Worker__c, Worker__r.Name, Worker__r.LastName__c, ' +
      'Worker__r.FirstName__c, Worker__r.Worker_Code__c, Worker__r.Department__r.Name, ' +
      'BaseSalary__c, Allowances__c, Deductions__c, TotalPayment__c, ' +
      'PaymentDate__c, Status__c ' +
      'FROM JIP_Payslip__c ' +
      'WHERE CALENDAR_YEAR(PaymentDate__c) = :year ' +
      'AND CALENDAR_MONTH(PaymentDate__c) = :month';

    Integer year = Integer.valueOf(filterYear);
    Integer month = Integer.valueOf(filterMonth);

    if (String.isNotBlank(filterDepartment)) {
      query += ' AND Worker__r.Department__c = :filterDepartment';
    }

    if (String.isNotBlank(searchKeyword)) {
      String safeKeyword =
        '%' +
        String.escapeSingleQuotes(searchKeyword.trim()) +
        '%';
      query += ' AND (Worker__r.Name LIKE :safeKeyword OR Worker__r.Worker_Code__c LIKE :safeKeyword)';
    }

    query += ' ORDER BY Worker__r.Worker_Code__c ASC LIMIT 500';

    for (JIP_Payslip__c p : Database.query(query)) {
      payslips.add(new PayslipWrapper(p, getT()));
    }
  }

  private void loadEvaluations() {
    evaluations = new List<EvaluationWrapper>();

    for (JIP_Evaluation__c ev : [
      SELECT
        Id,
        Name,
        Worker__c,
        Worker__r.Name,
        Worker__r.LastName__c,
        Worker__r.FirstName__c,
        Worker__r.Worker_Code__c,
        Worker__r.Department__r.Name,
        EvaluationPeriod__c,
        TotalScore__c,
        Grade__c,
        Status__c,
        EvaluatedBy__r.Name
      FROM JIP_Evaluation__c
      WHERE CALENDAR_YEAR(CreatedDate) = :Integer.valueOf(filterYear)
      ORDER BY CreatedDate DESC
      LIMIT 200
    ]) {
      evaluations.add(new EvaluationWrapper(ev, getT()));
    }
  }

  // ===== Action Methods =====
  public void search() {
    loadPayslips();
  }

  public void clearSearch() {
    searchKeyword = '';
    filterDepartment = '';
    loadPayslips();
  }

  public void applyFilters() {
    loadStatistics();
    loadPayslips();
    loadEvaluations();
  }

  public void changeTab() {
    // Tab is bound via property
  }

  public void processPayroll() {
    try {
      // Batch process pending payslips
      List<JIP_Payslip__c> pendingPayslips = [
        SELECT Id, Status__c
        FROM JIP_Payslip__c
        WHERE
          CALENDAR_YEAR(PaymentDate__c) = :Integer.valueOf(filterYear)
          AND CALENDAR_MONTH(PaymentDate__c) = :Integer.valueOf(filterMonth)
          AND Status__c = 'Pending'
        LIMIT 200
      ];

      for (JIP_Payslip__c p : pendingPayslips) {
        p.Status__c = 'Paid';
      }

      if (!pendingPayslips.isEmpty()) {
        update pendingPayslips;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            pendingPayslips.size() +
              ' ' +
              getT().get('payslip') +
              ' ' +
              getT().get('processed')
          )
        );
      }

      loadStatistics();
      loadPayslips();
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0))
      );
    }
  }

  public void exportPayslips() {
    // Export logic here
    ApexPages.addMessage(
      new ApexPages.Message(
        ApexPages.Severity.INFO,
        getT().get('export') + ': ' + getT().get('in_progress')
      )
    );
  }

  public void changeLanguage() {
    loadPayslips();
    loadEvaluations();
  }

  // ===== Select Options =====
  public List<SelectOption> getYearOptions() {
    List<SelectOption> options = new List<SelectOption>();
    Integer currentYear = Date.today().year();
    for (Integer y = currentYear; y >= currentYear - 5; y--) {
      options.add(
        new SelectOption(
          String.valueOf(y),
          String.valueOf(y) + getT().get('year_suffix')
        )
      );
    }
    return options;
  }

  public List<SelectOption> getMonthOptions() {
    List<SelectOption> options = new List<SelectOption>();
    for (Integer m = 1; m <= 12; m++) {
      String val = String.valueOf(m).leftPad(2, '0');
      options.add(
        new SelectOption(val, String.valueOf(m) + getT().get('month_suffix'))
      );
    }
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
    options.add(new SelectOption('payslip', getT().get('payslip')));
    options.add(new SelectOption('bonus', getT().get('bonus')));
    options.add(new SelectOption('evaluation', getT().get('evaluation')));
    options.add(
      new SelectOption('projection', getT().get('salary_projection'))
    );
    return options;
  }

  public List<SelectOption> getLanguageOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('ja', '日本語'));
    options.add(new SelectOption('en', 'English'));
    return options;
  }

  // ===== Wrapper Classes =====
  public class PayslipWrapper {
    public JIP_Payslip__c record { get; set; }
    public String employeeCode { get; set; }
    public String employeeName { get; set; }
    public String departmentName { get; set; }
    public Decimal baseSalary { get; set; }
    public Decimal allowances { get; set; }
    public Decimal deductions { get; set; }
    public Decimal totalPayment { get; set; }
    public String status { get; set; }
    public String statusClass { get; set; }

    public PayslipWrapper(JIP_Payslip__c p, Map<String, String> t) {
      this.record = p;
      this.employeeCode = p.Worker__r != null ? p.Worker__r.Worker_Code__c : '';
      this.baseSalary = p.BaseSalary__c != null ? p.BaseSalary__c : 0;
      this.allowances = p.Allowances__c != null ? p.Allowances__c : 0;
      this.deductions = p.Deductions__c != null ? p.Deductions__c : 0;
      this.totalPayment = p.TotalPayment__c != null ? p.TotalPayment__c : 0;

      if (p.Worker__r != null) {
        if (p.Worker__r.LastName__c != null) {
          this.employeeName = p.Worker__r.LastName__c;
          if (p.Worker__r.FirstName__c != null) {
            this.employeeName += ' ' + p.Worker__r.FirstName__c;
          }
        } else {
          this.employeeName = p.Worker__r.Name;
        }
        this.departmentName = p.Worker__r.Department__r != null
          ? p.Worker__r.Department__r.Name
          : '-';
      } else {
        this.employeeName = '-';
        this.departmentName = '-';
      }

      // Status with localization
      if (p.Status__c == 'Paid') {
        this.status = t.get('paid');
        this.statusClass = 'slds-badge slds-badge_success';
      } else if (p.Status__c == 'Pending') {
        this.status = t.get('pending_payment');
        this.statusClass = 'slds-badge slds-badge_warning';
      } else {
        this.status = p.Status__c;
        this.statusClass = 'slds-badge';
      }
    }
  }

  public class EvaluationWrapper {
    public JIP_Evaluation__c record { get; set; }
    public String employeeCode { get; set; }
    public String employeeName { get; set; }
    public String departmentName { get; set; }
    public String period { get; set; }
    public Decimal totalScore { get; set; }
    public String grade { get; set; }
    public String gradeClass { get; set; }
    public String evaluator { get; set; }
    public String status { get; set; }

    public EvaluationWrapper(JIP_Evaluation__c ev, Map<String, String> t) {
      this.record = ev;
      this.employeeCode = ev.Worker__r != null
        ? ev.Worker__r.Worker_Code__c
        : '';
      this.period = ev.EvaluationPeriod__c;
      this.totalScore = ev.TotalScore__c != null ? ev.TotalScore__c : 0;
      this.grade = ev.Grade__c;
      this.evaluator = ev.EvaluatedBy__r != null ? ev.EvaluatedBy__r.Name : '-';
      this.status = ev.Status__c;

      if (ev.Worker__r != null) {
        if (ev.Worker__r.LastName__c != null) {
          this.employeeName = ev.Worker__r.LastName__c;
          if (ev.Worker__r.FirstName__c != null) {
            this.employeeName += ' ' + ev.Worker__r.FirstName__c;
          }
        } else {
          this.employeeName = ev.Worker__r.Name;
        }
        this.departmentName = ev.Worker__r.Department__r != null
          ? ev.Worker__r.Department__r.Name
          : '-';
      } else {
        this.employeeName = '-';
        this.departmentName = '-';
      }

      // Grade styling
      if (grade == 'S' || grade == 'A') {
        gradeClass = 'slds-badge slds-badge_success';
      } else if (grade == 'B') {
        gradeClass = 'slds-badge slds-badge_info';
      } else if (grade == 'C') {
        gradeClass = 'slds-badge slds-badge_warning';
      } else {
        gradeClass = 'slds-badge';
      }
    }
  }

  public class SalaryStatWrapper {
    public String departmentName { get; set; }
    public Integer employeeCount { get; set; }
    public Decimal totalSalary { get; set; }
    public Decimal averageSalary { get; set; }
    public Decimal minSalary { get; set; }
    public Decimal maxSalary { get; set; }
  }
}