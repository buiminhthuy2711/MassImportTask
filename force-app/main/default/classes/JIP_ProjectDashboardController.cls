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
public with sharing class JIP_ProjectDashboardController {
  // ===== 1. Progress Rate =====
  @AuraEnabled(cacheable=true)
  public static Map<String, Integer> getProgressRate(Id projectId) {
    Map<String, Integer> result = new Map<String, Integer>();
    Integer total = [
      SELECT COUNT()
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId
    ];
    Integer completed = [
      SELECT COUNT()
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId AND Status__c = '完了'
    ];
    result.put('total', total);
    result.put('completed', completed);
    return result;
  }

  // ===== 2. Task Status Distribution =====
  @AuraEnabled(cacheable=true)
  public static List<StatusCount> getTaskStatusDistribution(Id projectId) {
    List<StatusCount> result = new List<StatusCount>();
    List<AggregateResult> ars = [
      SELECT Status__c, COUNT(Id) cnt
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId
      GROUP BY Status__c
      ORDER BY Status__c
    ];
    for (AggregateResult ar : ars) {
      result.add(
        new StatusCount((String) ar.get('Status__c'), (Integer) ar.get('cnt'))
      );
    }
    return result;
  }

  // ===== 3. Gantt Chart Data =====
  @AuraEnabled(cacheable=true)
  public static List<GanttTask> getGanttData(Id projectId) {
    List<GanttTask> result = new List<GanttTask>();
    List<JIP_ProjectTask__c> tasks = [
      SELECT
        Id,
        Name,
        Subject__c,
        StartDate__c,
        DueDate__c,
        Status__c,
        Assignee__r.LastName__c,
        Assignee__r.FirstName__c,
        Priority__c,
        Category__c
      FROM JIP_ProjectTask__c
      WHERE
        Project__c = :projectId
        AND StartDate__c != NULL
        AND DueDate__c != NULL
      ORDER BY StartDate__c ASC
    ];
    for (JIP_ProjectTask__c t : tasks) {
      GanttTask gt = new GanttTask();
      gt.id = t.Id;
      gt.taskKey = t.Name;
      gt.subject = t.Subject__c;
      gt.startDate = t.StartDate__c;
      gt.dueDate = t.DueDate__c;
      gt.status = t.Status__c;
      gt.priority = t.Priority__c;
      gt.category = t.Category__c;
      gt.isOverdue = t.DueDate__c < Date.today() && t.Status__c != '完了';
      String aName = '';
      if (t.Assignee__r != null) {
        if (t.Assignee__r.LastName__c != null)
          aName += t.Assignee__r.LastName__c;
        if (t.Assignee__r.FirstName__c != null)
          aName += ' ' + t.Assignee__r.FirstName__c;
      }
      gt.assigneeName = aName.trim();
      result.add(gt);
    }
    return result;
  }

  // ===== 4. Burndown Chart =====
  @AuraEnabled(cacheable=true)
  public static BurndownData getBurndownData(Id projectId) {
    BurndownData result = new BurndownData();

    JIP_Project__c proj = [
      SELECT StartDate__c, EndDate__c
      FROM JIP_Project__c
      WHERE Id = :projectId
      LIMIT 1
    ];
    Date startDt = proj.StartDate__c != null
      ? proj.StartDate__c
      : Date.today().addDays(-30);
    Date endDt = proj.EndDate__c != null
      ? proj.EndDate__c
      : Date.today().addDays(30);

    Integer totalTasks = [
      SELECT COUNT()
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId
    ];
    result.totalTasks = totalTasks;
    result.startDate = startDt;
    result.endDate = endDt;

    List<AggregateResult> completedByDate = [
      SELECT CompletedDate__c dt, COUNT(Id) cnt
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId AND CompletedDate__c != NULL
      GROUP BY CompletedDate__c
      ORDER BY CompletedDate__c ASC
    ];

    result.completedByDate = new List<DateCount>();
    for (AggregateResult ar : completedByDate) {
      result.completedByDate.add(
        new DateCount((Date) ar.get('dt'), (Integer) ar.get('cnt'))
      );
    }
    return result;
  }

  // ===== 5. Velocity (per Sprint) =====
  @AuraEnabled(cacheable=true)
  public static List<SprintVelocity> getVelocityData(Id projectId) {
    List<SprintVelocity> result = new List<SprintVelocity>();
    List<AggregateResult> ars = [
      SELECT Sprint__c, SUM(StoryPoints__c) pts
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId AND Sprint__c != NULL AND Status__c = '完了'
      GROUP BY Sprint__c
      ORDER BY Sprint__c ASC
    ];
    for (AggregateResult ar : ars) {
      result.add(
        new SprintVelocity(
          (String) ar.get('Sprint__c'),
          ar.get('pts') != null ? (Decimal) ar.get('pts') : 0
        )
      );
    }
    return result;
  }

  // ===== 6. Task Completion Trend (daily) =====
  @AuraEnabled(cacheable=true)
  public static List<DateCount> getCompletionTrend(Id projectId) {
    List<DateCount> result = new List<DateCount>();
    List<AggregateResult> ars = [
      SELECT CompletedDate__c dt, COUNT(Id) cnt
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId AND CompletedDate__c != NULL
      GROUP BY CompletedDate__c
      ORDER BY CompletedDate__c ASC
    ];
    for (AggregateResult ar : ars) {
      result.add(new DateCount((Date) ar.get('dt'), (Integer) ar.get('cnt')));
    }
    return result;
  }

  // ===== 7. Bug Count Trend =====
  @AuraEnabled(cacheable=true)
  public static List<DateCount> getBugTrend(Id projectId) {
    List<DateCount> result = new List<DateCount>();
    List<AggregateResult> ars = [
      SELECT DAY_ONLY(CreatedDate) dt, COUNT(Id) cnt
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId AND TaskType__c = 'バグ'
      GROUP BY DAY_ONLY(CreatedDate)
      ORDER BY DAY_ONLY(CreatedDate) ASC
    ];
    for (AggregateResult ar : ars) {
      result.add(new DateCount((Date) ar.get('dt'), (Integer) ar.get('cnt')));
    }
    return result;
  }

  @AuraEnabled(cacheable=true)
  public static List<DateCount> getBugFixTrend(Id projectId) {
    List<DateCount> result = new List<DateCount>();
    List<AggregateResult> ars = [
      SELECT CompletedDate__c dt, COUNT(Id) cnt
      FROM JIP_ProjectTask__c
      WHERE
        Project__c = :projectId
        AND TaskType__c = 'バグ'
        AND CompletedDate__c != NULL
      GROUP BY CompletedDate__c
      ORDER BY CompletedDate__c ASC
    ];
    for (AggregateResult ar : ars) {
      result.add(new DateCount((Date) ar.get('dt'), (Integer) ar.get('cnt')));
    }
    return result;
  }

  // ===== 8. Bug Status Distribution =====
  @AuraEnabled(cacheable=true)
  public static List<StatusCount> getBugStatusDistribution(Id projectId) {
    List<StatusCount> result = new List<StatusCount>();
    List<AggregateResult> ars = [
      SELECT Status__c, COUNT(Id) cnt
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId AND TaskType__c = 'バグ'
      GROUP BY Status__c
      ORDER BY Status__c
    ];
    for (AggregateResult ar : ars) {
      result.add(
        new StatusCount((String) ar.get('Status__c'), (Integer) ar.get('cnt'))
      );
    }
    return result;
  }

  // ===== 9. Overdue Tasks =====
  @AuraEnabled(cacheable=true)
  public static List<OverdueInfo> getOverdueTasks(Id projectId) {
    List<OverdueInfo> result = new List<OverdueInfo>();
    List<AggregateResult> ars = [
      SELECT
        Assignee__r.LastName__c lname,
        Assignee__r.FirstName__c fname,
        COUNT(Id) cnt
      FROM JIP_ProjectTask__c
      WHERE
        Project__c = :projectId
        AND DueDate__c < TODAY
        AND Status__c != '完了'
      GROUP BY Assignee__r.LastName__c, Assignee__r.FirstName__c
      ORDER BY COUNT(Id) DESC
    ];
    for (AggregateResult ar : ars) {
      String name = '';
      if (ar.get('lname') != null)
        name += (String) ar.get('lname');
      if (ar.get('fname') != null)
        name += ' ' + (String) ar.get('fname');
      if (String.isBlank(name))
        name = '未割当';
      result.add(new OverdueInfo(name.trim(), (Integer) ar.get('cnt')));
    }
    return result;
  }

  @AuraEnabled(cacheable=true)
  public static Integer getOverdueCount(Id projectId) {
    return [
      SELECT COUNT()
      FROM JIP_ProjectTask__c
      WHERE
        Project__c = :projectId
        AND DueDate__c < TODAY
        AND Status__c != '完了'
    ];
  }

  // ===== 10. Critical Path (tasks with high priority, on critical timeline) =====
  @AuraEnabled(cacheable=true)
  public static List<GanttTask> getCriticalPathData(Id projectId) {
    List<GanttTask> result = new List<GanttTask>();
    List<JIP_ProjectTask__c> tasks = [
      SELECT
        Id,
        Name,
        Subject__c,
        StartDate__c,
        DueDate__c,
        Status__c,
        Assignee__r.LastName__c,
        Assignee__r.FirstName__c,
        Priority__c,
        Category__c
      FROM JIP_ProjectTask__c
      WHERE
        Project__c = :projectId
        AND StartDate__c != NULL
        AND DueDate__c != NULL
        AND (Priority__c = '高'
        OR (DueDate__c < TODAY
        AND Status__c != '完了'))
      ORDER BY DueDate__c ASC
    ];
    for (JIP_ProjectTask__c t : tasks) {
      GanttTask gt = new GanttTask();
      gt.id = t.Id;
      gt.taskKey = t.Name;
      gt.subject = t.Subject__c;
      gt.startDate = t.StartDate__c;
      gt.dueDate = t.DueDate__c;
      gt.status = t.Status__c;
      gt.priority = t.Priority__c;
      gt.category = t.Category__c;
      gt.isOverdue = t.DueDate__c < Date.today() && t.Status__c != '完了';
      String aName = '';
      if (t.Assignee__r != null) {
        if (t.Assignee__r.LastName__c != null)
          aName += t.Assignee__r.LastName__c;
        if (t.Assignee__r.FirstName__c != null)
          aName += ' ' + t.Assignee__r.FirstName__c;
      }
      gt.assigneeName = aName.trim();
      result.add(gt);
    }
    return result;
  }

  // ===== 11. Member Task Load =====
  @AuraEnabled(cacheable=true)
  public static List<MemberLoad> getMemberTaskLoad(Id projectId) {
    Map<String, MemberLoad> loadMap = new Map<String, MemberLoad>();
    List<AggregateResult> ars = [
      SELECT
        Assignee__r.LastName__c lname,
        Assignee__r.FirstName__c fname,
        Status__c,
        COUNT(Id) cnt
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId AND Assignee__c != NULL
      GROUP BY Assignee__r.LastName__c, Assignee__r.FirstName__c, Status__c
    ];
    for (AggregateResult ar : ars) {
      String name = '';
      if (ar.get('lname') != null)
        name += (String) ar.get('lname');
      if (ar.get('fname') != null)
        name += ' ' + (String) ar.get('fname');
      name = name.trim();
      MemberLoad ml = loadMap.get(name);
      if (ml == null) {
        ml = new MemberLoad();
        ml.memberName = name;
        ml.notStarted = 0;
        ml.inProgress = 0;
        ml.resolved = 0;
        ml.done = 0;
        ml.total = 0;
        loadMap.put(name, ml);
      }
      Integer cnt = (Integer) ar.get('cnt');
      String status = (String) ar.get('Status__c');
      if (status == '未対応') {
        ml.notStarted = cnt;
      } else if (status == '処理中') {
        ml.inProgress = cnt;
      } else if (status == '処理済み') {
        ml.resolved = cnt;
      } else if (status == '完了') {
        ml.done = cnt;
      }
      ml.total += cnt;
    }
    List<MemberLoad> result = loadMap.values();
    result.sort();
    return result;
  }

  // ===== 12. Utilization Rate =====
  @AuraEnabled(cacheable=true)
  public static List<UtilizationInfo> getUtilizationData(Id projectId) {
    List<UtilizationInfo> result = new List<UtilizationInfo>();
    List<AggregateResult> ars = [
      SELECT
        Assignee__r.LastName__c lname,
        Assignee__r.FirstName__c fname,
        SUM(EstimatedHours__c) estimated,
        SUM(ActualHours__c) actual
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId AND Assignee__c != NULL
      GROUP BY Assignee__r.LastName__c, Assignee__r.FirstName__c
      ORDER BY Assignee__r.LastName__c ASC
    ];
    for (AggregateResult ar : ars) {
      UtilizationInfo ui = new UtilizationInfo();
      String name = '';
      if (ar.get('lname') != null)
        name += (String) ar.get('lname');
      if (ar.get('fname') != null)
        name += ' ' + (String) ar.get('fname');
      ui.memberName = name.trim();
      ui.estimatedHours = ar.get('estimated') != null
        ? (Decimal) ar.get('estimated')
        : 0;
      ui.actualHours = ar.get('actual') != null
        ? (Decimal) ar.get('actual')
        : 0;
      ui.utilizationRate = ui.estimatedHours > 0
        ? (ui.actualHours / ui.estimatedHours * 100).setScale(1)
        : 0;
      result.add(ui);
    }
    return result;
  }

  // ===== 13. Budget vs Actual Cost =====
  @AuraEnabled(cacheable=true)
  public static BudgetInfo getBudgetVsActual(Id projectId) {
    BudgetInfo result = new BudgetInfo();
    JIP_Project__c proj = [
      SELECT Budget__c, ActualCost__c
      FROM JIP_Project__c
      WHERE Id = :projectId
      LIMIT 1
    ];
    result.budget = proj.Budget__c != null ? proj.Budget__c : 0;
    result.actualCost = proj.ActualCost__c != null ? proj.ActualCost__c : 0;
    result.remaining = result.budget - result.actualCost;
    return result;
  }

  // ===== 14. S-Curve (Plan vs Actual) =====
  @AuraEnabled(cacheable=true)
  public static SCurveData getSCurveData(Id projectId) {
    SCurveData result = new SCurveData();

    JIP_Project__c proj = [
      SELECT StartDate__c, EndDate__c
      FROM JIP_Project__c
      WHERE Id = :projectId
      LIMIT 1
    ];
    Date startDt = proj.StartDate__c != null
      ? proj.StartDate__c
      : Date.today().addDays(-30);
    Date endDt = proj.EndDate__c != null
      ? proj.EndDate__c
      : Date.today().addDays(30);

    result.startDate = startDt;
    result.endDate = endDt;

    Integer totalTasks = [
      SELECT COUNT()
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId
    ];
    result.totalTasks = totalTasks;

    // Planned: distribute tasks evenly over project duration (due dates)
    List<AggregateResult> plannedByDate = [
      SELECT DueDate__c dt, COUNT(Id) cnt
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId AND DueDate__c != NULL
      GROUP BY DueDate__c
      ORDER BY DueDate__c ASC
    ];
    result.plannedByDate = new List<DateCount>();
    for (AggregateResult ar : plannedByDate) {
      result.plannedByDate.add(
        new DateCount((Date) ar.get('dt'), (Integer) ar.get('cnt'))
      );
    }

    // Actual: completed dates
    List<AggregateResult> actualByDate = [
      SELECT CompletedDate__c dt, COUNT(Id) cnt
      FROM JIP_ProjectTask__c
      WHERE Project__c = :projectId AND CompletedDate__c != NULL
      GROUP BY CompletedDate__c
      ORDER BY CompletedDate__c ASC
    ];
    result.actualByDate = new List<DateCount>();
    for (AggregateResult ar : actualByDate) {
      result.actualByDate.add(
        new DateCount((Date) ar.get('dt'), (Integer) ar.get('cnt'))
      );
    }
    return result;
  }

  // ===== Project List (for selector) =====
  @AuraEnabled(cacheable=true)
  public static List<ProjectOption> getProjectList() {
    List<ProjectOption> result = new List<ProjectOption>();
    List<JIP_Project__c> projects = [
      SELECT Id, Name, Name__c, Status__c
      FROM JIP_Project__c
      ORDER BY Name ASC
      LIMIT 200
    ];
    for (JIP_Project__c p : projects) {
      String label = p.Name__c != null ? p.Name__c : p.Name;
      result.add(new ProjectOption(p.Id, label, p.Status__c));
    }
    return result;
  }

  // ===== Inner Classes =====

  public class StatusCount {
    @AuraEnabled
    public String status;
    @AuraEnabled
    public Integer count;
    public StatusCount(String s, Integer c) {
      this.status = s;
      this.count = c;
    }
  }

  public class DateCount {
    @AuraEnabled
    public Date dt;
    @AuraEnabled
    public Integer count;
    public DateCount(Date d, Integer c) {
      this.dt = d;
      this.count = c;
    }
  }

  public class GanttTask {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String taskKey;
    @AuraEnabled
    public String subject;
    @AuraEnabled
    public Date startDate;
    @AuraEnabled
    public Date dueDate;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String priority;
    @AuraEnabled
    public String category;
    @AuraEnabled
    public String assigneeName;
    @AuraEnabled
    public Boolean isOverdue;
  }

  public class BurndownData {
    @AuraEnabled
    public Integer totalTasks;
    @AuraEnabled
    public Date startDate;
    @AuraEnabled
    public Date endDate;
    @AuraEnabled
    public List<DateCount> completedByDate;
  }

  public class SprintVelocity {
    @AuraEnabled
    public String sprint;
    @AuraEnabled
    public Decimal points;
    public SprintVelocity(String s, Decimal p) {
      this.sprint = s;
      this.points = p;
    }
  }

  public class OverdueInfo {
    @AuraEnabled
    public String assigneeName;
    @AuraEnabled
    public Integer count;
    public OverdueInfo(String n, Integer c) {
      this.assigneeName = n;
      this.count = c;
    }
  }

  public class MemberLoad implements Comparable {
    @AuraEnabled
    public String memberName;
    @AuraEnabled
    public Integer notStarted;
    @AuraEnabled
    public Integer inProgress;
    @AuraEnabled
    public Integer resolved;
    @AuraEnabled
    public Integer done;
    @AuraEnabled
    public Integer total;
    public Integer compareTo(Object other) {
      MemberLoad o = (MemberLoad) other;
      return o.total - this.total; // descending by total
    }
  }

  public class UtilizationInfo {
    @AuraEnabled
    public String memberName;
    @AuraEnabled
    public Decimal estimatedHours;
    @AuraEnabled
    public Decimal actualHours;
    @AuraEnabled
    public Decimal utilizationRate;
  }

  public class BudgetInfo {
    @AuraEnabled
    public Decimal budget;
    @AuraEnabled
    public Decimal actualCost;
    @AuraEnabled
    public Decimal remaining;
  }

  public class SCurveData {
    @AuraEnabled
    public Date startDate;
    @AuraEnabled
    public Date endDate;
    @AuraEnabled
    public Integer totalTasks;
    @AuraEnabled
    public List<DateCount> plannedByDate;
    @AuraEnabled
    public List<DateCount> actualByDate;
  }

  public class ProjectOption {
    @AuraEnabled
    public Id value;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String status;
    public ProjectOption(Id v, String l, String s) {
      this.value = v;
      this.label = l;
      this.status = s;
    }
  }
}