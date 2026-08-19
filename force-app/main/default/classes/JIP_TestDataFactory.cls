/**
 * Copyright (c) 2023-2026 JIP Academy (Tokyo, Japan).
 * Developed by JIP Academy R&D Team / Nguyen Minh Phuong.
 * All rights reserved.
 */
@isTest
public class JIP_TestDataFactory {
  /**
   * Create Department record
   */
  public static JIP_Department__c createDepartment(
    String name,
    Boolean doInsert
  ) {
    JIP_Department__c dept = new JIP_Department__c(
      Name = name,
      DepartmentCode__c = 'DEPT-' +
        String.valueOf(System.currentTimeMillis()).right(6),
      IsActive__c = true
    );
    if (doInsert)
      insert dept;
    return dept;
  }

  /**
   * Create Worker record
   */
  public static JIP_Worker__c createWorker(
    String name,
    Id departmentId,
    Boolean doInsert
  ) {
    JIP_Worker__c worker = new JIP_Worker__c(
      Name = name,
      Email__c = name.replaceAll(' ', '.').toLowerCase() + '@test.com',
      Department__c = departmentId
    );
    if (doInsert)
      insert worker;
    return worker;
  }

  /**
   * Create Project record
   */
  public static JIP_Project__c createProject(String name, Boolean doInsert) {
    JIP_Project__c proj = new JIP_Project__c(
      Name = name,
      Name__c = name,
      Status__c = 'Active',
      StartDate__c = Date.today(),
      EndDate__c = Date.today().addMonths(6)
    );
    if (doInsert)
      insert proj;
    return proj;
  }

  /**
   * Create ProjectTask record
   */
  public static JIP_ProjectTask__c createTask(
    String subject,
    Id projectId,
    Boolean doInsert
  ) {
    JIP_ProjectTask__c task = new JIP_ProjectTask__c(
      Subject__c = subject,
      Project__c = projectId,
      Status__c = '未対応',
      Priority__c = '中',
      StartDate__c = Date.today(),
      DueDate__c = Date.today().addDays(14)
    );
    if (doInsert)
      insert task;
    return task;
  }

  /**
   * Create Attendance record
   */
  public static JIP_Attendance__c createAttendance(
    Id workerId,
    Date attendanceDate,
    Boolean doInsert
  ) {
    JIP_Attendance__c att = new JIP_Attendance__c(
      Worker__c = workerId,
      AttendanceDate__c = attendanceDate,
      CheckInTime__c = DateTime.newInstance(
        attendanceDate,
        Time.newInstance(9, 0, 0, 0)
      ),
      CheckOutTime__c = DateTime.newInstance(
        attendanceDate,
        Time.newInstance(18, 0, 0, 0)
      ),
      Status__c = '出勤'
    );
    if (doInsert)
      insert att;
    return att;
  }

  /**
   * Create Document record
   */
  public static JIP_Document__c createDocument(String title, Boolean doInsert) {
    JIP_Document__c doc = new JIP_Document__c(
      Name = title,
      Description__c = 'Test document'
    );
    if (doInsert)
      insert doc;
    return doc;
  }

  /**
   * Create Skill record
   */
  public static JIP_Skill__c createSkill(String name, Boolean doInsert) {
    JIP_Skill__c skill = new JIP_Skill__c(Name = name, Category__c = 'Tool');
    if (doInsert)
      insert skill;
    return skill;
  }

  /**
   * Create Job record
   */
  public static JIP_Job__c createJob(String title, Boolean doInsert) {
    // Create Account for Company lookup
    Account company = new Account(
      Name = 'Test Company ' +
        String.valueOf(System.currentTimeMillis()).right(6)
    );
    insert company;

    JIP_Job__c job = new JIP_Job__c(
      Name = title,
      JobTitle__c = title,
      Company__c = company.Id,
      Priority__c = 'Medium',
      Status__c = 'Open',
      StartDate__c = Date.today()
    );
    if (doInsert)
      insert job;
    return job;
  }

  /**
   * Create Candidate record
   */
  public static JIP_Candidate__c createCandidate(
    String name,
    Boolean doInsert
  ) {
    JIP_Candidate__c candidate = new JIP_Candidate__c(
      Name = name,
      Full_name__c = name,
      Email__c = name.replaceAll(' ', '.').toLowerCase() + '@candidate.com',
      CurrentStatus__c = 'Active'
    );
    if (doInsert)
      insert candidate;
    return candidate;
  }

  /**
   * Create LeaveRequest record
   */
  public static JIP_LeaveRequest__c createLeaveRequest(
    Id workerId,
    Boolean doInsert
  ) {
    JIP_LeaveRequest__c leave = new JIP_LeaveRequest__c(
      Applicant__c = workerId,
      StartDate__c = Date.today().addDays(7),
      EndDate__c = Date.today().addDays(9)
    );
    if (doInsert)
      insert leave;
    return leave;
  }

  /**
   * Create Request record
   */
  public static JIP_Request__c createRequest(Id applicantId, Boolean doInsert) {
    // Applicant__c is a User lookup, use running user if wrong type passed
    Id userId = (applicantId != null &&
      String.valueOf(applicantId).startsWith('005'))
      ? applicantId
      : UserInfo.getUserId();
    JIP_Request__c req = new JIP_Request__c(
      Applicant__c = userId,
      Status__c = 'Pending',
      RequestType__c = 'その他'
    );
    if (doInsert)
      insert req;
    return req;
  }

  /**
   * Create Contract record
   */
  public static JIP_Contract__c createContract(Id workerId, Boolean doInsert) {
    JIP_Contract__c contract = new JIP_Contract__c(
      Worker__c = workerId,
      StartDate__c = Date.today(),
      ExpirationDate__c = Date.today().addYears(1),
      Status__c = 'Active'
    );
    if (doInsert)
      insert contract;
    return contract;
  }

  /**
   * Create Evaluation record
   */
  public static JIP_Evaluation__c createEvaluation(
    Id workerId,
    Boolean doInsert
  ) {
    JIP_Evaluation__c eval = new JIP_Evaluation__c(
      Worker__c = workerId,
      EvaluationPeriod__c = '2024 Q1',
      Status__c = 'Draft'
    );
    if (doInsert)
      insert eval;
    return eval;
  }

  /**
   * Create Payslip record
   */
  public static JIP_Payslip__c createPayslip(Id workerId, Boolean doInsert) {
    JIP_Payslip__c payslip = new JIP_Payslip__c(
      Worker__c = workerId,
      PaymentDate__c = Date.today(),
      BaseSalary__c = 300000,
      Status__c = 'Pending'
    );
    if (doInsert)
      insert payslip;
    return payslip;
  }

  /**
   * Create Training record
   */
  public static JIP_Training__c createTraining(String title, Boolean doInsert) {
    JIP_Training__c training = new JIP_Training__c(
      Name = title,
      TrainingName__c = title,
      StartDate__c = Date.today(),
      EndDate__c = Date.today().addDays(3),
      Status__c = 'Planned'
    );
    if (doInsert)
      insert training;
    return training;
  }

  /**
   * Create Certification record
   */
  public static JIP_Certification__c createCertification(
    Id workerId,
    String certName,
    Boolean doInsert
  ) {
    JIP_Certification__c cert = new JIP_Certification__c(
      Name = certName,
      Worker__c = workerId
    );
    if (doInsert)
      insert cert;
    return cert;
  }

  /**
   * Create ProjectMember record
   */
  public static JIP_ProjectMember__c createProjectMember(
    Id projectId,
    Id workerId,
    Boolean doInsert
  ) {
    JIP_ProjectMember__c member = new JIP_ProjectMember__c(
      Project__c = projectId,
      Worker__c = workerId,
      Role__c = 'メンバー'
    );
    if (doInsert)
      insert member;
    return member;
  }

  /**
   * Create SecurityAlert record
   */
  public static JIP_SecurityAlert__c createSecurityAlert(
    String alertType,
    Boolean doInsert
  ) {
    JIP_SecurityAlert__c alert = new JIP_SecurityAlert__c(
      Severity__c = 'Medium',
      Status__c = 'Active',
      DetectedDate__c = Date.today()
    );
    if (doInsert)
      insert alert;
    return alert;
  }
}