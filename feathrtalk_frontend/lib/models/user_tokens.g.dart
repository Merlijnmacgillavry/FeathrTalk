// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTokens _$UserTokensFromJson(Map<String, dynamic> json) => UserTokens()
  ..accessToken = json['accessToken'] as String
  ..refreshToken = json['refreshToken'] as String;

Map<String, dynamic> _$UserTokensToJson(UserTokens instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
