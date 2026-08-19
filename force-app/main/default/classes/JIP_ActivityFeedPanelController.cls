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
public with sharing class JIP_ActivityFeedPanelController {
  public Id selectedProjectId { get; set; }
  public JIP_Project__c project { get; set; }
  public List<ActivityWrapper> activities { get; set; }
  public String filterType { get; set; }
  public Integer totalCount { get; set; }
  public Integer displayLimit { get; set; }
  public Boolean hasMore { get; set; }
  public Integer remainingCount { get; set; }
  public Integer newCount { get; set; }
  public String lastSeenTime { get; set; }
  private static final Integer PAGE_SIZE = 20;

  public JIP_ActivityFeedPanelController() {
    filterType = '';
    activities = new List<ActivityWrapper>();
    totalCount = 0;
    displayLimit = PAGE_SIZE;
    hasMore = false;
    remainingCount = 0;
    newCount = 0;
    lastSeenTime = '';
  }

  public void init() {
    if (selectedProjectId != null) {
      loadProject();
      loadActivities();
    }
  }

  private void loadProject() {
    List<JIP_Project__c> projects = [
      SELECT Id, Name, Name__c, Status__c
      FROM JIP_Project__c
      WHERE Id = :selectedProjectId
      LIMIT 1
    ];
    if (!projects.isEmpty()) {
      project = projects[0];
    }
  }

  public void loadActivities() {
    if (selectedProjectId == null)
      return;

    String countQuery = 'SELECT COUNT() FROM JIP_ProjectActivity__c WHERE Project__c = :selectedProjectId';
    if (String.isNotBlank(filterType)) {
      countQuery += ' AND ActivityType__c = :filterType';
    }
    Integer totalMatching = Database.countQuery(countQuery);

    String query =
      'SELECT Id, Name, ActivityType__c, Action__c, ActorName__c, ActorWorker__c, ' +
      'ActorWorker__r.LastName__c, ActorWorker__r.FirstName__c, ' +
      'RelatedRecordId__c, RelatedRecordName__c, Description__c, StarCount__c, ' +
      'CreatedDate ' +
      'FROM JIP_ProjectActivity__c ' +
      'WHERE Project__c = :selectedProjectId';

    if (String.isNotBlank(filterType)) {
      query += ' AND ActivityType__c = :filterType';
    }

    query += ' ORDER BY CreatedDate DESC LIMIT ' + String.valueOf(displayLimit);

    List<JIP_ProjectActivity__c> records = Database.query(query);
    activities = new List<ActivityWrapper>();
    for (JIP_ProjectActivity__c rec : records) {
      activities.add(new ActivityWrapper(rec, project));
    }
    totalCount = activities.size();
    hasMore = totalMatching > displayLimit;
    remainingCount = totalMatching - displayLimit;
    if (remainingCount < 0)
      remainingCount = 0;
  }

  public void checkNewActivities() {
    if (selectedProjectId == null) {
      newCount = 0;
      return;
    }
    if (String.isBlank(lastSeenTime)) {
      lastSeenTime = Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
      newCount = 0;
      return;
    }
    Datetime sinceTime = Datetime.valueOf(lastSeenTime.replace('T', ' '));
    newCount = [
      SELECT COUNT()
      FROM JIP_ProjectActivity__c
      WHERE Project__c = :selectedProjectId AND CreatedDate > :sinceTime
    ];
  }

  public void markSeen() {
    lastSeenTime = Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
    newCount = 0;
  }

  // ===== JavaScript Remoting (stateless, no form needed) =====
  @RemoteAction
  public static Map<String, Object> checkNewRemote(
    String projectId,
    String lastSeenTimeStr
  ) {
    Map<String, Object> result = new Map<String, Object>();
    if (String.isBlank(projectId)) {
      result.put('newCount', 0);
      result.put('lastSeenTime', '');
      return result;
    }
    String seenTime;
    if (String.isBlank(lastSeenTimeStr)) {
      seenTime = Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
      result.put('newCount', 0);
      result.put('lastSeenTime', seenTime);
      return result;
    }
    seenTime = lastSeenTimeStr;
    Datetime sinceTime = Datetime.valueOf(lastSeenTimeStr.replace('T', ' '));
    Integer cnt = [
      SELECT COUNT()
      FROM JIP_ProjectActivity__c
      WHERE Project__c = :projectId AND CreatedDate > :sinceTime
    ];
    result.put('newCount', cnt);
    result.put('lastSeenTime', seenTime);
    return result;
  }

  @RemoteAction
  public static String markSeenRemote() {
    return Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
  }

  public void applyFilter() {
    displayLimit = PAGE_SIZE;
    loadActivities();
  }

  public void loadMore() {
    displayLimit += PAGE_SIZE;
    loadActivities();
  }

  public List<SelectOption> getFilterOptions() {
    List<SelectOption> opts = new List<SelectOption>();
    opts.add(new SelectOption('', 'すべて'));
    opts.add(new SelectOption('課題', '課題'));
    opts.add(new SelectOption('ドキュメント', 'ドキュメント'));
    opts.add(new SelectOption('ファイル', 'ファイル'));
    opts.add(new SelectOption('Wiki', 'Wiki'));
    opts.add(new SelectOption('コメント', 'コメント'));
    opts.add(new SelectOption('メンバー', 'メンバー'));
    return opts;
  }

  // ===== Wrapper Class =====
  public class ActivityWrapper {
    public JIP_ProjectActivity__c record { get; set; }
    public String actorDisplayName { get; set; }
    public String dateGroup { get; set; }
    public String timeAgo { get; set; }
    public String badgeClass { get; set; }
    public String avatarInitial { get; set; }
    public String avatarClass { get; set; }
    public String projectDisplay { get; set; }
    public String descriptionPreview { get; set; }
    public Boolean hasMoreDescription { get; set; }

    public ActivityWrapper(JIP_ProjectActivity__c rec, JIP_Project__c proj) {
      this.record = rec;
      this.actorDisplayName = resolveActorDisplayName(rec);

      if (rec.CreatedDate != null) {
        this.dateGroup = formatDateGroup(rec.CreatedDate);
        this.timeAgo = formatTimeAgo(rec.CreatedDate);
      } else {
        this.dateGroup = '';
        this.timeAgo = '';
      }

      if (rec.ActivityType__c == '課題') {
        this.badgeClass = 'badge-orange';
      } else if (rec.ActivityType__c == 'ドキュメント') {
        this.badgeClass = 'badge-orange';
      } else if (rec.ActivityType__c == 'ファイル') {
        this.badgeClass = 'badge-blue';
      } else if (rec.ActivityType__c == 'Wiki') {
        this.badgeClass = 'badge-green';
      } else if (rec.ActivityType__c == 'コメント') {
        this.badgeClass = 'badge-gray';
      } else {
        this.badgeClass = 'badge-gray';
      }

      if (String.isNotBlank(this.actorDisplayName)) {
        this.avatarInitial = this.actorDisplayName.substring(0, 1)
          .toUpperCase();
      } else {
        this.avatarInitial = '?';
      }
      Integer hashCode = rec.Id != null
        ? Math.abs(String.valueOf(rec.Id).hashCode())
        : 0;
      Integer colorIdx = Math.mod(hashCode, 3);
      if (colorIdx == 0)
        this.avatarClass = 'avatar-green';
      else if (colorIdx == 1)
        this.avatarClass = 'avatar-orange';
      else
        this.avatarClass = 'avatar-blue';

      if (proj != null) {
        String pName = proj.Name__c != null ? proj.Name__c : proj.Name;
        this.projectDisplay = pName + ' (' + proj.Name + ')';
      } else {
        this.projectDisplay = '';
      }

      if (String.isNotBlank(rec.Description__c)) {
        String plainText = rec.Description__c.stripHtmlTags();
        this.hasMoreDescription = plainText.length() > 120;
        this.descriptionPreview = this.hasMoreDescription
          ? plainText.substring(0, 120) + '...'
          : plainText;
      } else {
        this.descriptionPreview = '';
        this.hasMoreDescription = false;
      }
    }

    private String resolveActorDisplayName(JIP_ProjectActivity__c rec) {
      if (rec.ActorWorker__r != null) {
        List<String> nameParts = new List<String>();
        if (String.isNotBlank(rec.ActorWorker__r.LastName__c)) {
          nameParts.add(rec.ActorWorker__r.LastName__c);
        }
        if (String.isNotBlank(rec.ActorWorker__r.FirstName__c)) {
          nameParts.add(rec.ActorWorker__r.FirstName__c);
        }
        if (!nameParts.isEmpty()) {
          return String.join(nameParts, ' ');
        }
      }

      if (String.isNotBlank(rec.ActorName__c)) {
        return rec.ActorName__c;
      }

      return 'System';
    }

    private String formatDateGroup(Datetime dt) {
      Date d = dt.dateGmt();
      String[] dayNames = new List<String>{
        '日',
        '月',
        '火',
        '水',
        '木',
        '金',
        '土'
      };
      Date refDate = Date.newInstance(2026, 1, 4);
      Integer daysSinceRef = refDate.daysBetween(d);
      Integer dayOfWeek = Math.mod(Math.mod(daysSinceRef, 7) + 7, 7);
      return String.valueOf(d.year()) +
        '年' +
        String.valueOf(d.month()) +
        '月' +
        String.valueOf(d.day()) +
        '日(' +
        dayNames[dayOfWeek] +
        ')';
    }

    private String formatTimeAgo(Datetime dt) {
      Long nowMillis = Datetime.now().getTime();
      Long dtMillis = dt.getTime();
      Long diffMinutes = (nowMillis - dtMillis) / 60000;

      if (diffMinutes < 1)
        return 'たった今';
      if (diffMinutes < 60)
        return '約 ' + diffMinutes + ' 分前';
      Long diffHours = diffMinutes / 60;
      if (diffHours < 24)
        return '約 ' + diffHours + ' 時間前';
      Long diffDays = diffHours / 24;
      if (diffDays < 30)
        return '約 ' + diffDays + ' 日前';
      Long diffMonths = diffDays / 30;
      return '約 ' + diffMonths + ' ヶ月前';
    }
  }
}