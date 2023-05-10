// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDataService _$UserDataServiceFromJson(Map<String, dynamic> json) =>
    UserDataService()
      ..id = json['id'] as String
      ..name = json['name'] as String
      ..bio = json['bio'] as String
      ..profileImage = json['profileImage'] as String
      ..contacts = (json['contacts'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, PublicUser.fromJson(e as Map<String, dynamic>)),
      )
      ..friendRequests = (json['friendRequests'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, FriendRequest.fromJson(e as Map<String, dynamic>)),
      );

Map<String, dynamic> _$UserDataServiceToJson(UserDataService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bio': instance.bio,
      'profileImage': instance.profileImage,
      'contacts': instance.contacts.map((k, e) => MapEntry(k, e.toJson())),
      'friendRequests':
          instance.friendRequests.map((k, e) => MapEntry(k, e.toJson())),
    };

PublicUser _$PublicUserFromJson(Map<String, dynamic> json) => PublicUser(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String,
      profileImage: json['profileImage'] as String,
    );

Map<String, dynamic> _$PublicUserToJson(PublicUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bio': instance.bio,
      'profileImage': instance.profileImage,
    };

FriendRequest _$FriendRequestFromJson(Map<String, dynamic> json) =>
    FriendRequest(
      id: json['id'] as String,
      sender: json['sender'] as String,
      receiver: json['receiver'] as String,
      accepted: json['accepted'] as bool,
      rejected: json['rejected'] as bool,
    );

Map<String, dynamic> _$FriendRequestToJson(FriendRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': instance.sender,
      'receiver': instance.receiver,
      'accepted': instance.accepted,
      'rejected': instance.rejected,
    };
