import 'package:feathrtalk_frontend/models/user_tokens.dart';
import 'package:json_annotation/json_annotation.dart';

import '../providers/auth_provider.dart';

part 'login_data.g.dart';

@JsonSerializable(explicitToJson: true)
class LoginData {
  late UserTokens _tokens;
  late String _id;

  LoginData(UserTokens tokens, String id) {
    _tokens = tokens;
    _id = id;
  }

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataToJson(this);

  UserTokens get tokens => _tokens;
  String get id => _id;
}
