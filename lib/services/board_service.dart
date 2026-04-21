import 'package:cloud_firestore/cloud_firestore.dart';

class BoardService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _boards => _db.collection('boards');
  CollectionReference get _comments => _db.collection('comments');

  // ── 게시물 목록 (최신순, 페이지네이션)
  Future<List<Map<String, dynamic>>> getPosts({
    String? category,
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    Query query = _boards.orderBy('createdAt', descending: true).limit(limit);
    if (category != null && category != '전체') {
      query = query.where('category', isEqualTo: category);
    }
    if (lastDoc != null) query = query.startAfterDocument(lastDoc);
    final snap = await query.get();
    return snap.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      data['docId'] = d.id;
      data['_doc'] = d;
      return data;
    }).toList();
  }

  // ── 게시물 작성
  Future<void> createPost({
    required String uid,
    required String nickname,
    required String profileEmoji,
    required String title,
    required String content,
    required String category,
  }) async {
    await _boards.add({
      'uid': uid,
      'nickname': nickname,
      'profileEmoji': profileEmoji,
      'title': title,
      'content': content,
      'category': category,
      'likeCount': 0,
      'commentCount': 0,
      'likedBy': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── 좋아요 토글
  Future<void> toggleLike(String postId, String uid) async {
    final ref = _boards.doc(postId);
    final doc = await ref.get();
    final data = doc.data() as Map<String, dynamic>;
    final likedBy = List<String>.from(data['likedBy'] ?? []);

    if (likedBy.contains(uid)) {
      likedBy.remove(uid);
      await ref.update({'likedBy': likedBy, 'likeCount': FieldValue.increment(-1)});
    } else {
      likedBy.add(uid);
      await ref.update({'likedBy': likedBy, 'likeCount': FieldValue.increment(1)});
    }
  }

  // ── 댓글 목록
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final snap = await _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .get();
    return snap.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      data['docId'] = d.id;
      return data;
    }).toList();
  }

  // ── 댓글 작성
  Future<void> addComment({
    required String postId,
    required String uid,
    required String nickname,
    required String profileEmoji,
    required String content,
  }) async {
    await _comments.add({
      'postId': postId,
      'uid': uid,
      'nickname': nickname,
      'profileEmoji': profileEmoji,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _boards.doc(postId).update({'commentCount': FieldValue.increment(1)});
  }

  // ── 게시물 삭제
  Future<void> deletePost(String postId) async {
    await _boards.doc(postId).delete();
    // 댓글도 삭제
    final comments = await _comments.where('postId', isEqualTo: postId).get();
    for (final doc in comments.docs) {
      await doc.reference.delete();
    }
  }
}
