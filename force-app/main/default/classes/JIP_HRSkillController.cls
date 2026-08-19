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
public with sharing class JIP_HRSkillController {
  // ===== Properties =====
  public String language { get; set; }
  public String searchKeyword { get; set; }
  public String filterDepartment { get; set; }
  public String filterSkillCategory { get; set; }
  public String selectedTab { get; set; }

  // Data lists
  public List<SkillWrapper> skills { get; set; }
  public List<CertificationWrapper> certifications { get; set; }
  public List<TrainingWrapper> trainings { get; set; }
  public List<CareerPathWrapper> careerPaths { get; set; }

  // Statistics
  public Integer totalSkills { get; set; }
  public Integer totalCertifications { get; set; }
  public Integer expiringCertifications { get; set; }
  public Integer upcomingTrainings { get; set; }

  // ===== Constructor =====
  public JIP_HRSkillController() {
    language = 'ja';
    searchKeyword = '';
    filterDepartment = '';
    filterSkillCategory = '';
    selectedTab = 'skills';

    loadStatistics();
    loadSkills();
    loadCertifications();
    loadTrainings();
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
    totalSkills = [SELECT COUNT() FROM JIP_Skill__c];
    totalCertifications = [
      SELECT COUNT()
      FROM JIP_Certification__c
      WHERE Status__c = 'Active'
    ];
    expiringCertifications = [
      SELECT COUNT()
      FROM JIP_Certification__c
      WHERE
        Status__c = 'Active'
        AND ExpirationDate__c <= :Date.today().addDays(90)
        AND ExpirationDate__c >= :Date.today()
    ];
    upcomingTrainings = [
      SELECT COUNT()
      FROM JIP_Training__c
      WHERE
        StartDate__c >= :Date.today()
        AND StartDate__c <= :Date.today().addDays(30)
    ];
  }

  private void loadSkills() {
    skills = new List<SkillWrapper>();

    String query =
      'SELECT Id, Name, Worker__c, Worker__r.Name, Worker__r.LastName__c, ' +
      'Worker__r.FirstName__c, Worker__r.Worker_Code__c, Worker__r.Department__r.Name, ' +
      'SkillCategory__c, SkillName__c, ProficiencyLevel__c, YearsOfExperience__c, LastUsed__c ' +
      'FROM JIP_Skill__c WHERE Id != null';

    if (String.isNotBlank(filterDepartment)) {
      query += ' AND Worker__r.Department__c = :filterDepartment';
    }

    if (String.isNotBlank(filterSkillCategory)) {
      query += ' AND SkillCategory__c = :filterSkillCategory';
    }

    if (String.isNotBlank(searchKeyword)) {
      String safeKeyword =
        '%' +
        String.escapeSingleQuotes(searchKeyword.trim()) +
        '%';
      query += ' AND (SkillName__c LIKE :safeKeyword OR Worker__r.Name LIKE :safeKeyword)';
    }

    query += ' ORDER BY Worker__r.Worker_Code__c, SkillCategory__c ASC LIMIT 500';

    for (JIP_Skill__c s : Database.query(query)) {
      skills.add(new SkillWrapper(s, getT()));
    }
  }

  private void loadCertifications() {
    certifications = new List<CertificationWrapper>();

    for (JIP_Certification__c c : [
      SELECT
        Id,
        Name,
        Worker__c,
        Worker__r.Name,
        Worker__r.LastName__c,
        Worker__r.FirstName__c,
        Worker__r.Worker_Code__c,
        Worker__r.Department__r.Name,
        CertificationName__c,
        IssuingOrganization__c,
        IssueDate__c,
        ExpirationDate__c,
        Status__c
      FROM JIP_Certification__c
      WHERE Status__c = 'Active'
      ORDER BY ExpirationDate__c ASC NULLS LAST
      LIMIT 500
    ]) {
      certifications.add(new CertificationWrapper(c, getT()));
    }
  }

  private void loadTrainings() {
    trainings = new List<TrainingWrapper>();

    for (JIP_Training__c t : [
      SELECT
        Id,
        Name,
        TrainingName__c,
        TrainingType__c,
        StartDate__c,
        EndDate__c,
        Location__c,
        Instructor__c,
        MaxParticipants__c,
        CurrentEnrollment__c,
        Status__c
      FROM JIP_Training__c
      WHERE StartDate__c >= :Date.today().addDays(-30)
      ORDER BY StartDate__c ASC
      LIMIT 100
    ]) {
      trainings.add(new TrainingWrapper(t, getT()));
    }
  }

  // ===== Action Methods =====
  public void search() {
    loadSkills();
    loadCertifications();
  }

  public void clearSearch() {
    searchKeyword = '';
    filterDepartment = '';
    filterSkillCategory = '';
    loadSkills();
    loadCertifications();
  }

  public void changeTab() {
    // Tab bound via property
  }

  public void enrollTraining() {
    try {
      Id trainingId = ApexPages.currentPage().getParameters().get('trainingId');
      if (trainingId != null) {
        // Enrollment logic here
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            getT().get('training_enrolled')
          )
        );
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
      );
    }
  }

  public void exportSkillMatrix() {
    ApexPages.addMessage(
      new ApexPages.Message(
        ApexPages.Severity.INFO,
        getT().get('export') + ': ' + getT().get('in_progress')
      )
    );
  }

  public void changeLanguage() {
    loadSkills();
    loadCertifications();
    loadTrainings();
  }

  // ===== Select Options =====
  public List<SelectOption> getSkillCategoryOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', getT().get('all')));
    options.add(new SelectOption('technical', getT().get('tech_skills')));
    options.add(new SelectOption('language', getT().get('language_skills')));
    options.add(
      new SelectOption('management', getT().get('management_skills'))
    );
    options.add(new SelectOption('soft', getT().get('soft_skills')));
    return options;
  }

  public List<SelectOption> getProficiencyOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('beginner', getT().get('beginner')));
    options.add(new SelectOption('intermediate', getT().get('intermediate')));
    options.add(new SelectOption('advanced', getT().get('advanced')));
    options.add(new SelectOption('expert', getT().get('expert')));
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
    options.add(new SelectOption('skills', getT().get('skill_matrix')));
    options.add(
      new SelectOption('certifications', getT().get('certifications'))
    );
    options.add(new SelectOption('trainings', getT().get('training_program')));
    options.add(new SelectOption('career', getT().get('career_path')));
    return options;
  }

  public List<SelectOption> getLanguageOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('ja', '日本語'));
    options.add(new SelectOption('en', 'English'));
    return options;
  }

  // ===== Wrapper Classes =====
  public class SkillWrapper {
    public JIP_Skill__c record { get; set; }
    public String employeeCode { get; set; }
    public String employeeName { get; set; }
    public String departmentName { get; set; }
    public String category { get; set; }
    public String skillName { get; set; }
    public String proficiency { get; set; }
    public String proficiencyClass { get; set; }
    public Decimal yearsExp { get; set; }
    public Date lastUsed { get; set; }

    public SkillWrapper(JIP_Skill__c s, Map<String, String> t) {
      this.record = s;
      this.employeeCode = s.Worker__r != null ? s.Worker__r.Worker_Code__c : '';
      this.category = s.SkillCategory__c;
      this.skillName = s.SkillName__c;
      this.yearsExp = s.YearsOfExperience__c;
      this.lastUsed = s.LastUsed__c;

      if (s.Worker__r != null) {
        if (s.Worker__r.LastName__c != null) {
          this.employeeName = s.Worker__r.LastName__c;
          if (s.Worker__r.FirstName__c != null) {
            this.employeeName += ' ' + s.Worker__r.FirstName__c;
          }
        } else {
          this.employeeName = s.Worker__r.Name;
        }
        this.departmentName = s.Worker__r.Department__r != null
          ? s.Worker__r.Department__r.Name
          : '-';
      }

      // Proficiency with styling (1=beginner, 2=intermediate, 3=advanced, 4=expert)
      if (s.ProficiencyLevel__c >= 4) {
        this.proficiency = t.get('expert');
        this.proficiencyClass = 'slds-badge slds-badge_success';
      } else if (s.ProficiencyLevel__c == 3) {
        this.proficiency = t.get('advanced');
        this.proficiencyClass = 'slds-badge slds-badge_info';
      } else if (s.ProficiencyLevel__c == 2) {
        this.proficiency = t.get('intermediate');
        this.proficiencyClass = 'slds-badge slds-badge_warning';
      } else {
        this.proficiency = t.get('beginner');
        this.proficiencyClass = 'slds-badge';
      }
    }
  }

  public class CertificationWrapper {
    public JIP_Certification__c record { get; set; }
    public String employeeCode { get; set; }
    public String employeeName { get; set; }
    public String departmentName { get; set; }
    public String certName { get; set; }
    public String issuer { get; set; }
    public Date issueDate { get; set; }
    public Date expirationDate { get; set; }
    public String status { get; set; }
    public String statusClass { get; set; }
    public Boolean isExpiringSoon { get; set; }

    public CertificationWrapper(JIP_Certification__c c, Map<String, String> t) {
      this.record = c;
      this.employeeCode = c.Worker__r != null ? c.Worker__r.Worker_Code__c : '';
      this.certName = c.CertificationName__c;
      this.issuer = c.IssuingOrganization__c;
      this.issueDate = c.IssueDate__c;
      this.expirationDate = c.ExpirationDate__c;

      if (c.Worker__r != null) {
        if (c.Worker__r.LastName__c != null) {
          this.employeeName = c.Worker__r.LastName__c;
          if (c.Worker__r.FirstName__c != null) {
            this.employeeName += ' ' + c.Worker__r.FirstName__c;
          }
        } else {
          this.employeeName = c.Worker__r.Name;
        }
        this.departmentName = c.Worker__r.Department__r != null
          ? c.Worker__r.Department__r.Name
          : '-';
      }

      // Check expiration status
      this.isExpiringSoon =
        c.ExpirationDate__c != null &&
        c.ExpirationDate__c <= Date.today().addDays(90) &&
        c.ExpirationDate__c >= Date.today();

      if (c.ExpirationDate__c != null && c.ExpirationDate__c < Date.today()) {
        this.status = t.get('expired');
        this.statusClass = 'slds-badge slds-badge_error';
      } else if (isExpiringSoon) {
        this.status = t.get('cert_expiring');
        this.statusClass = 'slds-badge slds-badge_warning';
      } else {
        this.status = t.get('valid');
        this.statusClass = 'slds-badge slds-badge_success';
      }
    }
  }

  public class TrainingWrapper {
    public JIP_Training__c record { get; set; }
    public String trainingName { get; set; }
    public String trainingType { get; set; }
    public Date startDate { get; set; }
    public Date endDate { get; set; }
    public String location { get; set; }
    public String instructor { get; set; }
    public Integer maxParticipants { get; set; }
    public Integer currentEnrollment { get; set; }
    public String status { get; set; }
    public String statusClass { get; set; }
    public Boolean isAvailable { get; set; }

    public TrainingWrapper(JIP_Training__c t, Map<String, String> traslations) {
      this.record = t;
      this.trainingName = t.TrainingName__c;
      this.trainingType = t.TrainingType__c;
      this.startDate = t.StartDate__c;
      this.endDate = t.EndDate__c;
      this.location = t.Location__c;
      this.instructor = t.Instructor__c;
      this.maxParticipants = t.MaxParticipants__c != null
        ? Integer.valueOf(t.MaxParticipants__c)
        : 0;
      this.currentEnrollment = t.CurrentEnrollment__c != null
        ? Integer.valueOf(t.CurrentEnrollment__c)
        : 0;
      this.isAvailable = this.currentEnrollment < this.maxParticipants;

      if (t.StartDate__c > Date.today()) {
        this.status = traslations.get('scheduled');
        this.statusClass = 'slds-badge slds-badge_info';
      } else if (t.EndDate__c < Date.today()) {
        this.status = traslations.get('completed');
        this.statusClass = 'slds-badge slds-badge_success';
      } else {
        this.status = traslations.get('in_progress');
        this.statusClass = 'slds-badge slds-badge_warning';
      }
    }
  }

  public class CareerPathWrapper {
    public String employeeId { get; set; }
    public String employeeName { get; set; }
    public String currentPosition { get; set; }
    public String targetPosition { get; set; }
    public Date targetDate { get; set; }
    public List<String> requiredSkills { get; set; }
    public List<String> completedSkills { get; set; }
    public Decimal progressPercent { get; set; }
  }
}