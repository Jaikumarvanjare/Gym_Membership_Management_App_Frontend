import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class Member {
  final int id;
  final String name;
  final String email;
  final String membershipType;
  final String membershipStatus;
  final String? membershipStart;
  final String? membershipEnd;

  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.membershipType,
    required this.membershipStatus,
    this.membershipStart,
    this.membershipEnd,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        membershipType: json['membership_type'] as String,
        membershipStatus: json['membership_status'] as String,
        membershipStart: json['membership_start'] as String?,
        membershipEnd: json['membership_end'] as String?,
      );
}

class MembersResult {
  final List<Member> data;
  final int total;
  final int page;
  final int limit;

  const MembersResult({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class MemberService {
  final Dio _dio = ApiClient.instance.dio;

  Future<MembersResult> getMembers({
    int page = 1,
    int limit = 10,
    String? membershipType,
  }) async {
    try {
      final res = await _dio.get(
        '/members',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (membershipType != null) 'membership_type': membershipType,
        },
      );

      final body = res.data as Map<String, dynamic>;
      final meta = body['meta'] as Map<String, dynamic>;
      final rawList = body['data'] as List<dynamic>;

      return MembersResult(
        data: rawList
            .map((e) => Member.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: meta['total'] as int,
        page: meta['page'] as int,
        limit: meta['limit'] as int,
      );
    } on DioException catch (e) {
      throw e.error ?? ApiException('Failed to load members');
    }
  }

  Future<Member> getMemberById(int id) async {
    try {
      final res = await _dio.get('/members/$id');
      return Member.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ApiException('Failed to load member');
    }
  }

  Future<Member> createMember({
    required String name,
    required String email,
    required String membershipType,
  }) async {
    try {
      final res = await _dio.post('/members', data: {
        'name': name,
        'email': email,
        'membership_type': membershipType,
      });
      return Member.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ApiException('Failed to create member');
    }
  }

  Future<Member> updateMember(
    int id, {
    String? name,
    String? email,
    String? membershipType,
  }) async {
    try {
      final res = await _dio.put('/members/$id', data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (membershipType != null) 'membership_type': membershipType,
      });
      return Member.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ApiException('Failed to update member');
    }
  }

  Future<void> deleteMember(int id) async {
    try {
      await _dio.delete('/members/$id');
    } on DioException catch (e) {
      throw e.error ?? ApiException('Failed to delete member');
    }
  }

  Future<List<Member>> getExpiredMembers() async {
    try {
      final res = await _dio.get('/members/expired');
      final rawList = res.data['data'] as List<dynamic>;
      return rawList
          .map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException('Failed to load expired members');
    }
  }
}