/*
 * @Author       : Z2-WIN\xmm wujixmm@gmail.com
 * @Date         : 2026-01-05 11:12:10
 * @LastEditors  : Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime : 2026-01-05 13:25:29
 * @FilePath     : \ex1\lib\apis\data_model\user.dart
 * @Description  : 
 */
// class UserDataStruct {
//   final String id;
//   final String username;
//   final String? phone;
//   final String? name;
//   final String? avatar;
//   final String bio;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final List<String> roles;
  
//   const UserDataStruct({
//     required this.id,
//     required this.username,
//     this.phone,
//     this.name,
//     this.avatar,
//     required this.bio,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.roles,
//   });
  
//   // 统一的数据转换逻辑
//   factory UserDataStruct.fromMap(Map<String, dynamic> json) {
//     return UserDataStruct(
//       id: json['id'] ?? '',
//       username: json['username'] ?? json['nickname'] ?? '未知用户',
//       phone: json['phone'] ?? json['maskedPhone'],
//       name: json['name'] ?? json['nickname'] ?? json['username'],
//       avatar: json['avatar'] ?? json['headImage'] ?? json['profilePicture'],
//       bio: json['bio'] ?? json['description'] ?? '',
//       createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
//       updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
//       roles: List<String>.from(json['roles'] ?? []),
//     );
//   }
// }

abstract class UserDataStruct {
  final String id;
  final String username;
  final String? phone;
  final String? name;
  final String? avatar;
  final String bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> roles;
  
  const UserDataStruct({
    required this.id,
    required this.username,
    this.phone,
    this.name,
    this.avatar,
    required this.bio,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
  });
}
// mixin UserDataBaseMixin {
//   String get id;
//   String get username;
// }
// mixin UserDataStructMixin  on UserDataBaseMixin {
//   String get bio;
//   DateTime get createdAt;
//   DateTime get updatedAt;
//   List<String> get roles;
//   String? get maskedPhone; // 脱敏手机号，如：138****5678
//   String? get avatar;
//   String? get phone;
//   String? get name;
// }