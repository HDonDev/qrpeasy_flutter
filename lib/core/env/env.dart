import 'package:envied/envied.dart';

part 'env.g.dart';

@envied
abstract class Env {
  @EnviedField(varName: 'APP_URL')
  static const String appUrl = _Env.appUrl;
}
