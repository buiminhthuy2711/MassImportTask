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
public with sharing class JIP_TranslationHelper {
  private static Map<String, Map<String, String>> translations = new Map<String, Map<String, String>>();

  static {
    // Initialize translations
    initTranslations();
  }

  private static void initTranslations() {
    // ===== COMMON =====
    addTranslation('save', 'ja', '保存');
    addTranslation('save', 'en', 'Save');
    addTranslation('cancel', 'ja', 'キャンセル');
    addTranslation('cancel', 'en', 'Cancel');
    addTranslation('edit', 'ja', '編集');
    addTranslation('edit', 'en', 'Edit');
    addTranslation('delete', 'ja', '削除');
    addTranslation('delete', 'en', 'Delete');
    addTranslation('search', 'ja', '検索');
    addTranslation('search', 'en', 'Search');
    addTranslation('add', 'ja', '追加');
    addTranslation('add', 'en', 'Add');
    addTranslation('close', 'ja', '閉じる');
    addTranslation('close', 'en', 'Close');
    addTranslation('back', 'ja', '戻る');
    addTranslation('back', 'en', 'Back');
    addTranslation('register', 'ja', '登録');
    addTranslation('register', 'en', 'Register');
    addTranslation('create', 'ja', '作成');
    addTranslation('create', 'en', 'Create');
    addTranslation('update', 'ja', '更新');
    addTranslation('update', 'en', 'Update');

    // ===== PROJECT SETTINGS =====
    addTranslation('project_settings', 'ja', 'プロジェクト設定');
    addTranslation('project_settings', 'en', 'Project Settings');
    addTranslation('basic_settings', 'ja', '基本設定');
    addTranslation('basic_settings', 'en', 'Basic Settings');
    addTranslation('participating_users', 'ja', '参加ユーザー');
    addTranslation('participating_users', 'en', 'Members');
    addTranslation('theme', 'ja', 'テーマ');
    addTranslation('theme', 'en', 'Theme');
    addTranslation('type', 'ja', '種別');
    addTranslation('type', 'en', 'Type');
    addTranslation('status', 'ja', '状態');
    addTranslation('status', 'en', 'Status');
    addTranslation('category', 'ja', 'カテゴリー');
    addTranslation('category', 'en', 'Category');
    addTranslation('milestone', 'ja', '発生バージョン/マイルストーン');
    addTranslation('milestone', 'en', 'Version/Milestone');
    addTranslation('custom_attributes', 'ja', 'カスタム属性');
    addTranslation('custom_attributes', 'en', 'Custom Attributes');
    addTranslation('integration', 'ja', 'インテグレーション');
    addTranslation('integration', 'en', 'Integration');

    // ===== MEMBER MANAGEMENT =====
    addTranslation('edit_participating_users', 'ja', '参加ユーザーの編集');
    addTranslation('edit_participating_users', 'en', 'Edit Members');
    addTranslation('add_to_project', 'ja', 'プロジェクトに追加する');
    addTranslation('add_to_project', 'en', 'Add to Project');
    addTranslation('add_message', 'ja', 'メッセージを追加');
    addTranslation('add_message', 'en', 'Add Message');
    addTranslation('add_new_user', 'ja', '新しいユーザーの追加はこちらから');
    addTranslation('add_new_user', 'en', 'Add new user here');
    addTranslation('project_admin_settings', 'ja', 'プロジェクト管理者の設定');
    addTranslation('project_admin_settings', 'en', 'Project Admin Settings');
    addTranslation('participating_teams', 'ja', '参加中のチーム');
    addTranslation('participating_teams', 'en', 'Participating Teams');
    addTranslation('participating_users_count', 'ja', '参加中のユーザー');
    addTranslation('participating_users_count', 'en', 'Participating Users');
    addTranslation('filter_users', 'ja', 'ユーザーの絞り込み');
    addTranslation('filter_users', 'en', 'Filter Users');
    addTranslation(
      'filter_placeholder',
      'ja',
      'ユーザーID・ハンドルネーム・メールアドレスからキーワードで検索'
    );
    addTranslation(
      'filter_placeholder',
      'en',
      'Search by User ID, Handle Name, or Email'
    );
    addTranslation('handle_name', 'ja', 'ハンドルネーム');
    addTranslation('handle_name', 'en', 'Handle Name');
    addTranslation('email', 'ja', 'メールアドレス');
    addTranslation('email', 'en', 'Email');
    addTranslation('permission', 'ja', '権限');
    addTranslation('permission', 'en', 'Permission');
    addTranslation('registration_date', 'ja', '登録日');
    addTranslation('registration_date', 'en', 'Registered');
    addTranslation('actions', 'ja', '操作');
    addTranslation('actions', 'en', 'Actions');
    addTranslation('teams', 'ja', 'チーム');
    addTranslation('teams', 'en', 'teams');
    addTranslation('users', 'ja', '名');
    addTranslation('users', 'en', 'users');
    addTranslation('display_range', 'ja', '全 {0} 件中 {1} 件～{2} 件を表示');
    addTranslation('display_range', 'en', 'Showing {1} to {2} of {0} items');

    // ===== ROLES =====
    addTranslation('role_admin', 'ja', '管理者');
    addTranslation('role_admin', 'en', 'Admin');
    addTranslation('role_member', 'ja', 'メンバー');
    addTranslation('role_member', 'en', 'Member');
    addTranslation('role_viewer', 'ja', '閲覧者');
    addTranslation('role_viewer', 'en', 'Viewer');
    addTranslation('all_roles', 'ja', 'すべての権限');
    addTranslation('all_roles', 'en', 'All Roles');

    // ===== SIDEBAR =====
    addTranslation('home', 'ja', 'ホーム');
    addTranslation('home', 'en', 'Home');
    addTranslation('project_home', 'ja', 'プロジェクトホーム');
    addTranslation('project_home', 'en', 'Project Home');
    addTranslation('display_settings', 'ja', '表示設定');
    addTranslation('display_settings', 'en', 'Display Settings');
    addTranslation('dashboard', 'ja', 'ダッシュボード');
    addTranslation('dashboard', 'en', 'Dashboard');
    addTranslation('task_list', 'ja', '課題');
    addTranslation('task_list', 'en', 'Tasks');
    addTranslation('board', 'ja', 'ボード');
    addTranslation('board', 'en', 'Board');
    addTranslation('gantt', 'ja', 'ガント');
    addTranslation('gantt', 'en', 'Gantt');
    addTranslation('files', 'ja', 'ファイル');
    addTranslation('files', 'en', 'Files');
    addTranslation('document', 'ja', 'ドキュメント');
    addTranslation('document', 'en', 'Documents');
    addTranslation('wiki', 'ja', 'Wiki');
    addTranslation('wiki', 'en', 'Wiki');
    addTranslation('settings', 'ja', '設定');
    addTranslation('settings', 'en', 'Settings');
    addTranslation('add_task', 'ja', '課題の追加');
    addTranslation('add_task', 'en', 'Add Task');

    // ===== TASK DETAIL =====
    addTranslation('task_detail', 'ja', '課題詳細');
    addTranslation('task_detail', 'en', 'Task Detail');
    addTranslation('subject', 'ja', '件名');
    addTranslation('subject', 'en', 'Subject');
    addTranslation('description', 'ja', '詳細');
    addTranslation('description', 'en', 'Description');
    addTranslation('assignee', 'ja', '担当者');
    addTranslation('assignee', 'en', 'Assignee');
    addTranslation('start_date', 'ja', '開始日');
    addTranslation('start_date', 'en', 'Start Date');
    addTranslation('due_date', 'ja', '期限日');
    addTranslation('due_date', 'en', 'Due Date');
    addTranslation('priority', 'ja', '優先度');
    addTranslation('priority', 'en', 'Priority');
    addTranslation('estimated_hours', 'ja', '予定時間');
    addTranslation('estimated_hours', 'en', 'Estimated Hours');
    addTranslation('actual_hours', 'ja', '実績時間');
    addTranslation('actual_hours', 'en', 'Actual Hours');
    addTranslation('registered_by', 'ja', '登録者');
    addTranslation('registered_by', 'en', 'Registered By');
    addTranslation('comments', 'ja', 'コメント');
    addTranslation('comments', 'en', 'Comments');
    addTranslation('add_comment', 'ja', 'コメントを追加');
    addTranslation('add_comment', 'en', 'Add Comment');
    addTranslation('notify_users', 'ja', 'コメントをお知らせしたいユーザー');
    addTranslation('notify_users', 'en', 'Notify users about this comment');
    addTranslation('enter_username', 'ja', 'ユーザー名を入力...');
    addTranslation('enter_username', 'en', 'Enter username...');
    addTranslation('notified_to', 'ja', '通知先');
    addTranslation('notified_to', 'en', 'Notified to');

    // ===== STATUS =====
    addTranslation('status_not_started', 'ja', '未対応');
    addTranslation('status_not_started', 'en', 'Not Started');
    addTranslation('status_in_progress', 'ja', '処理中');
    addTranslation('status_in_progress', 'en', 'In Progress');
    addTranslation('status_resolved', 'ja', '処理済み');
    addTranslation('status_resolved', 'en', 'Resolved');
    addTranslation('status_closed', 'ja', '完了');
    addTranslation('status_closed', 'en', 'Closed');
    addTranslation('set_in_progress', 'ja', '処理中に設定');
    addTranslation('set_in_progress', 'en', 'Set In Progress');
    addTranslation('set_resolved', 'ja', '処理済みに設定');
    addTranslation('set_resolved', 'en', 'Set Resolved');
    addTranslation('assign_to_me', 'ja', '私が担当');
    addTranslation('assign_to_me', 'en', 'Assign to Me');

    // ===== PRIORITY =====
    addTranslation('priority_high', 'ja', '高');
    addTranslation('priority_high', 'en', 'High');
    addTranslation('priority_medium', 'ja', '中');
    addTranslation('priority_medium', 'en', 'Medium');
    addTranslation('priority_low', 'ja', '低');
    addTranslation('priority_low', 'en', 'Low');

    // ===== DASHBOARD =====
    addTranslation('progress_status', 'ja', '進捗状況');
    addTranslation('progress_status', 'en', 'Progress Status');
    addTranslation('task_by_assignee', 'ja', '担当者別課題');
    addTranslation('task_by_assignee', 'en', 'Tasks by Assignee');
    addTranslation('overdue_tasks', 'ja', '期限切れ課題');
    addTranslation('overdue_tasks', 'en', 'Overdue Tasks');
    addTranslation('recent_activities', 'ja', '最近のアクティビティ');
    addTranslation('recent_activities', 'en', 'Recent Activities');

    // ===== FILE MANAGEMENT =====
    addTranslation('files_documents', 'ja', 'ファイル / ドキュメント');
    addTranslation('files_documents', 'en', 'Files / Documents');
    addTranslation('upload_file', 'ja', 'ファイルをアップロード');
    addTranslation('upload_file', 'en', 'Upload File');
    addTranslation('file_name', 'ja', 'ファイル名');
    addTranslation('file_name', 'en', 'File Name');
    addTranslation('file_size', 'ja', 'サイズ');
    addTranslation('file_size', 'en', 'Size');
    addTranslation('uploaded_by', 'ja', 'アップロードユーザー');
    addTranslation('uploaded_by', 'en', 'Uploaded By');
    addTranslation('uploaded_date', 'ja', 'アップロード日');
    addTranslation('uploaded_date', 'en', 'Upload Date');
    addTranslation('download', 'ja', 'ダウンロード');
    addTranslation('download', 'en', 'Download');

    // ===== PLACEHOLDERS =====
    addTranslation(
      'basic_settings_placeholder',
      'ja',
      '基本設定の内容はこちらに表示されます。'
    );
    addTranslation(
      'basic_settings_placeholder',
      'en',
      'Basic settings content will be displayed here.'
    );
    addTranslation(
      'theme_placeholder',
      'ja',
      'テーマ設定の内容はこちらに表示されます。'
    );
    addTranslation(
      'theme_placeholder',
      'en',
      'Theme settings content will be displayed here.'
    );
    addTranslation(
      'type_placeholder',
      'ja',
      '種別設定の内容はこちらに表示されます。'
    );
    addTranslation(
      'type_placeholder',
      'en',
      'Type settings content will be displayed here.'
    );
    addTranslation(
      'status_placeholder',
      'ja',
      '状態設定の内容はこちらに表示されます。'
    );
    addTranslation(
      'status_placeholder',
      'en',
      'Status settings content will be displayed here.'
    );
    addTranslation(
      'category_placeholder',
      'ja',
      'カテゴリー設定の内容はこちらに表示されます。'
    );
    addTranslation(
      'category_placeholder',
      'en',
      'Category settings content will be displayed here.'
    );
    addTranslation(
      'milestone_placeholder',
      'ja',
      'マイルストーン設定の内容はこちらに表示されます。'
    );
    addTranslation(
      'milestone_placeholder',
      'en',
      'Milestone settings content will be displayed here.'
    );
    addTranslation(
      'custom_placeholder',
      'ja',
      'カスタム属性設定の内容はこちらに表示されます。'
    );
    addTranslation(
      'custom_placeholder',
      'en',
      'Custom attribute settings content will be displayed here.'
    );
    addTranslation(
      'integration_placeholder',
      'ja',
      'インテグレーション設定の内容はこちらに表示されます。'
    );
    addTranslation(
      'integration_placeholder',
      'en',
      'Integration settings content will be displayed here.'
    );

    // ===== MESSAGES =====
    addTranslation('msg_member_added', 'ja', 'メンバーを追加しました。');
    addTranslation('msg_member_added', 'en', 'Member added successfully.');
    addTranslation('msg_member_removed', 'ja', 'メンバーを削除しました。');
    addTranslation('msg_member_removed', 'en', 'Member removed successfully.');
    addTranslation('msg_role_updated', 'ja', '権限を更新しました。');
    addTranslation('msg_role_updated', 'en', 'Role updated successfully.');
    addTranslation('msg_save_success', 'ja', '保存しました。');
    addTranslation('msg_save_success', 'en', 'Saved successfully.');
    addTranslation('msg_error', 'ja', 'エラーが発生しました。');
    addTranslation('msg_error', 'en', 'An error occurred.');
    addTranslation('msg_comment_added', 'ja', 'コメントを登録しました。');
    addTranslation('msg_comment_added', 'en', 'Comment added successfully.');
    addTranslation('msg_comment_updated', 'ja', 'コメントを更新しました。');
    addTranslation(
      'msg_comment_updated',
      'en',
      'Comment updated successfully.'
    );

    // ===== LANGUAGE =====
    addTranslation('language', 'ja', '言語');
    addTranslation('language', 'en', 'Language');
    addTranslation('japanese', 'ja', '日本語');
    addTranslation('japanese', 'en', 'Japanese');
    addTranslation('english', 'ja', '英語');
    addTranslation('english', 'en', 'English');
    addTranslation('save_language', 'ja', '言語を保存');
    addTranslation('save_language', 'en', 'Save Language');

    // ===== BOARD PAGE =====
    addTranslation('hide_filter', 'ja', 'フィルタを隠す');
    addTranslation('hide_filter', 'en', 'Hide Filters');
    addTranslation('show_filter', 'ja', 'フィルタを表示');
    addTranslation('show_filter', 'en', 'Show Filters');
    addTranslation('clear', 'ja', 'クリア');
    addTranslation('clear', 'en', 'Clear');

    // ===== GANTT PAGE =====
    addTranslation('gantt_chart', 'ja', 'ガントチャート');
    addTranslation('gantt_chart', 'en', 'Gantt Chart');
    addTranslation('scale', 'ja', '表示単位');
    addTranslation('scale', 'en', 'Scale');
    addTranslation('day', 'ja', '日');
    addTranslation('day', 'en', 'Day');
    addTranslation('week', 'ja', '週');
    addTranslation('week', 'en', 'Week');
    addTranslation('month', 'ja', '月');
    addTranslation('month', 'en', 'Month');
    addTranslation('grouping', 'ja', 'グループ化');
    addTranslation('grouping', 'en', 'Grouping');
    addTranslation('none', 'ja', 'なし');
    addTranslation('none', 'en', 'None');
    addTranslation('today', 'ja', '今日');
    addTranslation('today', 'en', 'Today');
    addTranslation('collapse', 'ja', '折りたたむ');
    addTranslation('collapse', 'en', 'Collapse');
    addTranslation('expand', 'ja', '展開');
    addTranslation('expand', 'en', 'Expand');

    // ===== DOCUMENT PAGE =====
    addTranslation('search_document', 'ja', 'ドキュメントを検索');
    addTranslation('search_document', 'en', 'Search documents');
    addTranslation('add_document', 'ja', 'ドキュメントを追加');
    addTranslation('add_document', 'en', 'Add Document');
    addTranslation('trash', 'ja', 'ゴミ箱');
    addTranslation('trash', 'en', 'Trash');
    addTranslation('table_of_contents', 'ja', '目次');
    addTranslation('table_of_contents', 'en', 'Table of Contents');
    addTranslation('created_date', 'ja', '作成日');
    addTranslation('created_date', 'en', 'Created Date');
    addTranslation('updated_date', 'ja', '更新日');
    addTranslation('updated_date', 'en', 'Updated Date');
    addTranslation('no_document', 'ja', 'ドキュメントがありません');
    addTranslation('no_document', 'en', 'No documents');
    addTranslation('create_first_document', 'ja', '最初のドキュメントを作成');
    addTranslation('create_first_document', 'en', 'Create First Document');
    addTranslation('move_to_trash', 'ja', 'ゴミ箱に移動');
    addTranslation('move_to_trash', 'en', 'Move to Trash');
    addTranslation('restore', 'ja', '元に戻す');
    addTranslation('restore', 'en', 'Restore');
    addTranslation('delete_permanently', 'ja', '完全に削除');
    addTranslation('delete_permanently', 'en', 'Delete Permanently');
    addTranslation('document_name', 'ja', 'ドキュメント名');
    addTranslation('document_name', 'en', 'Document Name');
    addTranslation('deleted_date', 'ja', '削除日');
    addTranslation('deleted_date', 'en', 'Deleted Date');
    addTranslation(
      'confirm_delete',
      'ja',
      '完全に削除しますか？この操作は元に戻せません。'
    );
    addTranslation(
      'confirm_delete',
      'en',
      'Delete permanently? This action cannot be undone.'
    );
    addTranslation(
      'confirm_move_to_trash',
      'ja',
      'このドキュメントをゴミ箱に移動しますか？'
    );
    addTranslation(
      'confirm_move_to_trash',
      'en',
      'Move this document to trash?'
    );
    addTranslation('untitled', 'ja', '無題');
    addTranslation('untitled', 'en', 'Untitled');

    // ===== FILE PAGE =====
    addTranslation('file_management', 'ja', 'ファイル管理');
    addTranslation('file_management', 'en', 'File Management');
    addTranslation('search_placeholder', 'ja', 'ファイル名で検索...');
    addTranslation('search_placeholder', 'en', 'Search by file name...');
    addTranslation('new_folder', 'ja', '新規フォルダ');
    addTranslation('new_folder', 'en', 'New Folder');
    addTranslation('root', 'ja', 'ルート');
    addTranslation('root', 'en', 'Root');
    addTranslation('root_folder', 'ja', 'ルート（最上位）');
    addTranslation('root_folder', 'en', 'Root (Top Level)');
    addTranslation('folder_name', 'ja', 'フォルダ名');
    addTranslation('folder_name', 'en', 'Folder Name');
    addTranslation('rename', 'ja', '名前変更');
    addTranslation('rename', 'en', 'Rename');
    addTranslation('move', 'ja', '移動');
    addTranslation('move', 'en', 'Move');
    addTranslation('move_to', 'ja', '移動先');
    addTranslation('move_to', 'en', 'Move To');
    addTranslation('new_name', 'ja', '新しい名前');
    addTranslation('new_name', 'en', 'New Name');
    addTranslation('no_files', 'ja', 'ファイルがありません');
    addTranslation('no_files', 'en', 'No files');
    addTranslation('no_search_results', 'ja', '検索結果はありません。');
    addTranslation('no_search_results', 'en', 'No search results.');
    addTranslation(
      'folder_empty',
      'ja',
      'このフォルダにはファイルがありません。'
    );
    addTranslation('folder_empty', 'en', 'This folder is empty.');
    addTranslation(
      'folder_empty_hint',
      'ja',
      'フォルダを作成するか、ファイルをアップロードしてください。'
    );
    addTranslation(
      'folder_empty_hint',
      'en',
      'Create a folder or upload files.'
    );
    addTranslation('name', 'ja', '名前');
    addTranslation('name', 'en', 'Name');
    addTranslation('location', 'ja', '場所');
    addTranslation('location', 'en', 'Location');
    addTranslation('size', 'ja', 'サイズ');
    addTranslation('size', 'en', 'Size');
    addTranslation('file_type', 'ja', '種類');
    addTranslation('file_type', 'en', 'Type');
    addTranslation('uploader', 'ja', 'アップロード者');
    addTranslation('uploader', 'en', 'Uploader');
    addTranslation('confirm_delete_file', 'ja', 'を削除しますか？');
    addTranslation('confirm_delete_file', 'en', 'Delete this item?');
    addTranslation('search_results', 'ja', 'の検索結果');
    addTranslation('search_results', 'en', 'search results');
    addTranslation('items', 'ja', '件');
    addTranslation('items', 'en', 'items');
    addTranslation('drop_files_here', 'ja', 'ファイルをドラッグ＆ドロップ');
    addTranslation('drop_files_here', 'en', 'Drag & drop files here');
    addTranslation('folder', 'ja', 'フォルダ');
    addTranslation('folder', 'en', 'Folder');
    addTranslation('download', 'ja', 'ダウンロード');
    addTranslation('download', 'en', 'Download');
    addTranslation('enter_new_name', 'ja', '新しい名前を入力...');
    addTranslation('enter_new_name', 'en', 'Enter new name...');
    addTranslation('select_destination', 'ja', '移動先フォルダ選択');
    addTranslation('select_destination', 'en', 'Select Destination Folder');
    addTranslation('change', 'ja', '変更');
    addTranslation('change', 'en', 'Change');
    addTranslation('create_folder', 'ja', '新規フォルダ作成');
    addTranslation('create_folder', 'en', 'Create New Folder');
    addTranslation('enter_folder_name', 'ja', 'フォルダ名を入力...');
    addTranslation('enter_folder_name', 'en', 'Enter folder name...');

    // ===== TASK LIST PAGE =====
    addTranslation('all', 'ja', 'すべて');
    addTranslation('all', 'en', 'All');
    addTranslation('status_not_closed', 'ja', '完了以外');
    addTranslation('status_not_closed', 'en', 'Not Closed');
    addTranslation('keyword', 'ja', 'キーワード');
    addTranslation('keyword', 'en', 'Keyword');
    addTranslation('keyword_placeholder', 'ja', 'キーワードを入力');
    addTranslation('keyword_placeholder', 'en', 'Enter keyword');
    addTranslation('milestone_placeholder', 'ja', 'マイルストーン');
    addTranslation('milestone_placeholder', 'en', 'Milestone');
    addTranslation('showing_x_of_y', 'ja', '全 {0} 件中 {1} 件を表示');
    addTranslation('showing_x_of_y', 'en', 'Showing {1} of {0} items');
    addTranslation('key', 'ja', 'キー');
    addTranslation('key', 'en', 'Key');
    addTranslation('actions', 'ja', '操作');
    addTranslation('actions', 'en', 'Actions');
    addTranslation('confirm_delete_task', 'ja', 'この課題を削除しますか？');
    addTranslation('confirm_delete_task', 'en', 'Delete this task?');
    addTranslation('no_tasks', 'ja', '課題がありません');
    addTranslation('no_tasks', 'en', 'No tasks');
    addTranslation(
      'no_tasks_hint',
      'ja',
      '「+ 課題の追加」ボタンから新しい課題を登録してください。'
    );
    addTranslation(
      'no_tasks_hint',
      'en',
      'Click "+ Add Task" button to create a new task.'
    );
    addTranslation('select_project', 'ja', 'プロジェクトを選択してください');
    addTranslation('select_project', 'en', 'Please select a project');
    addTranslation('task_updated', 'ja', '課題を更新しました');
    addTranslation('task_updated', 'en', 'Task updated');
    addTranslation('task_created', 'ja', '課題を登録しました');
    addTranslation('task_created', 'en', 'Task created');
    addTranslation('task_deleted', 'ja', '課題を削除しました');
    addTranslation('task_deleted', 'en', 'Task deleted');

    // Column selector translations
    addTranslation('columns', 'ja', '表示列');
    addTranslation('columns', 'en', 'Columns');
    addTranslation('select_columns', 'ja', '表示する列を選択');
    addTranslation('select_columns', 'en', 'Select columns to display');
    addTranslation('reset', 'ja', 'リセット');
    addTranslation('reset', 'en', 'Reset');
    addTranslation('done', 'ja', '完了');
    addTranslation('done', 'en', 'Done');

    // ===== HR SYSTEM - COMMON =====
    addTranslation('hr_system', 'ja', '社員管理システム');
    addTranslation('hr_system', 'en', 'HR Management System');
    addTranslation('employee', 'ja', '社員');
    addTranslation('employee', 'en', 'Employee');
    addTranslation('employees', 'ja', '社員');
    addTranslation('employees', 'en', 'Employees');
    addTranslation('department', 'ja', '部門');
    addTranslation('department', 'en', 'Department');
    addTranslation('position', 'ja', '役職');
    addTranslation('position', 'en', 'Position');
    addTranslation('hire_date', 'ja', '入社日');
    addTranslation('hire_date', 'en', 'Hire Date');
    addTranslation('new_registration', 'ja', '新規登録');
    addTranslation('new_registration', 'en', 'New Registration');
    addTranslation('export', 'ja', 'エクスポート');
    addTranslation('export', 'en', 'Export');
    addTranslation('import', 'ja', 'インポート');
    addTranslation('import', 'en', 'Import');
    addTranslation('filter', 'ja', 'フィルター');
    addTranslation('filter', 'en', 'Filter');
    addTranslation('total', 'ja', '合計');
    addTranslation('total', 'en', 'Total');
    addTranslation('active', 'ja', '在籍中');
    addTranslation('active', 'en', 'Active');
    addTranslation('on_leave', 'ja', '休職中');
    addTranslation('on_leave', 'en', 'On Leave');
    addTranslation('new_hire', 'ja', '新入社員');
    addTranslation('new_hire', 'en', 'New Hire');

    // ===== HR SIDEBAR MENU =====
    addTranslation('basic_info_mgmt', 'ja', '基本情報管理');
    addTranslation('basic_info_mgmt', 'en', 'Basic Info Management');
    addTranslation('org_auth_mgmt', 'ja', '組織・権限管理');
    addTranslation('org_auth_mgmt', 'en', 'Organization & Permissions');
    addTranslation('attendance_mgmt', 'ja', '勤怠管理');
    addTranslation('attendance_mgmt', 'en', 'Attendance Management');
    addTranslation('salary_eval_mgmt', 'ja', '給与・評価管理');
    addTranslation('salary_eval_mgmt', 'en', 'Salary & Evaluation');
    addTranslation('skill_career', 'ja', 'スキル・キャリア');
    addTranslation('skill_career', 'en', 'Skills & Career');
    addTranslation('workflow_request', 'ja', '申請・ワークフロー');
    addTranslation('workflow_request', 'en', 'Workflow & Requests');
    addTranslation('document_mgmt', 'ja', 'ドキュメント管理');
    addTranslation('document_mgmt', 'en', 'Document Management');
    addTranslation('report_analysis', 'ja', 'レポート・分析');
    addTranslation('report_analysis', 'en', 'Reports & Analytics');
    addTranslation('security_compliance', 'ja', 'セキュリティ');
    addTranslation('security_compliance', 'en', 'Security & Compliance');
    addTranslation('main_menu', 'ja', 'メインメニュー');
    addTranslation('main_menu', 'en', 'Main Menu');
    addTranslation('hr_operations', 'ja', '人事業務');
    addTranslation('hr_operations', 'en', 'HR Operations');
    addTranslation('docs_reports', 'ja', 'ドキュメント・レポート');
    addTranslation('docs_reports', 'en', 'Documents & Reports');
    addTranslation('system', 'ja', 'システム');
    addTranslation('system', 'en', 'System');

    // ===== ATTENDANCE PAGE =====
    addTranslation('attendance', 'ja', '勤怠');
    addTranslation('attendance', 'en', 'Attendance');
    addTranslation('check_in', 'ja', '出勤');
    addTranslation('check_in', 'en', 'Check In');
    addTranslation('check_out', 'ja', '退勤');
    addTranslation('check_out', 'en', 'Check Out');
    addTranslation('working', 'ja', '出勤中');
    addTranslation('working', 'en', 'Working');
    addTranslation('not_checked_in', 'ja', '未出勤');
    addTranslation('not_checked_in', 'en', 'Not Checked In');
    addTranslation('paid_leave', 'ja', '有給休暇');
    addTranslation('paid_leave', 'en', 'Paid Leave');
    addTranslation('late', 'ja', '遅刻');
    addTranslation('late', 'en', 'Late');
    addTranslation('overtime', 'ja', '残業');
    addTranslation('overtime', 'en', 'Overtime');
    addTranslation('overtime_hours', 'ja', '残業時間');
    addTranslation('overtime_hours', 'en', 'Overtime Hours');
    addTranslation('current_time', 'ja', '現在時刻');
    addTranslation('current_time', 'en', 'Current Time');
    addTranslation('punch_card', 'ja', '打刻カード');
    addTranslation('punch_card', 'en', 'Punch Card');
    addTranslation('today_attendance', 'ja', '本日の勤怠');
    addTranslation('today_attendance', 'en', 'Today\'s Attendance');
    addTranslation('attendance_list', 'ja', '勤怠一覧');
    addTranslation('attendance_list', 'en', 'Attendance List');
    addTranslation('leave_balance', 'ja', '休暇残高');
    addTranslation('leave_balance', 'en', 'Leave Balance');
    addTranslation('remaining_days', 'ja', '残日数');
    addTranslation('remaining_days', 'en', 'Remaining Days');
    addTranslation('used_days', 'ja', '使用日数');
    addTranslation('used_days', 'en', 'Used Days');
    addTranslation('quick_actions', 'ja', 'クイックアクション');
    addTranslation('quick_actions', 'en', 'Quick Actions');
    addTranslation('leave_request', 'ja', '休暇申請');
    addTranslation('leave_request', 'en', 'Leave Request');
    addTranslation('overtime_request', 'ja', '残業申請');
    addTranslation('overtime_request', 'en', 'Overtime Request');
    addTranslation('work_report', 'ja', '勤務表出力');
    addTranslation('work_report', 'en', 'Work Report');
    addTranslation('todays_attendance', 'ja', '本日の出勤状況');
    addTranslation('todays_attendance', 'en', 'Today\'s Attendance');
    addTranslation('late_arrival', 'ja', '遅刻');
    addTranslation('late_arrival', 'en', 'Late Arrival');
    addTranslation('monthly_overtime', 'ja', '月間残業');
    addTranslation('monthly_overtime', 'en', 'Monthly Overtime');
    addTranslation('days_suffix', 'ja', '日');
    addTranslation('days_suffix', 'en', ' days');
    addTranslation('attendance_correction', 'ja', '勤怠修正');
    addTranslation('attendance_correction', 'en', 'Attendance Correction');
    addTranslation('employee_name', 'ja', '社員名');
    addTranslation('employee_name', 'en', 'Employee Name');
    addTranslation('monthly_report', 'ja', '月次レポート');
    addTranslation('monthly_report', 'en', 'Monthly Report');
    addTranslation('working_hours', 'ja', '勤務時間');
    addTranslation('working_hours', 'en', 'Working Hours');

    // ===== ORGANIZATION PAGE =====
    addTranslation('organization', 'ja', '組織');
    addTranslation('organization', 'en', 'Organization');
    addTranslation('org_chart', 'ja', '組織図');
    addTranslation('org_chart', 'en', 'Organization Chart');
    addTranslation('department_list', 'ja', '部門一覧');
    addTranslation('department_list', 'en', 'Department List');
    addTranslation('role_permission', 'ja', '役割・権限');
    addTranslation('role_permission', 'en', 'Roles & Permissions');
    addTranslation('add_department', 'ja', '部門追加');
    addTranslation('add_department', 'en', 'Add Department');
    addTranslation('dept_code', 'ja', '部門コード');
    addTranslation('dept_code', 'en', 'Dept Code');
    addTranslation('dept_name', 'ja', '部門名');
    addTranslation('dept_name', 'en', 'Department Name');
    addTranslation('manager', 'ja', '責任者');
    addTranslation('manager', 'en', 'Manager');
    addTranslation('member_count', 'ja', '人数');
    addTranslation('member_count', 'en', 'Member Count');
    addTranslation('view_details', 'ja', '詳細を見る');
    addTranslation('view_details', 'en', 'View Details');

    // ===== SALARY PAGE =====
    addTranslation('salary', 'ja', '給与');
    addTranslation('salary', 'en', 'Salary');
    addTranslation('salary_mgmt', 'ja', '給与管理');
    addTranslation('salary_mgmt', 'en', 'Salary Management');
    addTranslation('evaluation_mgmt', 'ja', '評価管理');
    addTranslation('evaluation_mgmt', 'en', 'Evaluation Management');
    addTranslation('evaluation', 'ja', '評価');
    addTranslation('evaluation', 'en', 'Evaluation');
    addTranslation('kpi_mgmt', 'ja', 'KPI管理');
    addTranslation('kpi_mgmt', 'en', 'KPI Management');
    addTranslation('bonus', 'ja', '賞与');
    addTranslation('bonus', 'en', 'Bonus');
    addTranslation('base_salary', 'ja', '基本給');
    addTranslation('base_salary', 'en', 'Base Salary');
    addTranslation('allowances', 'ja', '手当');
    addTranslation('allowances', 'en', 'Allowances');
    addTranslation('deductions', 'ja', '控除');
    addTranslation('deductions', 'en', 'Deductions');
    addTranslation('net_salary', 'ja', '手取り額');
    addTranslation('net_salary', 'en', 'Net Salary');
    addTranslation('gross_salary', 'ja', '総支給額');
    addTranslation('gross_salary', 'en', 'Gross Salary');
    addTranslation('payslip', 'ja', '給与明細');
    addTranslation('payslip', 'en', 'Payslip');
    addTranslation('evaluation_period', 'ja', '評価期間');
    addTranslation('evaluation_period', 'en', 'Evaluation Period');
    addTranslation('self_evaluation', 'ja', '自己評価');
    addTranslation('self_evaluation', 'en', 'Self Evaluation');
    addTranslation('manager_evaluation', 'ja', '上司評価');
    addTranslation('manager_evaluation', 'en', 'Manager Evaluation');
    addTranslation('final_rating', 'ja', '最終評価');
    addTranslation('final_rating', 'en', 'Final Rating');

    // ===== SKILL PAGE =====
    addTranslation('skill', 'ja', 'スキル');
    addTranslation('skill', 'en', 'Skill');
    addTranslation('skills', 'ja', 'スキル一覧');
    addTranslation('skills', 'en', 'Skill List');
    addTranslation('tech_skills', 'ja', '技術スキル');
    addTranslation('tech_skills', 'en', 'Technical Skills');
    addTranslation('business_skills', 'ja', 'ビジネススキル');
    addTranslation('business_skills', 'en', 'Business Skills');
    addTranslation('certifications', 'ja', '資格・認定');
    addTranslation('certifications', 'en', 'Certifications');
    addTranslation('training_history', 'ja', '研修履歴');
    addTranslation('training_history', 'en', 'Training History');
    addTranslation('career_path', 'ja', 'キャリアパス');
    addTranslation('career_path', 'en', 'Career Path');
    addTranslation('skill_matrix', 'ja', 'スキルマトリックス');
    addTranslation('skill_matrix', 'en', 'Skill Matrix');
    addTranslation('training_program', 'ja', '研修プログラム');
    addTranslation('training_program', 'en', 'Training Program');
    addTranslation('soft_skills', 'ja', 'ソフトスキル');
    addTranslation('soft_skills', 'en', 'Soft Skills');
    addTranslation('management_skills', 'ja', 'マネジメントスキル');
    addTranslation('management_skills', 'en', 'Management Skills');
    addTranslation('language_skills', 'ja', '語学スキル');
    addTranslation('language_skills', 'en', 'Language Skills');
    addTranslation('beginner', 'ja', '初級');
    addTranslation('beginner', 'en', 'Beginner');
    addTranslation('intermediate', 'ja', '中級');
    addTranslation('intermediate', 'en', 'Intermediate');
    addTranslation('advanced', 'ja', '上級');
    addTranslation('advanced', 'en', 'Advanced');
    addTranslation('expert', 'ja', 'エキスパート');
    addTranslation('expert', 'en', 'Expert');
    addTranslation('add_skill', 'ja', 'スキル追加');
    addTranslation('add_skill', 'en', 'Add Skill');
    addTranslation('skill_search', 'ja', 'スキル検索');
    addTranslation('skill_search', 'en', 'Skill Search');
    addTranslation('skill_level', 'ja', 'スキルレベル');
    addTranslation('skill_level', 'en', 'Skill Level');
    addTranslation('cert_valid', 'ja', '有効');
    addTranslation('cert_valid', 'en', 'Valid');
    addTranslation('cert_expiring', 'ja', 'まもなく期限');
    addTranslation('cert_expiring', 'en', 'Expiring Soon');
    addTranslation('contract_expiring', 'ja', '契約期限');
    addTranslation('contract_expiring', 'en', 'Contract Expiring');
    addTranslation('termination', 'ja', '退職');
    addTranslation('termination', 'en', 'Termination');
    addTranslation('cert_expired', 'ja', '期限切れ');
    addTranslation('cert_expired', 'en', 'Expired');
    addTranslation('completed', 'ja', '完了');
    addTranslation('completed', 'en', 'Completed');
    addTranslation('in_progress', 'ja', '進行中');
    addTranslation('in_progress', 'en', 'In Progress');
    addTranslation('scheduled', 'ja', '予定');
    addTranslation('scheduled', 'en', 'Scheduled');
    addTranslation('edit_plan', 'ja', '計画編集');
    addTranslation('edit_plan', 'en', 'Edit Plan');
    addTranslation('current', 'ja', '現在');
    addTranslation('current', 'en', 'Current');
    addTranslation('target', 'ja', '目標');
    addTranslation('target', 'en', 'Target');

    // ===== WORKFLOW PAGE =====
    addTranslation('workflow', 'ja', 'ワークフロー');
    addTranslation('workflow', 'en', 'Workflow');
    addTranslation('pending_approval', 'ja', '承認待ち');
    addTranslation('pending_approval', 'en', 'Pending Approval');
    addTranslation('my_requests', 'ja', '自分の申請');
    addTranslation('my_requests', 'en', 'My Requests');
    addTranslation('remote_work', 'ja', '在宅勤務');
    addTranslation('remote_work', 'en', 'Remote Work');
    addTranslation('expense_request', 'ja', '経費申請');
    addTranslation('expense_request', 'en', 'Expense Request');
    addTranslation('approve', 'ja', '承認');
    addTranslation('approve', 'en', 'Approve');
    addTranslation('reject', 'ja', '却下');
    addTranslation('reject', 'en', 'Reject');
    addTranslation('new_request', 'ja', '新規申請');
    addTranslation('new_request', 'en', 'New Request');
    addTranslation('request_history', 'ja', '申請履歴');
    addTranslation('request_history', 'en', 'Request History');
    addTranslation('workflow_request_mgmt', 'ja', 'ワークフロー・申請管理');
    addTranslation(
      'workflow_request_mgmt',
      'en',
      'Workflow & Request Management'
    );
    addTranslation('batch_approve', 'ja', '一括承認');
    addTranslation('batch_approve', 'en', 'Batch Approve');
    addTranslation('processing', 'ja', '審査中');
    addTranslation('processing', 'en', 'Processing');
    addTranslation('approved', 'ja', '承認済み');
    addTranslation('approved', 'en', 'Approved');
    addTranslation('rejected', 'ja', '却下済み');
    addTranslation('rejected', 'en', 'Rejected');
    addTranslation('cancelled', 'ja', 'キャンセル済み');
    addTranslation('cancelled', 'en', 'Cancelled');
    addTranslation('select', 'ja', '選択');
    addTranslation('select', 'en', 'Select');
    addTranslation('sick_leave', 'ja', '病気休暇');
    addTranslation('sick_leave', 'en', 'Sick Leave');
    addTranslation('business_trip', 'ja', '出張');
    addTranslation('business_trip', 'en', 'Business Trip');
    addTranslation('expense_claim', 'ja', '経費精算');
    addTranslation('expense_claim', 'en', 'Expense Claim');
    addTranslation('equipment_request', 'ja', '機器申請');
    addTranslation('equipment_request', 'en', 'Equipment Request');
    addTranslation('action_required', 'ja', '要対応');
    addTranslation('action_required', 'en', 'Action Required');
    addTranslation('request_submitted', 'ja', '申請が送信されました');
    addTranslation('request_submitted', 'en', 'Request Submitted');
    addTranslation('this_month_completed', 'ja', '今月完了');
    addTranslation('this_month_completed', 'en', 'Completed This Month');
    addTranslation('avg_processing_time', 'ja', '平均処理時間');
    addTranslation('avg_processing_time', 'en', 'Avg Processing Time');
    addTranslation('approval_flow', 'ja', '承認フロー');
    addTranslation('approval_flow', 'en', 'Approval Flow');
    addTranslation('applicant', 'ja', '申請者');
    addTranslation('applicant', 'en', 'Applicant');
    addTranslation('approver', 'ja', '承認者');
    addTranslation('approver', 'en', 'Approver');
    addTranslation('first_approver', 'ja', '第1承認者');
    addTranslation('first_approver', 'en', 'First Approver');
    addTranslation('second_approver', 'ja', '第2承認者');
    addTranslation('second_approver', 'en', 'Second Approver');
    addTranslation('final_check', 'ja', '最終確認');
    addTranslation('final_check', 'en', 'Final Check');
    addTranslation('not_started_yet', 'ja', '未着手');
    addTranslation('not_started_yet', 'en', 'Not Started');
    addTranslation('request_date', 'ja', '申請日');
    addTranslation('request_date', 'en', 'Request Date');
    addTranslation('days_elapsed', 'ja', '経過日数');
    addTranslation('days_elapsed', 'en', 'Days Elapsed');

    // ===== DOCUMENT PAGE =====
    addTranslation('documents', 'ja', 'ドキュメント');
    addTranslation('documents', 'en', 'Documents');
    addTranslation('search_documents', 'ja', 'ドキュメントを検索');
    addTranslation('search_documents', 'en', 'Search Documents');
    addTranslation('all_types', 'ja', 'すべてのタイプ');
    addTranslation('all_types', 'en', 'All Types');
    addTranslation('contracts', 'ja', '契約書類');
    addTranslation('contracts', 'en', 'Contracts');
    addTranslation('policies', 'ja', '規程・ポリシー');
    addTranslation('policies', 'en', 'Policies');
    addTranslation('doc_mgmt', 'ja', '文書管理');
    addTranslation('doc_mgmt', 'en', 'Document Management');
    addTranslation('templates', 'ja', 'テンプレート');
    addTranslation('templates', 'en', 'Templates');
    addTranslation('forms', 'ja', '申請フォーム');
    addTranslation('forms', 'en', 'Application Forms');
    addTranslation('manuals', 'ja', 'マニュアル');
    addTranslation('manuals', 'en', 'Manuals');
    addTranslation('reports', 'ja', 'レポート');
    addTranslation('reports', 'en', 'Reports');
    addTranslation('doc_document', 'ja', 'ドキュメント');
    addTranslation('doc_document', 'en', 'Document');
    addTranslation('doc_template', 'ja', 'テンプレート');
    addTranslation('doc_template', 'en', 'Template');
    addTranslation('confidential', 'ja', '機密文書');
    addTranslation('confidential', 'en', 'Confidential');
    addTranslation('last_updated', 'ja', '最終更新日');
    addTranslation('last_updated', 'en', 'Last Updated');
    addTranslation('sort_by_name', 'ja', '名前順');
    addTranslation('sort_by_name', 'en', 'Sort by Name');
    addTranslation('sort_by_size', 'ja', 'サイズ順');
    addTranslation('sort_by_size', 'en', 'Sort by Size');
    addTranslation('updated_by', 'ja', '更新者');
    addTranslation('updated_by', 'en', 'Updated By');
    addTranslation('upload', 'ja', 'アップロード');
    addTranslation('upload', 'en', 'Upload');
    addTranslation('upload_complete', 'ja', 'アップロード完了');
    addTranslation('upload_complete', 'en', 'Upload Complete');
    addTranslation('doc_deleted', 'ja', 'ドキュメントが削除されました');
    addTranslation('doc_deleted', 'en', 'Document Deleted');
    addTranslation('share', 'ja', '共有');
    addTranslation('share', 'en', 'Share');
    addTranslation(
      'drag_drop_upload',
      'ja',
      'ファイルをドラッグ＆ドロップ、またはクリックしてアップロード'
    );
    addTranslation(
      'drag_drop_upload',
      'en',
      'Drag & drop files, or click to upload'
    );
    addTranslation('supported_formats', 'ja', '対応形式');
    addTranslation('supported_formats', 'en', 'Supported Formats');
    addTranslation('max_file_size', 'ja', '最大');
    addTranslation('max_file_size', 'en', 'Max');

    // ===== DASHBOARD PAGE =====
    addTranslation('dashboard_reports', 'ja', 'レポート・分析ダッシュボード');
    addTranslation('dashboard_reports', 'en', 'Reports & Analytics Dashboard');
    addTranslation('this_week', 'ja', '今週');
    addTranslation('this_week', 'en', 'This Week');
    addTranslation('this_month', 'ja', '今月');
    addTranslation('this_month', 'en', 'This Month');
    addTranslation('quarter', 'ja', '四半期');
    addTranslation('quarter', 'en', 'Quarter');
    addTranslation('this_year', 'ja', '今年');
    addTranslation('this_year', 'en', 'This Year');
    addTranslation('this_quarter', 'ja', '今四半期');
    addTranslation('this_quarter', 'en', 'This Quarter');
    addTranslation('overview', 'ja', '概要');
    addTranslation('overview', 'en', 'Overview');
    addTranslation('demographics', 'ja', '人口統計');
    addTranslation('demographics', 'en', 'Demographics');
    addTranslation('export_report', 'ja', 'レポート出力');
    addTranslation('export_report', 'en', 'Export Report');
    addTranslation('refresh', 'ja', '更新');
    addTranslation('refresh', 'en', 'Refresh');
    addTranslation('total_employees', 'ja', '総従業員数');
    addTranslation('total_employees', 'en', 'Total Employees');
    addTranslation('turnover_rate', 'ja', '離職率');
    addTranslation('turnover_rate', 'en', 'Turnover Rate');
    addTranslation('avg_overtime', 'ja', '平均残業時間');
    addTranslation('avg_overtime', 'en', 'Avg Overtime Hours');
    addTranslation('leave_utilization', 'ja', '有給消化率');
    addTranslation('leave_utilization', 'en', 'Leave Utilization Rate');
    addTranslation('compared_last_month', 'ja', '前月比');
    addTranslation('compared_last_month', 'en', 'vs Last Month');
    addTranslation('industry_avg', 'ja', '業界平均');
    addTranslation('industry_avg', 'en', 'Industry Average');
    addTranslation('headcount_trend', 'ja', '従業員数推移');
    addTranslation('headcount_trend', 'en', 'Headcount Trend');
    addTranslation('last_12_months', 'ja', '過去12ヶ月');
    addTranslation('last_12_months', 'en', 'Last 12 Months');
    addTranslation('dept_distribution', 'ja', '部門別人員構成');
    addTranslation('dept_distribution', 'en', 'Department Distribution');
    addTranslation('dept_overtime', 'ja', '部門別残業時間');
    addTranslation('dept_overtime', 'en', 'Overtime by Department');
    addTranslation('attendance_summary', 'ja', '今月の勤怠サマリー');
    addTranslation('attendance_summary', 'en', 'Attendance Summary This Month');
    addTranslation('normal_attendance', 'ja', '正常出勤');
    addTranslation('normal_attendance', 'en', 'Normal Attendance');
    addTranslation('early_leave', 'ja', '早退');
    addTranslation('early_leave', 'en', 'Early Leave');
    addTranslation('leave_taken', 'ja', '有給取得');
    addTranslation('leave_taken', 'en', 'Leave Taken');

    // ===== SECURITY PAGE =====
    addTranslation('security', 'ja', 'セキュリティ');
    addTranslation('security', 'en', 'Security');
    addTranslation(
      'security_compliance',
      'ja',
      'セキュリティ・コンプライアンス'
    );
    addTranslation('security_compliance', 'en', 'Security & Compliance');
    addTranslation('audit_report', 'ja', '監査レポート');
    addTranslation('audit_report', 'en', 'Audit Report');
    addTranslation('security_settings', 'ja', 'セキュリティ設定');
    addTranslation('security_settings', 'en', 'Security Settings');
    addTranslation('security_alert', 'ja', 'セキュリティアラート');
    addTranslation('security_alert', 'en', 'Security Alert');
    addTranslation(
      'suspicious_login',
      'ja',
      '不審なログイン試行を検出しました'
    );
    addTranslation(
      'suspicious_login',
      'en',
      'Suspicious login attempts detected'
    );
    addTranslation('check_now', 'ja', '確認する');
    addTranslation('check_now', 'en', 'Check Now');
    addTranslation('security_score', 'ja', 'セキュリティスコア');
    addTranslation('security_score', 'en', 'Security Score');
    addTranslation('active_sessions', 'ja', 'アクティブセッション');
    addTranslation('active_sessions', 'en', 'Active Sessions');
    addTranslation('security_events', 'ja', 'セキュリティイベント');
    addTranslation('security_events', 'en', 'Security Events');
    addTranslation('today_detected', 'ja', '今日の検出件数');
    addTranslation('today_detected', 'en', 'Detected Today');
    addTranslation('two_fa_coverage', 'ja', '2FAカバレッジ');
    addTranslation('two_fa_coverage', 'en', '2FA Coverage');
    addTranslation('audit_log', 'ja', '監査ログ');
    addTranslation('audit_log', 'en', 'Audit Log');
    addTranslation('show_all', 'ja', 'すべて表示');
    addTranslation('show_all', 'en', 'Show All');
    addTranslation('blocked_login', 'ja', '不正ログイン試行をブロック');
    addTranslation('blocked_login', 'en', 'Blocked unauthorized login attempt');
    addTranslation('password_changed', 'ja', 'パスワード変更');
    addTranslation('password_changed', 'en', 'Password Changed');
    addTranslation('new_user_created', 'ja', '新規ユーザー作成');
    addTranslation('new_user_created', 'en', 'New User Created');
    addTranslation('permission_changed', 'ja', '権限設定変更');
    addTranslation('permission_changed', 'en', 'Permission Changed');
    addTranslation('critical', 'ja', '重大');
    addTranslation('critical', 'en', 'Critical');
    addTranslation('warning', 'ja', '警告');
    addTranslation('warning', 'en', 'Warning');
    addTranslation('info', 'ja', '情報');
    addTranslation('info', 'en', 'Info');
    addTranslation('success', 'ja', '成功');
    addTranslation('success', 'en', 'Success');
    addTranslation('compliance_check', 'ja', 'コンプライアンスチェック');
    addTranslation('compliance_check', 'en', 'Compliance Check');
    addTranslation('access_log', 'ja', 'アクセスログ');
    addTranslation('access_log', 'en', 'Access Log');
    addTranslation('security_alerts', 'ja', 'セキュリティ警告');
    addTranslation('security_alerts', 'en', 'Security Alerts');
    addTranslation('last_7_days', 'ja', '過去7日間');
    addTranslation('last_7_days', 'en', 'Last 7 Days');
    addTranslation('last_30_days', 'ja', '過去30日間');
    addTranslation('last_30_days', 'en', 'Last 30 Days');
    addTranslation('custom_range', 'ja', 'カスタム範囲');
    addTranslation('custom_range', 'en', 'Custom Range');
    addTranslation('view', 'ja', '表示');
    addTranslation('view', 'en', 'View');
    addTranslation('login', 'ja', 'ログイン');
    addTranslation('login', 'en', 'Login');
    addTranslation('logout', 'ja', 'ログアウト');
    addTranslation('logout', 'en', 'Logout');
    addTranslation('last_check', 'ja', '最終確認');
    addTranslation('last_check', 'en', 'Last Check');
    addTranslation('password_policy', 'ja', 'パスワードポリシー');
    addTranslation('password_policy', 'en', 'Password Policy');
    addTranslation('two_fa', 'ja', '二要素認証');
    addTranslation('two_fa', 'en', 'Two-Factor Authentication');
    addTranslation('data_encryption', 'ja', 'データ暗号化');
    addTranslation('data_encryption', 'en', 'Data Encryption');
    addTranslation('access_log_retention', 'ja', 'アクセスログ保持');
    addTranslation('access_log_retention', 'en', 'Access Log Retention');
    addTranslation('gdpr_compliance', 'ja', 'GDPR対応');
    addTranslation('gdpr_compliance', 'en', 'GDPR Compliance');
    addTranslation('compliant', 'ja', '準拠');
    addTranslation('compliant', 'en', 'Compliant');
    addTranslation('needs_attention', 'ja', '要対応');
    addTranslation('needs_attention', 'en', 'Needs Attention');
    addTranslation('access_control', 'ja', 'アクセス制御設定');
    addTranslation('access_control', 'en', 'Access Control Settings');
    addTranslation('add_rule', 'ja', 'ルール追加');
    addTranslation('add_rule', 'en', 'Add Rule');
    addTranslation('resource', 'ja', 'リソース');
    addTranslation('resource', 'en', 'Resource');
    addTranslation('admin', 'ja', '管理者');
    addTranslation('admin', 'en', 'Admin');
    addTranslation('hr_dept', 'ja', '人事部');
    addTranslation('hr_dept', 'en', 'HR Dept');
    addTranslation('dept_head', 'ja', '部門長');
    addTranslation('dept_head', 'en', 'Dept Head');
    addTranslation('general_employee', 'ja', '一般社員');
    addTranslation('general_employee', 'en', 'General Employee');
    addTranslation('enabled', 'ja', '有効');
    addTranslation('enabled', 'en', 'Enabled');
    addTranslation('disabled', 'ja', '無効');
    addTranslation('disabled', 'en', 'Disabled');
    addTranslation('basic_employee_info', 'ja', '社員情報（基本）');
    addTranslation('basic_employee_info', 'en', 'Employee Info (Basic)');
    addTranslation('salary_info', 'ja', '給与情報');
    addTranslation('salary_info', 'en', 'Salary Info');
    addTranslation('hr_evaluation', 'ja', '人事評価');
    addTranslation('hr_evaluation', 'en', 'HR Evaluation');
    addTranslation('request_approval', 'ja', '申請承認');
    addTranslation('request_approval', 'en', 'Request Approval');
    addTranslation('system_settings', 'ja', 'システム設定');
    addTranslation('system_settings', 'en', 'System Settings');
    addTranslation('current_logged_in', 'ja', '現在のログインユーザー');
    addTranslation('current_logged_in', 'en', 'Currently Logged In');

    // ===== ADDITIONAL COMMON KEYS =====
    addTranslation('select_period', 'ja', '期間選択');
    addTranslation('select_period', 'en', 'Select Period');
    addTranslation('register_skill', 'ja', 'スキル登録');
    addTranslation('register_skill', 'en', 'Register Skill');
    addTranslation('skill_career_mgmt', 'ja', 'スキル・キャリア管理');
    addTranslation('skill_career_mgmt', 'en', 'Skill & Career Management');

    // ===== ADDITIONAL MISSING TRANSLATIONS =====
    addTranslation('processed', 'ja', '処理済み');
    addTranslation('processed', 'en', 'Processed');
    addTranslation('year_suffix', 'ja', '年');
    addTranslation('year_suffix', 'en', '');
    addTranslation('month_suffix', 'ja', '月');
    addTranslation('month_suffix', 'en', '');
    addTranslation('salary_projection', 'ja', '給与予測');
    addTranslation('salary_projection', 'en', 'Salary Projection');
    addTranslation('alert_resolved', 'ja', 'アラートを解決しました');
    addTranslation('alert_resolved', 'en', 'Alert Resolved');
    addTranslation(
      'compliance_check_complete',
      'ja',
      'コンプライアンスチェック完了'
    );
    addTranslation(
      'compliance_check_complete',
      'en',
      'Compliance Check Complete'
    );

    // ===== MASS IMPORT TRANSLATIONS =====
    addTranslation('mass_import_tasks', 'ja', '一括インポートタスク');
    addTranslation('mass_import_tasks', 'en', 'Mass Import Tasks');
    addTranslation('preview_import', 'ja', 'プレビュー');
    addTranslation('preview_import', 'en', 'Preview');
    addTranslation('confirm_import', 'ja', 'インポートの確認');
    addTranslation('confirm_import', 'en', 'Confirm Import');
    addTranslation('confirm', 'ja', '確認');
    addTranslation('confirm', 'en', 'Confirm');
  }

  private static void addTranslation(String key, String lang, String value) {
    if (!translations.containsKey(key)) {
      translations.put(key, new Map<String, String>());
    }
    translations.get(key).put(lang, value);
  }

  /**
   * Get translation for a key in specified language
   * @param key The translation key
   * @param lang The language code ('ja' or 'en')
   * @return The translated string, or the key if not found
   */
  public static String get(String key, String lang) {
    if (String.isBlank(lang)) {
      lang = 'ja'; // Default to Japanese
    }
    if (
      translations.containsKey(key) && translations.get(key).containsKey(lang)
    ) {
      return translations.get(key).get(lang);
    }
    return key; // Return key if translation not found
  }

  /**
   * Get all translations for a specific language as a map
   * @param lang The language code
   * @return Map of key to translated value
   */
  public static Map<String, String> getAllTranslations(String lang) {
    Map<String, String> result = new Map<String, String>();
    if (String.isBlank(lang)) {
      lang = 'ja';
    }
    for (String key : translations.keySet()) {
      if (translations.get(key).containsKey(lang)) {
        result.put(key, translations.get(key).get(lang));
      } else {
        result.put(key, key);
      }
    }
    return result;
  }
}