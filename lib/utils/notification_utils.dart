import 'package:e_trace_app/utils/storage_manager.dart';

setNotificationArrived(String title, String text, String action, String url) async {
  StorageManager.saveData('action', action);
  StorageManager.saveData('title_notification', title);
  StorageManager.saveData('message_notification', text);
  StorageManager.saveData('url_notification', url);
  StorageManager.saveData('clicked', false);
}

setNotificationClicked() async {
  StorageManager.deleteData('action');
  StorageManager.deleteData('title_notification');
  StorageManager.deleteData('message_notification');
  StorageManager.deleteData('url_notification');
  StorageManager.deleteData('clicked');
}