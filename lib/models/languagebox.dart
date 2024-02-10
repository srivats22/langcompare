import 'package:hive/hive.dart';
import 'language-model.dart';

class LanguageBox{
  static Box<LanguageModel> getLanguages() =>
      Hive.box<LanguageModel>('languages');
}