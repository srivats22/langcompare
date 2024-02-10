import 'package:hive/hive.dart';
import 'api-model.dart';

class ApiBox{
  static Box<ApiModel> getApiKey() =>
      Hive.box<ApiModel>('apiinfo');
}