import 'package:hive/hive.dart';
part 'api-model.g.dart';

@HiveType(typeId: 1)
class ApiModel extends HiveObject{
  @HiveField(0)
  late String apiType;
  @HiveField(1)
  late String apiKey;
}