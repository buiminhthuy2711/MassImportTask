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
/**
 * @description Controller for Worker Details Page
 * Displays detailed employee information with tabs, org chart, and activities
 */
public with sharing class JIP_WorkerDetailsController {
  // Current worker
  public JIP_Worker__c worker { get; set; }
  public String workerId { get; set; }
  public Boolean isCreateMode { get; set; }

  // Active tab
  public String activeTab { get; set; }
  public Boolean isEditMode { get; set; }
  public String activityView { get; set; }
  public Boolean showMemoComposer { get; set; }
  public String newMemoText { get; set; }
  public Integer activityDisplayLimit { get; set; }
  public Integer activityStepSize { get; set; }
  public Boolean hasMoreActivities { get; set; }
  public transient Blob avatarBody { get; set; }
  public String avatarFileName { get; set; }
  public String avatarCompressedBase64 { get; set; }
  public String avatarCompressedFileName { get; set; }
  public String avatarUrl { get; set; }
  public Boolean hasAvatar { get; set; }

  // Related records
  public List<AttendanceWrapper> recentAttendances { get; set; }
  public List<LeaveWrapper> recentLeaves { get; set; }
  public List<SkillWrapper> skills { get; set; }
  public List<CertificationWrapper> certifications { get; set; }
  public List<TrainingWrapper> trainings { get; set; }
  public List<ActivityWrapper> activities { get; set; }
  public List<TeamMemberWrapper> teamMembers { get; set; }

  // Department Manager info
  public Boolean hasManager { get; set; }
  public Boolean isCurrentWorkerManager { get; set; }
  public String managerName { get; set; }
  public String managerPosition { get; set; }
  public String managerInitials { get; set; }
  public Id managerId { get; set; }
  public String departmentName { get; set; }

  // Stats
  public Decimal totalWorkDays { get; set; }
  public Decimal totalLeaveDays { get; set; }
  public Decimal totalOvertimeHours { get; set; }
  public Integer skillCount { get; set; }
  public Integer certCount { get; set; }
  public Integer trainingCount { get; set; }

  // System Account properties
  public String newAccountType { get; set; }
  public String newAccountRole { get; set; }
  public String newAccountPassword { get; set; }
  public String generatedPassword { get; set; }
  public Boolean showAccountModal { get; set; }
  public List<SelectOption> accountTypeOptions { get; set; }
  public List<SelectOption> accountRoleOptions { get; set; }
  public List<SelectOption> salesforceUserOptions { get; set; }
  public Id selectedSalesforceUserId { get; set; }

  // Constructor
  public JIP_WorkerDetailsController() {
    workerId = ApexPages.currentPage().getParameters().get('id');
    activeTab = ApexPages.currentPage().getParameters().get('tab');
    isEditMode = false;
    isCreateMode = false;
    activityView = 'activity';
    showMemoComposer = false;
    newMemoText = '';
    activityDisplayLimit = 20;
    activityStepSize = 20;
    hasMoreActivities = false;
    hasAvatar = false;
    avatarUrl = null;

    // Initialize system account properties
    showAccountModal = false;
    newAccountType = 'Guest';
    newAccountRole = 'Employee';
    newAccountPassword = '';
    generatedPassword = '';
    initAccountOptions();

    if (String.isBlank(activeTab)) {
      activeTab = 'work';
    }

    // Initialize lists
    recentAttendances = new List<AttendanceWrapper>();
    recentLeaves = new List<LeaveWrapper>();
    skills = new List<SkillWrapper>();
    certifications = new List<CertificationWrapper>();
    trainings = new List<TrainingWrapper>();
    activities = new List<ActivityWrapper>();
    teamMembers = new List<TeamMemberWrapper>();

    if (String.isNotBlank(workerId)) {
      if (workerId == 'new') {
        // Create mode
        isCreateMode = true;
        isEditMode = true;
        worker = new JIP_Worker__c();
      } else {
        // View mode - load existing worker
        loadWorkerDetails();
        loadAvatar();
        loadRelatedData();
        loadActivities();
        calculateStats();
      }
    }
  }

  /**
   * @description Load worker details
   */
  private void loadWorkerDetails() {
    List<JIP_Worker__c> workers = [
      SELECT
        Id,
        Name,
        Worker_Code__c,
        LastName__c,
        FirstName__c,
        LastNameKana__c,
        FirstNameKana__c,
        Email__c,
        Phone__c,
        Department__c,
        Department__r.Name,
        Manager__c,
        Manager__r.LastName__c,
        Manager__r.FirstName__c,
        Manager__r.Position__c,
        User__c,
        User__r.Name,
        Position__c,
        ContractType__c,
        EmploymentStatus__c,
        HireDate__c,
        EndDate__c,
        BirthDate__c,
        Gender__c,
        Address__c,
        PostalCode__c,
        EmergencyContactName__c,
        EmergencyContactPhone__c,
        BankName__c,
        BankBranch__c,
        BankAccountNumber__c,
        BankAccountType__c,
        InsuranceNumber__c,
        MyNumber__c,
        Notes__c,
        SystemLoginType__c,
        SystemUsername__c,
        SystemPassword__c,
        SystemRole__c,
        SystemAccountActive__c,
        SystemAccountCreatedDate__c
      FROM JIP_Worker__c
      WHERE Id = :workerId
      LIMIT 1
    ];

    if (!workers.isEmpty()) {
      worker = workers[0];
      loadManagerInfo();
    }
  }

  private void loadManagerInfo() {
    hasManager = false;
    isCurrentWorkerManager = false;
    managerName = '';
    managerPosition = '';
    managerInitials = '';
    managerId = null;
    departmentName = worker.Department__r != null
      ? worker.Department__r.Name
      : '';

    // Check if current worker has a manager (Manager__c on Worker__c)
    if (worker.Manager__c != null) {
      hasManager = true;
      managerId = worker.Manager__c;
      String mln = worker.Manager__r.LastName__c != null
        ? worker.Manager__r.LastName__c
        : '';
      String mfn = worker.Manager__r.FirstName__c != null
        ? worker.Manager__r.FirstName__c
        : '';
      managerName = mln + ' ' + mfn;
      managerPosition = worker.Manager__r.Position__c;
      managerInitials =
        (mln.length() > 0 ? mln.substring(0, 1) : '') +
        (mfn.length() > 0 ? mfn.substring(0, 1) : '');
    }
  }

  private void loadAvatar() {
    hasAvatar = false;
    avatarUrl = null;

    if (String.isBlank(workerId)) {
      return;
    }

    List<ContentDocumentLink> avatarLinks = [
      SELECT
        ContentDocument.LatestPublishedVersionId,
        ContentDocument.FileType,
        ContentDocument.LastModifiedDate
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :workerId
      ORDER BY ContentDocument.LastModifiedDate DESC
      LIMIT 30
    ];

    Set<String> imageTypes = new Set<String>{
      'PNG',
      'JPG',
      'JPEG',
      'GIF',
      'WEBP'
    };
    for (ContentDocumentLink link : avatarLinks) {
      String fileType = link.ContentDocument.FileType != null
        ? link.ContentDocument.FileType.toUpperCase()
        : '';
      if (
        imageTypes.contains(fileType) &&
        link.ContentDocument.LatestPublishedVersionId != null
      ) {
        hasAvatar = true;
        avatarUrl =
          '/sfc/servlet.shepherd/version/download/' +
          link.ContentDocument.LatestPublishedVersionId;
        break;
      }
    }
  }

  /**
   * @description Load related data based on active tab
   */
  private void loadRelatedData() {
    // Load team members (direct reports - workers whose Manager__c = current worker)
    for (JIP_Worker__c member : [
      SELECT Id, Name, LastName__c, FirstName__c, Position__c
      FROM JIP_Worker__c
      WHERE Manager__c = :workerId AND EmploymentStatus__c = '在職'
      ORDER BY Name
      LIMIT 10
    ]) {
      teamMembers.add(new TeamMemberWrapper(member));
    }

    // Load skills
    for (JIP_Skill__c skill : [
      SELECT
        Id,
        Name,
        SkillName__c,
        Category__c,
        ProficiencyLevel__c,
        YearsOfExperience__c
      FROM JIP_Skill__c
      WHERE Worker__c = :workerId
      ORDER BY ProficiencyLevel__c DESC
      LIMIT 10
    ]) {
      skills.add(new SkillWrapper(skill));
    }

    // Load certifications
    for (JIP_Certification__c cert : [
      SELECT
        Id,
        Name,
        CertificationName__c,
        IssuingOrganization__c,
        IssueDate__c,
        ExpirationDate__c,
        Status__c
      FROM JIP_Certification__c
      WHERE Worker__c = :workerId
      ORDER BY IssueDate__c DESC
      LIMIT 10
    ]) {
      certifications.add(new CertificationWrapper(cert));
    }

    // Load recent attendances
    for (JIP_Attendance__c att : [
      SELECT
        Id,
        Name,
        AttendanceDate__c,
        CheckInTime__c,
        CheckOutTime__c,
        WorkingHours__c,
        Status__c,
        OvertimeHours__c
      FROM JIP_Attendance__c
      WHERE Worker__c = :workerId
      ORDER BY AttendanceDate__c DESC
      LIMIT 10
    ]) {
      recentAttendances.add(new AttendanceWrapper(att));
    }
  }

  /**
   * @description Load activities for the worker
   */
  private void loadActivities() {
    activities = new List<ActivityWrapper>();
    hasMoreActivities = false;
    Integer queryLimit = activityDisplayLimit + 1;
    Boolean sourceHasMore = false;

    if (activityView == 'message') {
      sourceHasMore = loadEmailFeed(queryLimit);
    } else {
      Boolean hasMoreProject = loadProjectActivityFeed(queryLimit);
      Boolean hasMoreMemo = loadMemoFeed(queryLimit);
      sourceHasMore = hasMoreProject || hasMoreMemo;
    }

    activities.sort();
    trimActivities(sourceHasMore);
    markDateHeaders();
  }

  private Boolean loadProjectActivityFeed(Integer queryLimit) {
    Id currentWorkerId = getCurrentUserWorkerId();
    Set<Id> projectIds = new Set<Id>();
    for (JIP_ProjectMember__c member : [
      SELECT Project__c
      FROM JIP_ProjectMember__c
      WHERE Worker__c = :workerId AND Project__c != NULL
      LIMIT 200
    ]) {
      projectIds.add(member.Project__c);
    }

    if (projectIds.isEmpty()) {
      return false;
    }

    if (currentWorkerId == null) {
      return false;
    }

    List<JIP_ProjectActivity__c> projectActivities = [
      SELECT
        Id,
        ActivityType__c,
        Action__c,
        ActorName__c,
        ActorWorker__c,
        ActorWorker__r.LastName__c,
        ActorWorker__r.FirstName__c,
        Description__c,
        RelatedRecordName__c,
        CreatedDate
      FROM JIP_ProjectActivity__c
      WHERE Project__c IN :projectIds AND ActorWorker__c = :currentWorkerId
      ORDER BY CreatedDate DESC
      LIMIT :queryLimit
    ];

    for (JIP_ProjectActivity__c rec : projectActivities) {
      String body = String.isNotBlank(rec.Description__c)
        ? rec.Description__c
        : rec.Action__c;
      String meta = String.isNotBlank(rec.ActivityType__c)
        ? rec.ActivityType__c
        : '活動';
      if (String.isNotBlank(rec.RelatedRecordName__c)) {
        meta += ' - ' + rec.RelatedRecordName__c;
      }

      activities.add(
        new ActivityWrapper(
          'activity',
          body,
          rec.CreatedDate,
          getActivityActorDisplayName(rec),
          meta
        )
      );
    }

    return projectActivities.size() == queryLimit;
  }

  private Boolean loadMemoFeed(Integer queryLimit) {
    Id currentUserId = UserInfo.getUserId();
    List<Note> memos = [
      SELECT Id, Title, Body, CreatedDate, CreatedBy.Name
      FROM Note
      WHERE ParentId = :workerId AND CreatedById = :currentUserId
      ORDER BY CreatedDate DESC
      LIMIT :queryLimit
    ];

    for (Note memo : memos) {
      activities.add(
        new ActivityWrapper(
          'memo',
          String.isNotBlank(memo.Body) ? memo.Body : '(メモ本文なし)',
          memo.CreatedDate,
          memo.CreatedBy != null ? memo.CreatedBy.Name : 'System',
          String.isNotBlank(memo.Title) ? memo.Title : 'メモ'
        )
      );
    }

    return memos.size() == queryLimit;
  }

  private Boolean loadEmailFeed(Integer queryLimit) {
    if (worker == null) {
      return false;
    }

    try {
      Id currentUserId = UserInfo.getUserId();
      String mailPattern =
        '%' +
        (String.isNotBlank(worker.Email__c) ? worker.Email__c : '') +
        '%';
      String currentUserEmail = UserInfo.getUserEmail();
      List<EmailMessage> emails;

      if (String.isNotBlank(currentUserEmail)) {
        String currentUserEmailPattern = '%' + currentUserEmail + '%';
        emails = [
          SELECT
            Id,
            Subject,
            TextBody,
            FromAddress,
            ToAddress,
            MessageDate,
            CreatedBy.Name
          FROM EmailMessage
          WHERE
            (RelatedToId = :workerId
            OR ToAddress LIKE :mailPattern
            OR FromAddress LIKE :mailPattern)
            AND (CreatedById = :currentUserId
            OR FromAddress LIKE :currentUserEmailPattern)
          ORDER BY MessageDate DESC
          LIMIT :queryLimit
        ];
      } else {
        emails = [
          SELECT
            Id,
            Subject,
            TextBody,
            FromAddress,
            ToAddress,
            MessageDate,
            CreatedBy.Name
          FROM EmailMessage
          WHERE
            (RelatedToId = :workerId
            OR ToAddress LIKE :mailPattern
            OR FromAddress LIKE :mailPattern)
            AND CreatedById = :currentUserId
          ORDER BY MessageDate DESC
          LIMIT :queryLimit
        ];
      }

      for (EmailMessage email : emails) {
        Datetime displayDate = email.MessageDate != null
          ? email.MessageDate
          : System.now();
        String body = String.isNotBlank(email.TextBody)
          ? email.TextBody
          : '(本文なし)';
        String author = String.isNotBlank(email.FromAddress)
          ? email.FromAddress
          : (email.CreatedBy != null ? email.CreatedBy.Name : 'System');

        activities.add(
          new ActivityWrapper(
            'message',
            body,
            displayDate,
            author,
            String.isNotBlank(email.Subject) ? email.Subject : 'メール'
          )
        );
      }
      return emails.size() == queryLimit;
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.WARNING,
          'メール履歴を取得できませんでした。'
        )
      );
      return false;
    }
  }

  private Id getCurrentUserWorkerId() {
    List<JIP_Worker__c> workers = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE User__c = :UserInfo.getUserId()
      LIMIT 1
    ];

    return workers.isEmpty() ? null : workers[0].Id;
  }

  private String getActivityActorDisplayName(JIP_ProjectActivity__c activity) {
    if (activity != null && activity.ActorWorker__r != null) {
      List<String> nameParts = new List<String>();
      if (String.isNotBlank(activity.ActorWorker__r.LastName__c)) {
        nameParts.add(activity.ActorWorker__r.LastName__c);
      }
      if (String.isNotBlank(activity.ActorWorker__r.FirstName__c)) {
        nameParts.add(activity.ActorWorker__r.FirstName__c);
      }

      if (!nameParts.isEmpty()) {
        return String.join(nameParts, ' ');
      }
    }

    if (activity != null && String.isNotBlank(activity.ActorName__c)) {
      return activity.ActorName__c;
    }

    return 'System';
  }

  private void trimActivities(Boolean sourceHasMore) {
    if (activities.size() > activityDisplayLimit) {
      List<ActivityWrapper> limitedActivities = new List<ActivityWrapper>();
      for (Integer i = 0; i < activityDisplayLimit; i++) {
        limitedActivities.add(activities[i]);
      }
      activities = limitedActivities;
      hasMoreActivities = true;
      return;
    }

    hasMoreActivities = sourceHasMore;
  }

  private void markDateHeaders() {
    Date prevDate;
    for (Integer i = 0; i < activities.size(); i++) {
      if (activities[i].activityDateTime != null) {
        Date currentDate = activities[i].activityDateTime.date();
        activities[i].showDateHeader = (prevDate == null ||
        currentDate != prevDate);
        prevDate = currentDate;
      } else {
        activities[i].showDateHeader = false;
      }
    }
  }

  public PageReference showMessageFeed() {
    activityView = 'message';
    showMemoComposer = false;
    activityDisplayLimit = activityStepSize;
    loadActivities();
    return null;
  }

  public PageReference showMemoFeed() {
    activityView = 'memo';
    showMemoComposer = true;
    activityDisplayLimit = activityStepSize;
    loadActivities();
    return null;
  }

  public PageReference showActivityFeed() {
    activityView = 'activity';
    showMemoComposer = false;
    activityDisplayLimit = activityStepSize;
    loadActivities();
    return null;
  }

  public PageReference loadMoreActivities() {
    activityDisplayLimit += activityStepSize;
    loadActivities();
    return null;
  }

  public PageReference uploadAvatar() {
    if (
      String.isNotBlank(avatarCompressedBase64) &&
      String.isNotBlank(avatarCompressedFileName)
    ) {
      String rawBase64 = avatarCompressedBase64;
      Integer commaIndex = rawBase64.indexOf(',');
      if (commaIndex >= 0) {
        rawBase64 = rawBase64.substring(commaIndex + 1);
      }

      avatarBody = EncodingUtil.base64Decode(rawBase64);
      avatarFileName = avatarCompressedFileName;
    }

    if (avatarBody == null || String.isBlank(avatarFileName)) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.WARNING,
          'アップロードする画像を選択してください。'
        )
      );
      return null;
    }

    String lowerFileName = avatarFileName.toLowerCase();
    if (
      !(lowerFileName.endsWith('.jpg') ||
      lowerFileName.endsWith('.jpeg') ||
      lowerFileName.endsWith('.png') ||
      lowerFileName.endsWith('.gif') ||
      lowerFileName.endsWith('.webp'))
    ) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '画像ファイル（jpg, jpeg, png, gif, webp）のみアップロードできます。'
        )
      );
      return null;
    }

    try {
      ContentVersion version = new ContentVersion();
      version.Title =
        'Worker Avatar - ' +
        workerId +
        ' - ' +
        String.valueOf(System.now().getTime());
      version.PathOnClient = avatarFileName;
      version.VersionData = avatarBody;
      version.IsMajorVersion = true;
      version.FirstPublishLocationId = workerId;
      insert version;

      avatarBody = null;
      avatarFileName = null;
      avatarCompressedBase64 = null;
      avatarCompressedFileName = null;
      loadAvatar();
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          'アバター画像をアップロードしました。'
        )
      );
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'アップロードに失敗しました: ' + ex.getMessage()
        )
      );
    }
    return null;
  }

  public PageReference cancelMemoComposer() {
    showMemoComposer = false;
    newMemoText = '';
    return null;
  }

  public PageReference saveMemo() {
    if (String.isBlank(newMemoText)) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.WARNING,
          'メモ内容を入力してください。'
        )
      );
      return null;
    }

    try {
      insert new Note(
        ParentId = workerId,
        Title = 'Worker Memo',
        Body = newMemoText
      );
      newMemoText = '';
      activityView = 'activity';
      showMemoComposer = false;
      activityDisplayLimit = activityStepSize;
      loadActivities();
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          'メモを記録しました。'
        )
      );
    } catch (DmlException ex) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDmlMessage(0))
      );
    }
    return null;
  }

  public String getMessageBtnClass() {
    return activityView == 'message'
      ? 'btn btn-purple btn-sm'
      : 'btn btn-outline btn-sm';
  }

  public String getMemoBtnClass() {
    return showMemoComposer
      ? 'btn btn-purple btn-sm'
      : 'btn btn-outline btn-sm';
  }

  public String getActivityBtnClass() {
    return activityView == 'activity'
      ? 'btn btn-purple btn-sm'
      : 'btn btn-outline btn-sm';
  }

  /**
   * @description Calculate statistics
   */
  private void calculateStats() {
    // Initialize
    totalWorkDays = 0;
    totalOvertimeHours = 0;
    totalLeaveDays = 0;

    // Count work days this month
    Date firstDayOfMonth = Date.today().toStartOfMonth();
    Date lastDayOfMonth = firstDayOfMonth.addMonths(1).addDays(-1);

    AggregateResult[] workResult = [
      SELECT
        COUNT(Id) cnt,
        SUM(WorkingHours__c) hours,
        SUM(OvertimeHours__c) overtime
      FROM JIP_Attendance__c
      WHERE
        Worker__c = :workerId
        AND AttendanceDate__c >= :firstDayOfMonth
        AND AttendanceDate__c <= :lastDayOfMonth
    ];

    if (!workResult.isEmpty()) {
      totalWorkDays = workResult[0].get('cnt') != null
        ? (Decimal) workResult[0].get('cnt')
        : 0;
      totalOvertimeHours = workResult[0].get('overtime') != null
        ? (Decimal) workResult[0].get('overtime')
        : 0;
    }

    // Count skills and certifications
    skillCount = [SELECT COUNT() FROM JIP_Skill__c WHERE Worker__c = :workerId];
    certCount = [
      SELECT COUNT()
      FROM JIP_Certification__c
      WHERE Worker__c = :workerId
    ];
    trainingCount = 0;
  }

  /**
   * @description Change active tab
   */
  public PageReference changeTab() {
    activeTab = ApexPages.currentPage().getParameters().get('tab');
    return null;
  }

  /**
   * @description Navigate back to list
   */
  public PageReference goBack() {
    return new PageReference('/apex/JIP_WorkerManagementPage');
  }

  /**
   * @description Switch to inline edit mode
   */
  public PageReference editWorker() {
    isEditMode = true;
    return null;
  }

  /**
   * @description Save worker changes on details page
   */
  public PageReference saveWorker() {
    if (worker == null) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '保存対象の従業員が見つかりません。'
        )
      );
      return null;
    }

    try {
      if (isCreateMode) {
        // Create new worker
        insert worker;
        workerId = worker.Id;
        isCreateMode = false;
        isEditMode = false;
        PageReference pr = new PageReference(
          '/apex/JIP_WorkerDetailsPage?id=' + workerId
        );
        pr.setRedirect(true);
        return pr;
      } else {
        // Update existing worker
        update worker;
        loadWorkerDetails();
        isEditMode = false;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            '従業員情報を保存しました。'
          )
        );
      }
    } catch (DmlException ex) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDmlMessage(0))
      );
    }
    return null;
  }

  /**
   * @description Cancel edit mode and reload latest data
   */
  public PageReference cancelEdit() {
    if (isCreateMode) {
      // Redirect back to management page if creating new worker
      PageReference pr = new PageReference('/apex/JIP_WorkerManagementPage');
      pr.setRedirect(true);
      return pr;
    }
    loadWorkerDetails();
    isEditMode = false;
    return null;
  }

  // ============ Wrapper Classes ============

  public class AttendanceWrapper {
    public Id recordId { get; set; }
    public Date attendanceDate { get; set; }
    public String checkInTime { get; set; }
    public String checkOutTime { get; set; }
    public Decimal workHours { get; set; }
    public Decimal overtimeHours { get; set; }
    public String status { get; set; }

    public AttendanceWrapper(JIP_Attendance__c att) {
      this.recordId = att.Id;
      this.attendanceDate = att.AttendanceDate__c;
      this.checkInTime = att.CheckInTime__c != null
        ? String.valueOf(att.CheckInTime__c).substring(0, 5)
        : '';
      this.checkOutTime = att.CheckOutTime__c != null
        ? String.valueOf(att.CheckOutTime__c).substring(0, 5)
        : '';
      this.workHours = att.WorkingHours__c;
      this.overtimeHours = att.OvertimeHours__c;
      this.status = att.Status__c;
    }
  }

  public class LeaveWrapper {
    public Id recordId { get; set; }
    public String requestType { get; set; }
    public Date startDate { get; set; }
    public Date endDate { get; set; }
    public String status { get; set; }

    public LeaveWrapper() {
      // Empty constructor
    }
  }

  public class SkillWrapper {
    public Id recordId { get; set; }
    public String skillName { get; set; }
    public String category { get; set; }
    public Decimal proficiencyLevel { get; set; }
    public String proficiencyLabel { get; set; }
    public Decimal yearsOfExperience { get; set; }

    public SkillWrapper(JIP_Skill__c skill) {
      this.recordId = skill.Id;
      this.skillName = skill.SkillName__c;
      this.category = skill.Category__c;
      this.proficiencyLevel = skill.ProficiencyLevel__c;
      this.yearsOfExperience = skill.YearsOfExperience__c;

      // Convert numeric level to label
      if (skill.ProficiencyLevel__c >= 4) {
        this.proficiencyLabel = 'エキスパート';
      } else if (skill.ProficiencyLevel__c >= 3) {
        this.proficiencyLabel = '上級';
      } else if (skill.ProficiencyLevel__c >= 2) {
        this.proficiencyLabel = '中級';
      } else {
        this.proficiencyLabel = '初級';
      }
    }
  }

  public class CertificationWrapper {
    public Id recordId { get; set; }
    public String certName { get; set; }
    public String issuingOrg { get; set; }
    public Date issueDate { get; set; }
    public Date expirationDate { get; set; }
    public String status { get; set; }
    public Boolean isExpiringSoon { get; set; }

    public CertificationWrapper(JIP_Certification__c cert) {
      this.recordId = cert.Id;
      this.certName = cert.CertificationName__c;
      this.issuingOrg = cert.IssuingOrganization__c;
      this.issueDate = cert.IssueDate__c;
      this.expirationDate = cert.ExpirationDate__c;
      this.status = cert.Status__c;
      this.isExpiringSoon =
        cert.ExpirationDate__c != null &&
        cert.ExpirationDate__c <= Date.today().addDays(90) &&
        cert.ExpirationDate__c > Date.today();
    }
  }

  public class TrainingWrapper {
    public Id recordId { get; set; }
    public String trainingName { get; set; }
    public String trainingType { get; set; }
    public Date startDate { get; set; }
    public Date endDate { get; set; }
    public String status { get; set; }

    public TrainingWrapper(JIP_Training__c tr) {
      this.recordId = tr.Id;
      this.trainingName = tr.TrainingName__c;
      this.trainingType = tr.TrainingType__c;
      this.startDate = tr.StartDate__c;
      this.endDate = tr.EndDate__c;
      this.status = tr.Status__c;
    }
  }

  public class TeamMemberWrapper {
    public Id recordId { get; set; }
    public String fullName { get; set; }
    public String position { get; set; }
    public String initials { get; set; }

    public TeamMemberWrapper(JIP_Worker__c member) {
      this.recordId = member.Id;
      this.fullName =
        (member.LastName__c != null ? member.LastName__c : '') +
        ' ' +
        (member.FirstName__c != null ? member.FirstName__c : '');
      this.position = member.Position__c;

      String ln = member.LastName__c != null ? member.LastName__c : '';
      String fn = member.FirstName__c != null ? member.FirstName__c : '';
      this.initials =
        (ln.length() > 0 ? ln.substring(0, 1) : '') +
        (fn.length() > 0 ? fn.substring(0, 1) : '');
    }
  }

  public class ActivityWrapper implements Comparable {
    public String activityType { get; set; }
    public String message { get; set; }
    public Datetime activityDateTime { get; set; }
    public String author { get; set; }
    public String formattedDate { get; set; }
    public String formattedTime { get; set; }
    public Boolean showDateHeader { get; set; }
    public String subLabel { get; set; }

    public ActivityWrapper(
      String actType,
      String msg,
      Datetime actDateTime,
      String auth,
      String metaLabel
    ) {
      this.activityType = actType;
      this.message = msg;
      this.activityDateTime = actDateTime;
      this.author = auth;
      this.showDateHeader = false;
      this.subLabel = metaLabel;

      if (actDateTime != null) {
        Date onlyDate = actDateTime.date();
        this.formattedDate =
          onlyDate.year() +
          '年' +
          onlyDate.month() +
          '月' +
          onlyDate.day() +
          '日';
        this.formattedTime = actDateTime.format('H:mm');
      }
    }

    public Integer compareTo(Object compareTo) {
      ActivityWrapper other = (ActivityWrapper) compareTo;
      if (this.activityDateTime == null)
        return 1;
      if (other.activityDateTime == null)
        return -1;
      if (this.activityDateTime > other.activityDateTime)
        return -1;
      if (this.activityDateTime < other.activityDateTime)
        return 1;
      return 0;
    }
  }

  /**
   * @description Get full name
   */
  public String getWorkerFullName() {
    if (worker == null)
      return '';
    return (worker.LastName__c != null ? worker.LastName__c : '') +
      ' ' +
      (worker.FirstName__c != null ? worker.FirstName__c : '');
  }

  /**
   * @description Get initials for avatar
   */
  public String getWorkerInitials() {
    if (worker == null)
      return '';
    String ln = worker.LastName__c != null ? worker.LastName__c : '';
    String fn = worker.FirstName__c != null ? worker.FirstName__c : '';
    return (ln.length() > 0 ? ln.substring(0, 1) : '') +
      (fn.length() > 0 ? fn.substring(0, 1) : '');
  }

  /**
   * @description Get status badge class
   */
  public String getStatusBadgeClass() {
    if (worker == null || worker.EmploymentStatus__c == null)
      return 'badge-default';
    if (worker.EmploymentStatus__c == '在職')
      return 'badge-active';
    if (worker.EmploymentStatus__c == '休職中')
      return 'badge-leave';
    if (worker.EmploymentStatus__c == '退職済')
      return 'badge-resigned';
    return 'badge-default';
  }

  /**
   * @description Get formatted work address
   */
  public String getFormattedAddress() {
    if (worker == null)
      return '';
    List<String> parts = new List<String>();
    if (String.isNotBlank(worker.PostalCode__c))
      parts.add(worker.PostalCode__c);
    if (String.isNotBlank(worker.Address__c))
      parts.add(worker.Address__c);
    return String.join(parts, '\n');
  }

  // ============ System Account Methods ============

  /**
   * @description Initialize account options
   */
  private void initAccountOptions() {
    // Account type options
    accountTypeOptions = new List<SelectOption>{
      new SelectOption('Guest', 'ゲストアカウント（独立）'),
      new SelectOption('SalesforceUser', 'Salesforceユーザー連携')
    };

    // Role options
    accountRoleOptions = new List<SelectOption>{
      new SelectOption('Admin', '管理者'),
      new SelectOption('Manager', 'マネージャー'),
      new SelectOption('Employee', '一般社員'),
      new SelectOption('ReadOnly', '閲覧のみ')
    };

    // Load available Salesforce users (not linked to other workers)
    loadSalesforceUserOptions();
  }

  /**
   * @description Load Salesforce users not linked to workers
   */
  private void loadSalesforceUserOptions() {
    salesforceUserOptions = new List<SelectOption>();
    salesforceUserOptions.add(new SelectOption('', '-- ユーザーを選択 --'));

    // Get users already linked to workers
    Set<Id> linkedUserIds = new Set<Id>();
    for (JIP_Worker__c w : [
      SELECT User__c
      FROM JIP_Worker__c
      WHERE User__c != NULL AND Id != :workerId
    ]) {
      linkedUserIds.add(w.User__c);
    }

    // Get active users not already linked
    for (User u : [
      SELECT Id, Name, Email, Username
      FROM User
      WHERE IsActive = TRUE AND Id NOT IN :linkedUserIds
      ORDER BY Name
      LIMIT 200
    ]) {
      salesforceUserOptions.add(
        new SelectOption(u.Id, u.Name + ' (' + u.Email + ')')
      );
    }
  }

  /**
   * @description Check if worker has system account
   */
  public Boolean getHasSystemAccount() {
    return worker != null && String.isNotBlank(worker.SystemLoginType__c);
  }

  /**
   * @description Get system role label
   */
  public String getSystemRoleLabel() {
    if (worker == null || String.isBlank(worker.SystemRole__c)) {
      return '';
    }
    Map<String, String> roleLabels = new Map<String, String>{
      'Admin' => '管理者',
      'Manager' => 'マネージャー',
      'Employee' => '一般社員',
      'ReadOnly' => '閲覧のみ'
    };
    return roleLabels.containsKey(worker.SystemRole__c)
      ? roleLabels.get(worker.SystemRole__c)
      : worker.SystemRole__c;
  }

  /**
   * @description Get linked Salesforce user name
   */
  public String getLinkedUserName() {
    if (worker == null || worker.User__c == null) {
      return '';
    }
    return worker.User__r != null ? worker.User__r.Name : '';
  }

  /**
   * @description Open account modal
   */
  public PageReference openAccountModal() {
    showAccountModal = true;
    newAccountType = 'Guest';
    newAccountRole = 'Employee';
    newAccountPassword = '';
    generatedPassword = generateRandomPassword();
    loadSalesforceUserOptions();
    return null;
  }

  /**
   * @description Close account modal
   */
  public PageReference closeAccountModal() {
    showAccountModal = false;
    return null;
  }

  /**
   * @description Generate random password
   */
  private String generateRandomPassword() {
    String chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#$%';
    String password = '';
    for (Integer i = 0; i < 12; i++) {
      Integer idx = Math.mod(
        Math.abs(Crypto.getRandomInteger()),
        chars.length()
      );
      password += chars.substring(idx, idx + 1);
    }
    return password;
  }

  /**
   * @description Create system account
   */
  public PageReference createSystemAccount() {
    if (worker == null) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          '従業員が見つかりません。'
        )
      );
      return null;
    }

    try {
      // Set account type
      worker.SystemLoginType__c = newAccountType;
      worker.SystemRole__c = newAccountRole;
      worker.SystemAccountActive__c = true;
      worker.SystemAccountCreatedDate__c = Datetime.now();

      if (newAccountType == 'Guest') {
        // Create guest account with email as username
        if (String.isBlank(worker.Email__c)) {
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'ゲストアカウントを作成するには、メールアドレスが必要です。'
            )
          );
          return null;
        }
        worker.SystemUsername__c = worker.Email__c;

        // Hash password
        String passwordToUse = String.isNotBlank(newAccountPassword)
          ? newAccountPassword
          : generatedPassword;
        worker.SystemPassword__c = hashPassword(passwordToUse);
        worker.User__c = null;

        update worker;

        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            'ゲストアカウントを作成しました。ログインID: ' +
              worker.SystemUsername__c +
              ', パスワード: ' +
              passwordToUse
          )
        );
      } else if (newAccountType == 'SalesforceUser') {
        // Link to Salesforce user
        if (selectedSalesforceUserId == null) {
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Salesforceユーザーを選択してください。'
            )
          );
          return null;
        }

        // Get user info
        User selectedUser = [
          SELECT Id, Email, Username, Name
          FROM User
          WHERE Id = :selectedSalesforceUserId
          LIMIT 1
        ];

        worker.User__c = selectedSalesforceUserId;
        worker.SystemUsername__c = selectedUser.Email;
        worker.SystemPassword__c = null; // No password for SF users

        update worker;

        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            'Salesforceユーザー「' + selectedUser.Name + '」と連携しました。'
          )
        );
      }

      showAccountModal = false;
      loadWorkerDetails();
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())
      );
    }

    return null;
  }

  /**
   * @description Hash password using SHA-256
   */
  private String hashPassword(String password) {
    Blob hashBlob = Crypto.generateDigest('SHA-256', Blob.valueOf(password));
    return EncodingUtil.convertToHex(hashBlob);
  }

  /**
   * @description Reset account password
   */
  public PageReference resetAccountPassword() {
    if (worker == null || worker.SystemLoginType__c != 'Guest') {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'パスワードリセットはゲストアカウントのみ可能です。'
        )
      );
      return null;
    }

    try {
      String newPassword = generateRandomPassword();
      worker.SystemPassword__c = hashPassword(newPassword);
      update worker;

      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          'パスワードをリセットしました。新しいパスワード: ' + newPassword
        )
      );
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())
      );
    }

    return null;
  }

  /**
   * @description Toggle account active status
   */
  public PageReference toggleAccountStatus() {
    if (worker == null || String.isBlank(worker.SystemLoginType__c)) {
      return null;
    }

    try {
      worker.SystemAccountActive__c = !worker.SystemAccountActive__c;
      update worker;

      String statusMsg = worker.SystemAccountActive__c ? '有効化' : '無効化';
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          'アカウントを' + statusMsg + 'しました。'
        )
      );
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())
      );
    }

    return null;
  }

  /**
   * @description Delete system account
   */
  public PageReference deleteSystemAccount() {
    if (worker == null) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, 'Worker not found.')
      );
      return null;
    }

    try {
      // Save login type before clearing
      String loginType = worker.SystemLoginType__c;

      // Clear all system account fields
      worker.SystemLoginType__c = null;
      worker.SystemUsername__c = null;
      worker.SystemPassword__c = null;
      worker.SystemRole__c = null;
      worker.SystemAccountActive__c = false;
      worker.SystemAccountCreatedDate__c = null;

      // Clear Salesforce user link if applicable
      if (loginType == 'SalesforceUser') {
        worker.User__c = null;
      }

      update worker;

      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          'システムアカウントを削除しました。'
        )
      );

      // Reload worker to refresh all fields
      loadWorkerDetails();
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'アカウント削除エラー: ' + ex.getMessage()
        )
      );
    }

    return null;
  }

  /**
   * @description Regenerate password for display
   */
  public PageReference regeneratePassword() {
    generatedPassword = generateRandomPassword();
    return null;
  }
}