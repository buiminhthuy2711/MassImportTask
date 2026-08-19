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
public with sharing class JIP_HRWorkflowController {
  // ===== Properties =====
  public String language { get; set; }
  public String searchKeyword { get; set; }
  public String filterStatus { get; set; }
  public String filterType { get; set; }
  public String selectedTab { get; set; }

  // Data lists
  public List<RequestWrapper> myRequests { get; set; }
  public List<RequestWrapper> pendingApprovals { get; set; }
  public List<RequestWrapper> allRequests { get; set; }

  // Modal control
  public Boolean showModal { get; set; }
  public String currentRequestType { get; set; }
  public JIP_Request__c currentRequest { get; set; }

  // Statistics
  public Integer myPendingCount { get; set; }
  public Integer approvalPendingCount { get; set; }
  public Integer approvedThisMonth { get; set; }
  public Integer rejectedThisMonth { get; set; }

  // Query parameters (class-level for bind variable access)
  private String safeKeyword { get; set; }

  // ===== Constructor =====
  public JIP_HRWorkflowController() {
    language = 'ja';
    searchKeyword = '';
    filterStatus = '';
    filterType = '';
    selectedTab = 'my_requests';
    showModal = false;
    currentRequest = new JIP_Request__c();

    loadStatistics();
    loadMyRequests();
    loadPendingApprovals();
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
    Id currentUserId = UserInfo.getUserId();
    Date startOfMonth = Date.today().toStartOfMonth();

    myPendingCount = [
      SELECT COUNT()
      FROM JIP_Request__c
      WHERE Applicant__c = :currentUserId AND Status__c = 'Pending'
    ];

    approvalPendingCount = [
      SELECT COUNT()
      FROM JIP_Request__c
      WHERE Approver__c = :currentUserId AND Status__c = 'Pending'
    ];

    approvedThisMonth = [
      SELECT COUNT()
      FROM JIP_Request__c
      WHERE ApprovedDate__c >= :startOfMonth AND Status__c = 'Approved'
    ];

    rejectedThisMonth = [
      SELECT COUNT()
      FROM JIP_Request__c
      WHERE ApprovedDate__c >= :startOfMonth AND Status__c = 'Rejected'
    ];
  }

  private void loadMyRequests() {
    myRequests = new List<RequestWrapper>();
    Id currentUserId = UserInfo.getUserId();

    String query = buildRequestQuery() + ' AND Applicant__c = :currentUserId';
    query += ' ORDER BY CreatedDate DESC LIMIT 200';

    for (JIP_Request__c r : Database.query(query)) {
      myRequests.add(new RequestWrapper(r, getT()));
    }
  }

  private void loadPendingApprovals() {
    pendingApprovals = new List<RequestWrapper>();
    Id currentUserId = UserInfo.getUserId();

    for (JIP_Request__c r : [
      SELECT
        Id,
        Name,
        RequestType__c,
        Applicant__c,
        Applicant__r.Name,
        Applicant__r.LastName,
        Applicant__r.FirstName,
        Applicant__r.Department,
        RequestDate__c,
        StartDate__c,
        EndDate__c,
        Status__c,
        Comment__c,
        Approver__c,
        Approver__r.Name,
        ApprovedDate__c,
        ApproverComment__c
      FROM JIP_Request__c
      WHERE Approver__c = :currentUserId AND Status__c = 'Pending'
      ORDER BY RequestDate__c ASC
      LIMIT 100
    ]) {
      pendingApprovals.add(new RequestWrapper(r, getT()));
    }
  }

  private void loadAllRequests() {
    allRequests = new List<RequestWrapper>();

    String query = buildRequestQuery();
    query += ' ORDER BY CreatedDate DESC LIMIT 500';

    for (JIP_Request__c r : Database.query(query)) {
      allRequests.add(new RequestWrapper(r, getT()));
    }
  }

  private String buildRequestQuery() {
    String query =
      'SELECT Id, Name, RequestType__c, Applicant__c, Applicant__r.Name, ' +
      'Applicant__r.LastName, Applicant__r.FirstName, Applicant__r.Department, ' +
      'RequestDate__c, StartDate__c, EndDate__c, ' +
      'Status__c, Comment__c, Approver__c, Approver__r.Name, ApprovedDate__c, ApproverComment__c ' +
      'FROM JIP_Request__c WHERE Id != null';

    if (String.isNotBlank(filterStatus)) {
      query += ' AND Status__c = :filterStatus';
    }

    if (String.isNotBlank(filterType)) {
      query += ' AND RequestType__c = :filterType';
    }

    if (String.isNotBlank(searchKeyword)) {
      safeKeyword =
        '%' +
        String.escapeSingleQuotes(searchKeyword.trim()) +
        '%';
      query += ' AND (Name LIKE :safeKeyword OR Applicant__r.Name LIKE :safeKeyword)';
    }

    return query;
  }

  // ===== Action Methods =====
  public void search() {
    loadMyRequests();
    loadPendingApprovals();
    if (selectedTab == 'all_requests') {
      loadAllRequests();
    }
  }

  public void clearSearch() {
    searchKeyword = '';
    filterStatus = '';
    filterType = '';
    loadMyRequests();
    loadPendingApprovals();
  }

  public void changeTab() {
    if (selectedTab == 'all_requests') {
      loadAllRequests();
    }
  }

  public void openNewRequest() {
    currentRequest = new JIP_Request__c();
    currentRequest.Applicant__c = UserInfo.getUserId();
    currentRequest.RequestDate__c = Date.today();
    currentRequest.Status__c = 'Pending';
    currentRequestType = '';
    showModal = true;
  }

  public void selectRequestType() {
    currentRequestType = ApexPages.currentPage().getParameters().get('type');
    currentRequest.RequestType__c = currentRequestType;
  }

  public void closeModal() {
    showModal = false;
    currentRequest = new JIP_Request__c();
  }

  public void submitRequest() {
    try {
      insert currentRequest;

      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.CONFIRM,
          getT().get('request_submitted')
        )
      );

      showModal = false;
      currentRequest = new JIP_Request__c();
      loadStatistics();
      loadMyRequests();
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0))
      );
    }
  }

  public void approveRequest() {
    try {
      Id requestId = ApexPages.currentPage().getParameters().get('requestId');
      if (requestId != null) {
        JIP_Request__c req = [
          SELECT Id, Status__c
          FROM JIP_Request__c
          WHERE Id = :requestId
          LIMIT 1
        ];
        req.Status__c = 'Approved';
        req.ApprovedDate__c = Date.today();
        update req;

        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            getT().get('approved')
          )
        );

        loadStatistics();
        loadPendingApprovals();
      }
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0))
      );
    }
  }

  public void rejectRequest() {
    try {
      Id requestId = ApexPages.currentPage().getParameters().get('requestId');
      String comment = ApexPages.currentPage()
        .getParameters()
        .get('rejectComment');

      if (requestId != null) {
        JIP_Request__c req = [
          SELECT Id, Status__c
          FROM JIP_Request__c
          WHERE Id = :requestId
          LIMIT 1
        ];
        req.Status__c = 'Rejected';
        req.ApprovedDate__c = Date.today();
        req.ApproverComment__c = comment;
        update req;

        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            getT().get('rejected')
          )
        );

        loadStatistics();
        loadPendingApprovals();
      }
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0))
      );
    }
  }

  public void cancelRequest() {
    try {
      Id requestId = ApexPages.currentPage().getParameters().get('requestId');
      if (requestId != null) {
        JIP_Request__c req = [
          SELECT Id, Status__c, Applicant__c
          FROM JIP_Request__c
          WHERE Id = :requestId
          LIMIT 1
        ];

        // Only applicant can cancel their own request
        if (
          req.Applicant__c == UserInfo.getUserId() &&
          req.Status__c == 'Pending'
        ) {
          req.Status__c = 'Cancelled';
          update req;

          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.CONFIRM,
              getT().get('cancelled')
            )
          );

          loadStatistics();
          loadMyRequests();
        }
      }
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0))
      );
    }
  }

  public void changeLanguage() {
    loadMyRequests();
    loadPendingApprovals();
  }

  // ===== Select Options =====
  public List<SelectOption> getRequestTypeOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '-- ' + getT().get('select') + ' --'));
    options.add(new SelectOption('paid_leave', getT().get('paid_leave')));
    options.add(new SelectOption('sick_leave', getT().get('sick_leave')));
    options.add(new SelectOption('remote_work', getT().get('remote_work')));
    options.add(new SelectOption('overtime', getT().get('overtime')));
    options.add(new SelectOption('business_trip', getT().get('business_trip')));
    options.add(new SelectOption('expense_claim', getT().get('expense_claim')));
    options.add(new SelectOption('equipment', getT().get('equipment_request')));
    return options;
  }

  public List<SelectOption> getStatusFilterOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', getT().get('all')));
    options.add(new SelectOption('Pending', getT().get('pending_approval')));
    options.add(new SelectOption('Approved', getT().get('approved')));
    options.add(new SelectOption('Rejected', getT().get('rejected')));
    options.add(new SelectOption('Cancelled', getT().get('cancelled')));
    return options;
  }

  public List<SelectOption> getApproverOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '-- ' + getT().get('select') + ' --'));

    for (JIP_Worker__c worker : [
      SELECT Id, Name, LastName__c, FirstName__c, Worker_Code__c
      FROM JIP_Worker__c
      WHERE
        EmploymentStatus__c = '在職中'
        AND (Position__c LIKE '%長%'
        OR Position__c LIKE '%Manager%')
      ORDER BY Worker_Code__c
      LIMIT 100
    ]) {
      String label = worker.Worker_Code__c != null
        ? worker.Worker_Code__c + ' - '
        : '';
      label += worker.LastName__c != null ? worker.LastName__c : worker.Name;
      options.add(new SelectOption(worker.Id, label));
    }

    return options;
  }

  public List<SelectOption> getTabOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('my_requests', getT().get('my_requests')));
    options.add(
      new SelectOption('pending_approvals', getT().get('pending_approval'))
    );
    options.add(new SelectOption('all_requests', getT().get('all')));
    return options;
  }

  public List<SelectOption> getLanguageOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('ja', '日本語'));
    options.add(new SelectOption('en', 'English'));
    return options;
  }

  // ===== Wrapper Classes =====
  public class RequestWrapper {
    public JIP_Request__c record { get; set; }
    public String requestNumber { get; set; }
    public String requestType { get; set; }
    public String applicantCode { get; set; }
    public String applicantName { get; set; }
    public String departmentName { get; set; }
    public Date requestDate { get; set; }
    public Date startDate { get; set; }
    public Date endDate { get; set; }
    public String status { get; set; }
    public String statusClass { get; set; }
    public String comment { get; set; }
    public String approverName { get; set; }
    public Date approvedDate { get; set; }
    public String approverComment { get; set; }
    public Boolean canCancel { get; set; }
    public Boolean canApprove { get; set; }

    public RequestWrapper(JIP_Request__c r, Map<String, String> t) {
      this.record = r;
      this.requestNumber = r.Name;
      this.requestDate = r.RequestDate__c;
      this.startDate = r.StartDate__c;
      this.endDate = r.EndDate__c;
      this.comment = r.Comment__c;
      this.approvedDate = r.ApprovedDate__c;
      this.approverComment = r.ApproverComment__c;

      // Request type with translation
      if (r.RequestType__c == 'paid_leave') {
        this.requestType = t.get('paid_leave');
      } else if (r.RequestType__c == 'sick_leave') {
        this.requestType = t.get('sick_leave');
      } else if (r.RequestType__c == 'remote_work') {
        this.requestType = t.get('remote_work');
      } else if (r.RequestType__c == 'overtime') {
        this.requestType = t.get('overtime');
      } else if (r.RequestType__c == 'business_trip') {
        this.requestType = t.get('business_trip');
      } else if (r.RequestType__c == 'expense_claim') {
        this.requestType = t.get('expense_claim');
      } else {
        this.requestType = r.RequestType__c;
      }

      // Applicant info (User is standard object)
      if (r.Applicant__r != null) {
        this.applicantCode = '-';
        if (r.Applicant__r.LastName != null) {
          this.applicantName = r.Applicant__r.LastName;
          if (r.Applicant__r.FirstName != null) {
            this.applicantName += ' ' + r.Applicant__r.FirstName;
          }
        } else {
          this.applicantName = r.Applicant__r.Name;
        }
        this.departmentName = String.isNotBlank(r.Applicant__r.Department)
          ? r.Applicant__r.Department
          : '-';
      }

      // Approver
      this.approverName = r.Approver__r != null ? r.Approver__r.Name : '-';

      // Status with styling
      if (r.Status__c == 'Pending') {
        this.status = t.get('pending_approval');
        this.statusClass = 'slds-badge slds-badge_warning';
      } else if (r.Status__c == 'Approved') {
        this.status = t.get('approved');
        this.statusClass = 'slds-badge slds-badge_success';
      } else if (r.Status__c == 'Rejected') {
        this.status = t.get('rejected');
        this.statusClass = 'slds-badge slds-badge_error';
      } else if (r.Status__c == 'Cancelled') {
        this.status = t.get('cancelled');
        this.statusClass = 'slds-badge';
      } else {
        this.status = r.Status__c;
        this.statusClass = 'slds-badge';
      }

      // Permissions
      this.canCancel =
        r.Status__c == 'Pending' &&
        r.Applicant__c == UserInfo.getUserId();
      this.canApprove =
        r.Status__c == 'Pending' &&
        r.Approver__c == UserInfo.getUserId();
    }
  }
}