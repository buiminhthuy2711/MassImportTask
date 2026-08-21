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
public with sharing class JIP_ProjectActivityHelper {
  private static Id currentWorkerId;

  // ===== JIP_ProjectTask__c =====
  public static void onTaskInsert(List<JIP_ProjectTask__c> newTasks) {
    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_ProjectTask__c t : newTasks) {
      if (t.Project__c == null)
        continue;
      String recordName = t.Name + ' ' + t.Subject__c;
      activities.add(
        createActivity(
          t.Project__c,
          '課題',
          '追加',
          resolveActorName(t.RegisteredBy__c),
          t.Id,
          recordName,
          t.Description__c
        )
      );
    }
    insertActivities(activities);
  }

  public static void onTaskUpdate(
    List<JIP_ProjectTask__c> newTasks,
    Map<Id, JIP_ProjectTask__c> oldMap
  ) {
    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_ProjectTask__c t : newTasks) {
      if (t.Project__c == null)
        continue;
      JIP_ProjectTask__c oldT = oldMap.get(t.Id);
      // Only log if meaningful fields changed
      if (
        t.Subject__c != oldT.Subject__c ||
        t.Status__c != oldT.Status__c ||
        t.Priority__c != oldT.Priority__c ||
        t.Assignee__c != oldT.Assignee__c ||
        t.Description__c != oldT.Description__c ||
        t.DueDate__c != oldT.DueDate__c ||
        t.StartDate__c != oldT.StartDate__c ||
        t.Category__c != oldT.Category__c
      ) {
        String descText = buildTaskChangeDescription(t, oldT);
        String recordName = t.Name + ' ' + t.Subject__c;
        activities.add(
          createActivity(
            t.Project__c,
            '課題',
            '更新',
            resolveCurrentUserName(),
            t.Id,
            recordName,
            descText
          )
        );
      }
    }
    insertActivities(activities);
  }

  public static void onTaskDelete(List<JIP_ProjectTask__c> oldTasks) {
    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_ProjectTask__c t : oldTasks) {
      if (t.Project__c == null)
        continue;
      String recordName = t.Name + ' ' + t.Subject__c;
      activities.add(
        createActivity(
          t.Project__c,
          '課題',
          '削除',
          resolveCurrentUserName(),
          null,
          recordName,
          null
        )
      );
    }
    insertActivities(activities);
  }

  // ===== JIP_TaskComment__c =====
  public static void onCommentInsert(List<JIP_TaskComment__c> newComments) {
    Set<Id> taskIds = new Set<Id>();
    for (JIP_TaskComment__c c : newComments) {
      if (c.ProjectTask__c != null)
        taskIds.add(c.ProjectTask__c);
    }
    if (taskIds.isEmpty())
      return;

    Map<Id, JIP_ProjectTask__c> taskMap = new Map<Id, JIP_ProjectTask__c>(
      [
        SELECT Id, Subject__c, Project__c
        FROM JIP_ProjectTask__c
        WHERE Id IN :taskIds
      ]
    );

    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_TaskComment__c c : newComments) {
      JIP_ProjectTask__c task = taskMap.get(c.ProjectTask__c);
      if (task == null || task.Project__c == null)
        continue;
      activities.add(
        createActivity(
          task.Project__c,
          'コメント',
          '追加',
          resolveActorName(c.CommentBy__c),
          task.Id,
          task.Subject__c,
          c.CommentBody__c
        )
      );
    }
    insertActivities(activities);
  }

  public static void onCommentUpdate(
    List<JIP_TaskComment__c> newComments,
    Map<Id, JIP_TaskComment__c> oldMap
  ) {
    Set<Id> taskIds = new Set<Id>();
    for (JIP_TaskComment__c c : newComments) {
      if (c.ProjectTask__c != null)
        taskIds.add(c.ProjectTask__c);
    }
    if (taskIds.isEmpty())
      return;

    Map<Id, JIP_ProjectTask__c> taskMap = new Map<Id, JIP_ProjectTask__c>(
      [
        SELECT Id, Subject__c, Project__c
        FROM JIP_ProjectTask__c
        WHERE Id IN :taskIds
      ]
    );

    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_TaskComment__c c : newComments) {
      JIP_TaskComment__c oldC = oldMap.get(c.Id);
      if (c.CommentBody__c == oldC.CommentBody__c)
        continue;
      JIP_ProjectTask__c task = taskMap.get(c.ProjectTask__c);
      if (task == null || task.Project__c == null)
        continue;
      activities.add(
        createActivity(
          task.Project__c,
          'コメント',
          '更新',
          resolveActorName(c.CommentBy__c),
          task.Id,
          task.Subject__c,
          c.CommentBody__c
        )
      );
    }
    insertActivities(activities);
  }

  public static void onCommentDelete(List<JIP_TaskComment__c> oldComments) {
    Set<Id> taskIds = new Set<Id>();
    for (JIP_TaskComment__c c : oldComments) {
      if (c.ProjectTask__c != null)
        taskIds.add(c.ProjectTask__c);
    }
    if (taskIds.isEmpty())
      return;

    Map<Id, JIP_ProjectTask__c> taskMap = new Map<Id, JIP_ProjectTask__c>(
      [
        SELECT Id, Subject__c, Project__c
        FROM JIP_ProjectTask__c
        WHERE Id IN :taskIds
      ]
    );

    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_TaskComment__c c : oldComments) {
      JIP_ProjectTask__c task = taskMap.get(c.ProjectTask__c);
      if (task == null || task.Project__c == null)
        continue;
      activities.add(
        createActivity(
          task.Project__c,
          'コメント',
          '削除',
          resolveActorName(c.CommentBy__c),
          task.Id,
          task.Subject__c,
          null
        )
      );
    }
    insertActivities(activities);
  }

  // ===== ProjectDocument__c =====
  public static void onDocumentInsert(List<JIP_ProjectDocument__c> newDocs) {
    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_ProjectDocument__c d : newDocs) {
      if (d.Project__c == null)
        continue;
      activities.add(
        createActivity(
          d.Project__c,
          'ドキュメント',
          '追加',
          resolveActorName(d.CreatedByName__c),
          d.Id,
          d.Title__c,
          d.Content__c
        )
      );
    }
    insertActivities(activities);
  }

  public static void onDocumentUpdate(
    List<JIP_ProjectDocument__c> newDocs,
    Map<Id, JIP_ProjectDocument__c> oldMap
  ) {
    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_ProjectDocument__c d : newDocs) {
      if (d.Project__c == null)
        continue;
      JIP_ProjectDocument__c oldD = oldMap.get(d.Id);
      if (d.Title__c != oldD.Title__c || d.Content__c != oldD.Content__c) {
        activities.add(
          createActivity(
            d.Project__c,
            'ドキュメント',
            '更新',
            resolveActorName(d.CreatedByName__c),
            d.Id,
            d.Title__c,
            d.Content__c
          )
        );
      }
    }
    insertActivities(activities);
  }

  public static void onDocumentDelete(List<JIP_ProjectDocument__c> oldDocs) {
    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_ProjectDocument__c d : oldDocs) {
      if (d.Project__c == null)
        continue;
      activities.add(
        createActivity(
          d.Project__c,
          'ドキュメント',
          '削除',
          resolveActorName(d.CreatedByName__c),
          null,
          d.Title__c,
          null
        )
      );
    }
    insertActivities(activities);
  }

  // ===== JIP_ProjectFile__c =====
  public static void onFileInsert(List<JIP_ProjectFile__c> newFiles) {
    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_ProjectFile__c f : newFiles) {
      if (f.Project__c == null)
        continue;
      String descText = f.FileName__c;
      if (f.FileSize__c != null) {
        descText += ' (' + formatFileSize(f.FileSize__c) + ')';
      }
      activities.add(
        createActivity(
          f.Project__c,
          'ファイル',
          '追加',
          resolveActorName(f.UploadedBy__c),
          f.Id,
          f.FileName__c,
          descText
        )
      );
    }
    insertActivities(activities);
  }

  public static void onFileUpdate(
    List<JIP_ProjectFile__c> newFiles,
    Map<Id, JIP_ProjectFile__c> oldMap
  ) {
    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_ProjectFile__c f : newFiles) {
      if (f.Project__c == null)
        continue;
      JIP_ProjectFile__c oldF = oldMap.get(f.Id);
      if (f.FileName__c != oldF.FileName__c) {
        activities.add(
          createActivity(
            f.Project__c,
            'ファイル',
            '更新',
            resolveActorName(f.UploadedBy__c),
            f.Id,
            f.FileName__c,
            null
          )
        );
      }
    }
    insertActivities(activities);
  }

  public static void onFileDelete(List<JIP_ProjectFile__c> oldFiles) {
    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_ProjectFile__c f : oldFiles) {
      if (f.Project__c == null)
        continue;
      activities.add(
        createActivity(
          f.Project__c,
          'ファイル',
          '削除',
          resolveActorName(f.UploadedBy__c),
          null,
          f.FileName__c,
          null
        )
      );
    }
    insertActivities(activities);
  }

  // ===== JIP_ProjectMember__c =====
  public static void onMemberInsert(List<JIP_ProjectMember__c> newMembers) {
    Set<Id> workerIds = new Set<Id>();
    for (JIP_ProjectMember__c m : newMembers) {
      if (m.Worker__c != null)
        workerIds.add(m.Worker__c);
    }
    Map<Id, JIP_Worker__c> workerMap = workerIds.isEmpty()
      ? new Map<Id, JIP_Worker__c>()
      : new Map<Id, JIP_Worker__c>(
          [
            SELECT Id, LastName__c, FirstName__c
            FROM JIP_Worker__c
            WHERE Id IN :workerIds
          ]
        );

    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_ProjectMember__c m : newMembers) {
      if (m.Project__c == null)
        continue;
      String workerName = getWorkerName(workerMap.get(m.Worker__c));
      activities.add(
        createActivity(
          m.Project__c,
          'メンバー',
          '追加',
          resolveCurrentUserName(),
          m.Id,
          workerName + ' (' + m.Role__c + ')',
          null
        )
      );
    }
    insertActivities(activities);
  }

  public static void onMemberDelete(List<JIP_ProjectMember__c> oldMembers) {
    Set<Id> workerIds = new Set<Id>();
    for (JIP_ProjectMember__c m : oldMembers) {
      if (m.Worker__c != null)
        workerIds.add(m.Worker__c);
    }
    Map<Id, JIP_Worker__c> workerMap = workerIds.isEmpty()
      ? new Map<Id, JIP_Worker__c>()
      : new Map<Id, JIP_Worker__c>(
          [
            SELECT Id, LastName__c, FirstName__c
            FROM JIP_Worker__c
            WHERE Id IN :workerIds
          ]
        );

    List<JIP_ProjectActivity__c> activities = new List<JIP_ProjectActivity__c>();
    for (JIP_ProjectMember__c m : oldMembers) {
      if (m.Project__c == null)
        continue;
      String workerName = getWorkerName(workerMap.get(m.Worker__c));
      activities.add(
        createActivity(
          m.Project__c,
          'メンバー',
          '削除',
          resolveCurrentUserName(),
          null,
          workerName,
          null
        )
      );
    }
    insertActivities(activities);
  }

  // ===== Helper Methods =====
  private static JIP_ProjectActivity__c createActivity(
    Id projectId,
    String activityType,
    String action,
    String actorName,
    Id relatedRecordId,
    String relatedRecordName,
    String description
  ) {
    String safeDesc = description;
    if (String.isNotBlank(safeDesc) && safeDesc.length() > 32768) {
      safeDesc = safeDesc.substring(0, 32765) + '...';
    }
    return new JIP_ProjectActivity__c(
      Project__c = projectId,
      ActivityType__c = activityType,
      Action__c = action,
      ActorName__c = actorName,
      ActorWorker__c = resolveCurrentWorkerId(),
      RelatedRecordId__c = relatedRecordId != null
        ? String.valueOf(relatedRecordId)
        : null,
      RelatedRecordName__c = relatedRecordName,
      Description__c = safeDesc,
      StarCount__c = 0
    );
  }

  private static void insertActivities(
    List<JIP_ProjectActivity__c> activities
  ) {
    if (!activities.isEmpty()) {
      insert activities;
    }
  }

  private static String resolveActorName(String nameValue) {
    if (String.isNotBlank(nameValue)) {
      return nameValue;
    }
    return resolveCurrentUserName();
  }

  private static String resolveCurrentUserName() {
    return UserInfo.getName();
  }

  private static Id resolveCurrentWorkerId() {
    if (currentWorkerId != null) {
      return currentWorkerId;
    }

    List<JIP_Worker__c> workers = [
      SELECT Id
      FROM JIP_Worker__c
      WHERE User__c = :UserInfo.getUserId()
      LIMIT 1
    ];

    currentWorkerId = workers.isEmpty() ? null : workers[0].Id;
    return currentWorkerId;
  }

  private static String getWorkerName(JIP_Worker__c w) {
    if (w == null)
      return '不明';
    String name = '';
    if (w.LastName__c != null)
      name += w.LastName__c;
    if (w.FirstName__c != null)
      name += ' ' + w.FirstName__c;
    return String.isBlank(name.trim()) ? '不明' : name.trim();
  }

  private static String truncate(String text, Integer maxLen) {
    if (String.isBlank(text))
      return null;
    return text.length() > maxLen ? text.substring(0, maxLen) + '...' : text;
  }

  private static String formatFileSize(Decimal sizeBytes) {
    if (sizeBytes == null)
      return '';
    if (sizeBytes < 1024)
      return sizeBytes.setScale(0) + ' B';
    Decimal kb = sizeBytes / 1024;
    if (kb < 1024)
      return kb.setScale(1) + ' KB';
    Decimal mb = kb / 1024;
    return mb.setScale(1) + ' MB';
  }

  private static String buildTaskChangeDescription(
    JIP_ProjectTask__c newT,
    JIP_ProjectTask__c oldT
  ) {
    List<String> changes = new List<String>();
    if (newT.Status__c != oldT.Status__c) {
      changes.add(
        '状態: ' +
          (oldT.Status__c != null ? oldT.Status__c : '(空)') +
          ' → ' +
          (newT.Status__c != null ? newT.Status__c : '(空)')
      );
    }
    if (newT.Priority__c != oldT.Priority__c) {
      changes.add(
        '優先度: ' +
          (oldT.Priority__c != null ? oldT.Priority__c : '(空)') +
          ' → ' +
          (newT.Priority__c != null ? newT.Priority__c : '(空)')
      );
    }
    if (newT.Assignee__c != oldT.Assignee__c) {
      changes.add('担当者が変更されました');
    }
    if (newT.Subject__c != oldT.Subject__c) {
      changes.add(
        '件名: ' +
          (oldT.Subject__c != null ? oldT.Subject__c : '(空)') +
          ' → ' +
          (newT.Subject__c != null ? newT.Subject__c : '(空)')
      );
    }
    if (newT.Description__c != oldT.Description__c) {
      changes.add('詳細が変更されました');
      if (String.isNotBlank(newT.Description__c)) {
        changes.add(newT.Description__c);
      }
    }
    if (changes.isEmpty()) {
      changes.add('更新されました');
    }
    return String.join(changes, '<br/>');
  }
}