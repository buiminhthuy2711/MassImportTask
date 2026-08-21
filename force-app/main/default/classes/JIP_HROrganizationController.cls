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
public with sharing class JIP_HROrganizationController {
  // ===== Properties =====
  public String language { get; set; }
  public String searchKeyword { get; set; }
  public String selectedTab { get; set; }

  // Data lists
  public List<DepartmentWrapper> departments { get; set; }
  public List<DepartmentWrapper> rootDepartments { get; set; }
  public List<WorkerHierarchyWrapper> rootWorkers { get; set; }
  public List<RoleWrapper> roles { get; set; }

  // Modal control
  public Boolean showModal { get; set; }
  public Boolean isEditMode { get; set; }
  public JIP_Department__c currentDepartment { get; set; }

  // Edit/Delete params
  public Id editDeptId { get; set; }
  public Id deleteDeptId { get; set; }

  // Workers modal
  public Boolean showWorkersModal { get; set; }
  public Id viewDeptId { get; set; }
  public String viewDeptName { get; set; }
  public List<WorkerWrapper> deptWorkers { get; set; }

  // Stats
  public Integer totalDepartments { get; set; }
  public Integer totalManagers { get; set; }
  public Integer totalEmployees { get; set; }
  private Map<Id, String> workerAvatarUrlById;

  // ===== Constructor =====
  public JIP_HROrganizationController() {
    language = 'ja';
    searchKeyword = '';
    selectedTab = 'org_chart';
    showModal = false;
    showWorkersModal = false;
    isEditMode = false;
    currentDepartment = new JIP_Department__c();
    deptWorkers = new List<WorkerWrapper>();
    workerAvatarUrlById = new Map<Id, String>();

    loadStatistics();
    loadDepartments();
    loadRoles();
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
    totalDepartments = [
      SELECT COUNT()
      FROM JIP_Department__c
      WHERE IsActive__c = TRUE
    ];
    totalManagers = [
      SELECT COUNT()
      FROM JIP_Worker__c
      WHERE Position__c LIKE '%長%' AND EmploymentStatus__c = '在職'
    ];
    totalEmployees = [
      SELECT COUNT()
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職'
    ];
  }

  private void loadDepartments() {
    departments = new List<DepartmentWrapper>();

    String query =
      'SELECT Id, Name, DepartmentCode__c, ParentDepartment__c, ' +
      'ParentDepartment__r.Name, Manager__c, Manager__r.Name, ' +
      'Manager__r.LastName__c, Manager__r.FirstName__c, IsActive__c ' +
      'FROM JIP_Department__c WHERE IsActive__c = true';

    if (String.isNotBlank(searchKeyword)) {
      String safeKeyword =
        '%' +
        String.escapeSingleQuotes(searchKeyword.trim()) +
        '%';
      query += ' AND (Name LIKE :safeKeyword OR DepartmentCode__c LIKE :safeKeyword)';
    }

    query += ' ORDER BY DepartmentCode__c ASC';

    // Get member counts
    Map<Id, Integer> memberCounts = new Map<Id, Integer>();
    for (AggregateResult ar : [
      SELECT Department__c deptId, COUNT(Id) cnt
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職'
      GROUP BY Department__c
    ]) {
      memberCounts.put((Id) ar.get('deptId'), (Integer) ar.get('cnt'));
    }

    // Track each active worker's department so manager counting matches modal display.
    Map<Id, Id> activeWorkerDeptById = new Map<Id, Id>();
    for (JIP_Worker__c worker : [
      SELECT Id, Department__c
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職'
    ]) {
      activeWorkerDeptById.put(worker.Id, worker.Department__c);
    }

    List<JIP_Department__c> queriedDepartments = Database.query(query);
    Set<Id> managerIds = new Set<Id>();
    for (JIP_Department__c dept : queriedDepartments) {
      if (dept.Manager__c != null) {
        managerIds.add(dept.Manager__c);
      }
    }
    ensureWorkerAvatarUrls(managerIds);

    for (JIP_Department__c dept : queriedDepartments) {
      Integer memberCount = memberCounts.containsKey(dept.Id)
        ? memberCounts.get(dept.Id)
        : 0;
      // If assigned manager is not already counted in this department's active workers,
      // include the manager to keep the card count consistent with the modal list.
      if (
        dept.Manager__c != null &&
        activeWorkerDeptById.get(dept.Manager__c) != dept.Id
      ) {
        memberCount += 1;
      }
      if (memberCount == 0 && dept.Manager__c != null) {
        memberCount = 1;
      }
      DepartmentWrapper wrapper = new DepartmentWrapper(dept, memberCount);
      if (
        dept.Manager__c != null &&
        String.isNotBlank(workerAvatarUrlById.get(dept.Manager__c))
      ) {
        wrapper.iconUrl = workerAvatarUrlById.get(dept.Manager__c);
      }
      departments.add(wrapper);
    }
    buildTree();
    loadWorkerHierarchy();
  }

  private void loadWorkerHierarchy() {
    Map<Id, WorkerHierarchyWrapper> workerById = new Map<Id, WorkerHierarchyWrapper>();
    Set<Id> workerIds = new Set<Id>();
    for (JIP_Worker__c worker : [
      SELECT
        Id,
        Name,
        Worker_Code__c,
        LastName__c,
        FirstName__c,
        Position__c,
        Department__r.Name,
        Email__c,
        Phone__c,
        EmploymentStatus__c,
        Manager__c
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職'
      ORDER BY Worker_Code__c ASC, Name ASC
    ]) {
      workerIds.add(worker.Id);
      workerById.put(worker.Id, new WorkerHierarchyWrapper(worker));
    }

    ensureWorkerAvatarUrls(workerIds);

    Set<Id> deptManagerIds = new Set<Id>();
    for (JIP_Department__c dept : [
      SELECT Manager__c
      FROM JIP_Department__c
      WHERE IsActive__c = TRUE AND Manager__c != NULL
    ]) {
      deptManagerIds.add(dept.Manager__c);
    }

    for (WorkerHierarchyWrapper workerNode : workerById.values()) {
      workerNode.avatarUrl = workerAvatarUrlById.get(workerNode.workerId);
      workerNode.isDeptManager = deptManagerIds.contains(workerNode.workerId);
    }

    rootWorkers = new List<WorkerHierarchyWrapper>();
    for (WorkerHierarchyWrapper workerNode : workerById.values()) {
      if (
        workerNode.managerId == null ||
        !workerById.containsKey(workerNode.managerId)
      ) {
        rootWorkers.add(workerNode);
      } else {
        workerById.get(workerNode.managerId).children.add(workerNode);
      }
    }
  }

  public String getEmployeeHierarchyJson() {
    return JSON.serialize(serializeWorkerNodes(rootWorkers, new Set<Id>()));
  }

  private List<Map<String, Object>> serializeWorkerNodes(
    List<WorkerHierarchyWrapper> nodes,
    Set<Id> visitedWorkerIds
  ) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();
    for (WorkerHierarchyWrapper node : nodes) {
      if (node.workerId != null && visitedWorkerIds.contains(node.workerId)) {
        continue;
      }
      if (node.workerId != null) {
        visitedWorkerIds.add(node.workerId);
      }

      Map<String, Object> nodeMap = new Map<String, Object>();
      nodeMap.put('id', node.workerId);
      nodeMap.put('workerCode', node.workerCode);
      nodeMap.put('workerName', node.workerName);
      nodeMap.put('position', node.position);
      nodeMap.put('departmentName', node.departmentName);
      nodeMap.put('avatarUrl', node.avatarUrl);
      nodeMap.put('isDeptManager', node.isDeptManager);
      nodeMap.put(
        'children',
        serializeWorkerNodes(node.children, visitedWorkerIds)
      );
      result.add(nodeMap);
    }
    return result;
  }

  private void ensureWorkerAvatarUrls(Set<Id> workerIds) {
    if (workerIds == null || workerIds.isEmpty()) {
      return;
    }

    Set<Id> missingIds = new Set<Id>();
    for (Id workerId : workerIds) {
      if (workerId != null && !workerAvatarUrlById.containsKey(workerId)) {
        missingIds.add(workerId);
        workerAvatarUrlById.put(workerId, '');
      }
    }
    if (missingIds.isEmpty()) {
      return;
    }

    Set<String> imageTypes = new Set<String>{
      'PNG',
      'JPG',
      'JPEG',
      'GIF',
      'WEBP'
    };
    for (ContentDocumentLink link : [
      SELECT
        LinkedEntityId,
        ContentDocument.LatestPublishedVersionId,
        ContentDocument.FileType,
        ContentDocument.LastModifiedDate
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN :missingIds
      ORDER BY LinkedEntityId, ContentDocument.LastModifiedDate DESC
      LIMIT 5000
    ]) {
      Id linkedWorkerId = link.LinkedEntityId;
      if (String.isNotBlank(workerAvatarUrlById.get(linkedWorkerId))) {
        continue;
      }

      String fileType = link.ContentDocument.FileType != null
        ? link.ContentDocument.FileType.toUpperCase()
        : '';
      if (
        imageTypes.contains(fileType) &&
        link.ContentDocument.LatestPublishedVersionId != null
      ) {
        workerAvatarUrlById.put(
          linkedWorkerId,
          '/sfc/servlet.shepherd/version/download/' +
          link.ContentDocument.LatestPublishedVersionId
        );
      }
    }
  }

  private void buildTree() {
    Map<Id, DepartmentWrapper> deptById = new Map<Id, DepartmentWrapper>();
    for (DepartmentWrapper dw : departments) {
      deptById.put(dw.record.Id, dw);
    }
    rootDepartments = new List<DepartmentWrapper>();
    for (DepartmentWrapper dw : departments) {
      if (dw.record.ParentDepartment__c == null) {
        rootDepartments.add(dw);
      } else if (deptById.containsKey(dw.record.ParentDepartment__c)) {
        deptById.get(dw.record.ParentDepartment__c).children.add(dw);
      } else {
        rootDepartments.add(dw);
      }
    }

    for (DepartmentWrapper root : rootDepartments) {
      rollupMemberCount(root);
    }
  }

  private Integer rollupMemberCount(DepartmentWrapper node) {
    Integer total = node.directMemberCount;
    for (DepartmentWrapper child : node.children) {
      total += rollupMemberCount(child);
    }
    node.memberCount = String.valueOf(total);
    return total;
  }

  private void loadRoles() {
    roles = new List<RoleWrapper>();

    // Define standard roles with permissions
    roles.add(
      new RoleWrapper(
        'admin',
        getT().get('admin'),
        true,
        true,
        true,
        true,
        true
      )
    );
    roles.add(
      new RoleWrapper(
        'hr_dept',
        getT().get('hr_dept'),
        true,
        true,
        true,
        true,
        false
      )
    );
    roles.add(
      new RoleWrapper(
        'dept_head',
        getT().get('dept_head'),
        true,
        false,
        true,
        true,
        false
      )
    );
    roles.add(
      new RoleWrapper(
        'general',
        getT().get('general_employee'),
        true,
        false,
        false,
        true,
        false
      )
    );
  }

  // ===== Action Methods =====
  public void searchDepartments() {
    loadDepartments();
  }

  public void clearSearch() {
    searchKeyword = '';
    loadDepartments();
  }

  public void changeTab() {
    // Tab is already bound to selectedTab property
  }

  public void openNewModal() {
    currentDepartment = new JIP_Department__c();
    isEditMode = false;
    showModal = true;
  }

  public void openEditModal() {
    if (editDeptId != null) {
      List<JIP_Department__c> depts = [
        SELECT Id, Name, DepartmentCode__c, ParentDepartment__c, Manager__c
        FROM JIP_Department__c
        WHERE Id = :editDeptId
        LIMIT 1
      ];
      if (!depts.isEmpty()) {
        currentDepartment = depts[0];
        isEditMode = true;
        showModal = true;
      }
    }
  }

  public void closeModal() {
    showModal = false;
    currentDepartment = new JIP_Department__c();
  }

  public void openWorkersModal() {
    if (viewDeptId != null) {
      List<JIP_Department__c> depts = [
        SELECT Id, Name, Manager__c
        FROM JIP_Department__c
        WHERE Id = :viewDeptId
        LIMIT 1
      ];
      Id deptManagerId;
      if (!depts.isEmpty()) {
        viewDeptName = depts[0].Name;
        deptManagerId = depts[0].Manager__c;
      }

      deptWorkers = new List<WorkerWrapper>();
      WorkerWrapper managerWrapper;
      Set<Id> workerIds = new Set<Id>();
      for (JIP_Worker__c w : [
        SELECT
          Id,
          Name,
          Worker_Code__c,
          LastName__c,
          FirstName__c,
          Position__c,
          Email__c,
          Phone__c,
          EmploymentStatus__c
        FROM JIP_Worker__c
        WHERE Department__c = :viewDeptId AND EmploymentStatus__c = '在職'
        ORDER BY Worker_Code__c ASC
      ]) {
        if (deptManagerId != null && w.Id == deptManagerId) {
          managerWrapper = new WorkerWrapper(w, true);
        } else {
          deptWorkers.add(new WorkerWrapper(w, false));
        }
        workerIds.add(w.Id);
      }

      // Always include assigned manager if present and not already listed.
      if (deptManagerId != null && !workerIds.contains(deptManagerId)) {
        List<JIP_Worker__c> managerWorkers = [
          SELECT
            Id,
            Name,
            Worker_Code__c,
            LastName__c,
            FirstName__c,
            Position__c,
            Email__c,
            Phone__c,
            EmploymentStatus__c
          FROM JIP_Worker__c
          WHERE Id = :deptManagerId
          LIMIT 1
        ];
        if (!managerWorkers.isEmpty()) {
          managerWrapper = new WorkerWrapper(managerWorkers[0], true);
        }
      }

      if (managerWrapper != null) {
        List<WorkerWrapper> orderedWorkers = new List<WorkerWrapper>();
        orderedWorkers.add(managerWrapper);
        orderedWorkers.addAll(deptWorkers);
        deptWorkers = dedupeWorkerWrappers(orderedWorkers);
      } else {
        deptWorkers = dedupeWorkerWrappers(deptWorkers);
      }
      showWorkersModal = true;
    }
  }

  private List<WorkerWrapper> dedupeWorkerWrappers(
    List<WorkerWrapper> workers
  ) {
    List<WorkerWrapper> uniqueWorkers = new List<WorkerWrapper>();
    Set<String> seenWorkerIds = new Set<String>();
    for (WorkerWrapper worker : workers) {
      String key = String.valueOf(worker.workerId);
      if (!seenWorkerIds.contains(key)) {
        seenWorkerIds.add(key);
        uniqueWorkers.add(worker);
      }
    }
    return uniqueWorkers;
  }

  public void closeWorkersModal() {
    showWorkersModal = false;
    deptWorkers = new List<WorkerWrapper>();
  }

  public void saveDepartment() {
    try {
      if (isEditMode) {
        update currentDepartment;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            getT().get('department') + ' ' + getT().get('task_updated')
          )
        );
      } else {
        currentDepartment.IsActive__c = true;
        insert currentDepartment;
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            getT().get('department') + ' ' + getT().get('task_created')
          )
        );
      }

      showModal = false;
      currentDepartment = new JIP_Department__c();
      loadStatistics();
      loadDepartments();
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0))
      );
    }
  }

  public void deleteDepartment() {
    try {
      Id deptId = deleteDeptId;
      if (deptId != null) {
        JIP_Department__c dept = [
          SELECT Id
          FROM JIP_Department__c
          WHERE Id = :deptId
          LIMIT 1
        ];
        delete dept;
        deleteDeptId = null;

        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.CONFIRM,
            getT().get('department') + ' ' + getT().get('task_deleted')
          )
        );

        loadStatistics();
        loadDepartments();
      }
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0))
      );
    }
  }

  public void changeLanguage() {
    loadRoles(); // Reload roles with new language
  }

  // ===== Select Options =====
  public List<SelectOption> getTabOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('org_chart', getT().get('org_chart')));
    options.add(new SelectOption('dept_list', getT().get('department_list')));
    options.add(new SelectOption('roles', getT().get('role_permission')));
    return options;
  }

  public List<SelectOption> getParentDepartmentOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '-- ' + getT().get('none') + ' --'));

    for (JIP_Department__c dept : [
      SELECT Id, Name, DepartmentCode__c
      FROM JIP_Department__c
      WHERE IsActive__c = TRUE
      ORDER BY DepartmentCode__c
    ]) {
      String label = dept.DepartmentCode__c != null
        ? dept.DepartmentCode__c + ' - ' + dept.Name
        : dept.Name;
      options.add(new SelectOption(dept.Id, label));
    }

    return options;
  }

  public List<SelectOption> getManagerOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '-- ' + getT().get('none') + ' --'));

    for (JIP_Worker__c worker : [
      SELECT Id, Name, LastName__c, FirstName__c, Worker_Code__c
      FROM JIP_Worker__c
      WHERE EmploymentStatus__c = '在職'
      ORDER BY Worker_Code__c
      LIMIT 500
    ]) {
      String label = worker.Worker_Code__c != null
        ? worker.Worker_Code__c + ' - '
        : '';
      label += worker.LastName__c != null ? worker.LastName__c : '';
      label += worker.FirstName__c != null
        ? ' ' + worker.FirstName__c
        : worker.Name;
      options.add(new SelectOption(worker.Id, label));
    }

    return options;
  }

  public List<SelectOption> getLanguageOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('ja', '日本語'));
    options.add(new SelectOption('en', 'English'));
    return options;
  }

  // ===== Tree Data JSON =====
  public String getTreeDataJson() {
    return JSON.serialize(serializeTreeNodes(rootDepartments));
  }

  private List<Map<String, Object>> serializeTreeNodes(
    List<DepartmentWrapper> nodes
  ) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();
    for (DepartmentWrapper node : nodes) {
      Map<String, Object> nodeMap = new Map<String, Object>();
      nodeMap.put('id', node.record.Id);
      nodeMap.put('deptCode', node.deptCode);
      nodeMap.put('deptName', node.deptName);
      nodeMap.put('memberCount', node.memberCount);
      nodeMap.put('managerName', node.managerName);
      nodeMap.put('iconUrl', node.iconUrl);
      nodeMap.put('children', serializeTreeNodes(node.children));
      result.add(nodeMap);
    }
    return result;
  }

  // ===== Wrapper Classes =====
  public class DepartmentWrapper {
    public JIP_Department__c record { get; set; }
    public String deptCode { get; set; }
    public String deptName { get; set; }
    public String parentName { get; set; }
    public String managerName { get; set; }
    public String memberCount { get; set; }
    public Integer directMemberCount { get; set; }
    public String iconUrl { get; set; }
    public List<DepartmentWrapper> children { get; set; }

    public DepartmentWrapper(JIP_Department__c dept, Integer count) {
      this.record = dept;
      this.children = new List<DepartmentWrapper>();
      this.deptCode = dept.DepartmentCode__c;
      this.deptName = dept.Name;
      this.directMemberCount = count;
      this.memberCount = String.valueOf(count);
      this.iconUrl = null;
      this.parentName = dept.ParentDepartment__r != null
        ? dept.ParentDepartment__r.Name
        : '-';

      if (dept.Manager__r != null) {
        this.managerName = '';
        if (dept.Manager__r.LastName__c != null)
          this.managerName += dept.Manager__r.LastName__c;
        if (dept.Manager__r.FirstName__c != null)
          this.managerName += ' ' + dept.Manager__r.FirstName__c;
        if (String.isBlank(this.managerName))
          this.managerName = dept.Manager__r.Name;
      } else {
        this.managerName = '-';
      }
    }
  }

  public class RoleWrapper {
    public String roleId { get; set; }
    public String roleName { get; set; }
    public Boolean canViewEmployee { get; set; }
    public Boolean canViewSalary { get; set; }
    public Boolean canViewEvaluation { get; set; }
    public Boolean canApproveRequests { get; set; }
    public Boolean canAccessSystem { get; set; }

    public RoleWrapper(
      String roleId,
      String roleName,
      Boolean emp,
      Boolean sal,
      Boolean eval,
      Boolean req,
      Boolean sys
    ) {
      this.roleId = roleId;
      this.roleName = roleName;
      this.canViewEmployee = emp;
      this.canViewSalary = sal;
      this.canViewEvaluation = eval;
      this.canApproveRequests = req;
      this.canAccessSystem = sys;
    }
  }

  public class WorkerHierarchyWrapper {
    public Id workerId { get; set; }
    public Id managerId { get; set; }
    public String workerCode { get; set; }
    public String workerName { get; set; }
    public String position { get; set; }
    public String departmentName { get; set; }
    public String avatarUrl { get; set; }
    public Boolean isDeptManager { get; set; }
    public List<WorkerHierarchyWrapper> children { get; set; }

    public WorkerHierarchyWrapper(JIP_Worker__c w) {
      this.workerId = w.Id;
      this.managerId = w.Manager__c;
      this.workerCode = w.Worker_Code__c;
      this.workerName = '';
      if (w.LastName__c != null) {
        this.workerName += w.LastName__c;
      }
      if (w.FirstName__c != null) {
        this.workerName += ' ' + w.FirstName__c;
      }
      if (String.isBlank(this.workerName)) {
        this.workerName = w.Name;
      }
      this.position = w.Position__c;
      this.departmentName = w.Department__r != null
        ? w.Department__r.Name
        : null;
      this.avatarUrl = null;
      this.isDeptManager = false;
      this.children = new List<WorkerHierarchyWrapper>();
    }
  }

  public class WorkerWrapper {
    public String workerId { get; set; }
    public String workerCode { get; set; }
    public String workerName { get; set; }
    public String position { get; set; }
    public String email { get; set; }
    public String phone { get; set; }
    public String status { get; set; }
    public Boolean isManager { get; set; }

    public WorkerWrapper(JIP_Worker__c w) {
      this(w, false);
    }

    public WorkerWrapper(JIP_Worker__c w, Boolean isManager) {
      this.workerId = w.Id;
      this.workerCode = w.Worker_Code__c;
      this.workerName = '';
      if (w.LastName__c != null) {
        this.workerName += w.LastName__c;
      }
      if (w.FirstName__c != null) {
        this.workerName += ' ' + w.FirstName__c;
      }
      if (String.isBlank(this.workerName)) {
        this.workerName = w.Name;
      }
      this.position = w.Position__c;
      this.email = w.Email__c;
      this.phone = w.Phone__c;
      this.status = w.EmploymentStatus__c;
      this.isManager = isManager;
    }
  }
}