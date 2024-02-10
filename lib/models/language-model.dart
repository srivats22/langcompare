import 'package:hive/hive.dart';
part 'language-model.g.dart';

@HiveType(typeId: 0)
class LanguageModel extends HiveObject{
  @HiveField(0)
  late String languageName;
}