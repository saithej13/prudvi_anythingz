import 'package:anythingz/interfaces/repository_interface.dart';
import 'package:anythingz/util/html_type.dart';

abstract class HtmlRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getHtmlText(HtmlType htmlType);
}