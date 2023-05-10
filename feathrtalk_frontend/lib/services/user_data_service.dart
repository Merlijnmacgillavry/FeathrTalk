import 'dart:collection';
import 'dart:ffi';

import 'package:feathrtalk_frontend/services/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';

// part 'user.g.dart';
part 'user_data_service.g.dart';
// part 'public_user.g.dart';
// part 'friend_request.g.dart';

@JsonSerializable(explicitToJson: true)
class UserDataService {
  late String id;
  late String name;
  late String bio;
  late String profileImage;
  // late List<Chat> _chats;
  late Map<String, PublicUser> contacts = <String, PublicUser>{};
  late Map<String, FriendRequest> friendRequests = {};

  UserDataService();

  setUserData(Map<String, dynamic> rawUserData) {
    id = rawUserData['_id'][r'$oid'];
    name = rawUserData['name'];
    bio = rawUserData['bio'];
    profileImage = rawUserData['profile_image'];
    contacts.clear();
    friendRequests.clear();

    for (var contactData in rawUserData['contacts']) {
      PublicUser contact = PublicUser(
          id: contactData['_id'][r'$oid'],
          name: contactData['name'],
          bio: contactData['bio'],
          profileImage: contactData['profile_image']);
      contacts[contact.id] = contact;
    }
    for (var friendRequestData in rawUserData['friend_requests']) {
      FriendRequest friend_request = FriendRequest(
          id: friendRequestData['_id'][r'$oid'],
          sender: friendRequestData['sender'],
          receiver: friendRequestData['receiver'],
          accepted: friendRequestData['accepted'],
          rejected: friendRequestData['rejected']);
      friendRequests[friend_request.id] = friend_request;
    }
  }

  // late HashMap<String, PublicUser> blocks = HashMap<String, PublicUser>();
  factory UserDataService.fromJson(Map<String, dynamic> json) =>
      _$UserDataServiceFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataServiceToJson(this);
}

@JsonSerializable()
class PublicUser {
  late String id;
  late String name;
  late String bio;
  late String profileImage;

  factory PublicUser.fromJson(Map<String, dynamic> json) =>
      _$PublicUserFromJson(json);

  Map<String, dynamic> toJson() => _$PublicUserToJson(this);

  PublicUser(
      {required this.id,
      required this.name,
      required this.bio,
      required this.profileImage});
}

@JsonSerializable()
class FriendRequest {
  late String id;
  late String sender;
  late String receiver;
  late bool accepted;
  late bool rejected;

  factory FriendRequest.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FriendRequestToJson(this);

  FriendRequest(
      {required this.id,
      required this.sender,
      required this.receiver,
      required this.accepted,
      required this.rejected});
}

String? getId(Map<String, dynamic> rawUserData) {
  RegExp exp = RegExp(r'\s([[:alnum:]]+)');
  Iterable<RegExpMatch> matches = exp.allMatches(rawUserData['_id']);
  return matches.first[0];
}
