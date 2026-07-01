import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Message model for chat
class ChatMessage {
  final String id;
  final String senderId;
  final String senderRole;
  final String text;
  final DateTime? timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.text,
    this.timestamp,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderRole: data['senderRole'] ?? 'user',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderRole': senderRole,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

/// Chat model
class Chat {
  final String id;
  final String oderId;
  final String userName;
  final String? userEmail;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCountUser;
  final int unreadCountAdmin;

  Chat({
    required this.id,
    required this.oderId,
    required this.userName,
    this.userEmail,
    required this.lastMessage,
    this.lastMessageTime,
    required this.unreadCountUser,
    required this.unreadCountAdmin,
  });

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      id: doc.id,
      oderId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      userEmail: data['userEmail'],
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCountUser: data['unreadCountUser'] ?? 0,
      unreadCountAdmin: data['unreadCountAdmin'] ?? 0,
    );
  }
}

/// Chat Service for handling all chat operations
class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _chatsCollection => _firestore.collection('chats');

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get current user display name
  String get currentUserName {
    final user = _auth.currentUser;
    return user?.displayName ?? user?.email?.split('@').first ?? 'User';
  }

  /// Get current user email
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Get or create a chat for the current user
  Future<String> getOrCreateChat() async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Check if chat already exists for this user
    final existingChat = await _chatsCollection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingChat.docs.isNotEmpty) {
      return existingChat.docs.first.id;
    }

    // Create new chat
    final chatDoc = await _chatsCollection.add({
      'userId': userId,
      'userName': currentUserName,
      'userEmail': currentUserEmail,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCountUser': 0,
      'unreadCountAdmin': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return chatDoc.id;
  }

  /// Stream messages for a specific chat
  Stream<List<ChatMessage>> streamMessages(String chatId, {int limit = 50}) {
    return _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  /// Send a message as user
  Future<void> sendMessageAsUser(String chatId, String text) async {
    if (text.trim().isEmpty) return;

    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final batch = _firestore.batch();

    // Add message to subcollection
    final messageRef = _chatsCollection.doc(chatId).collection('messages').doc();
    batch.set(messageRef, {
      'senderId': userId,
      'senderRole': 'user',
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update chat document
    final chatRef = _chatsCollection.doc(chatId);
    batch.update(chatRef, {
      'lastMessage': text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCountAdmin': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Send a message as admin
  Future<void> sendMessageAsAdmin(String chatId, String text, {String? adminId}) async {
    if (text.trim().isEmpty) return;

    final senderId = adminId ?? currentUserId ?? 'admin';

    final batch = _firestore.batch();

    // Add message to subcollection
    final messageRef = _chatsCollection.doc(chatId).collection('messages').doc();
    batch.set(messageRef, {
      'senderId': senderId,
      'senderRole': 'admin',
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update chat document
    final chatRef = _chatsCollection.doc(chatId);
    batch.update(chatRef, {
      'lastMessage': text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCountUser': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Reset unread count for user (when user opens chat)
  Future<void> resetUserUnreadCount(String chatId) async {
    await _chatsCollection.doc(chatId).update({
      'unreadCountUser': 0,
    });
  }

  /// Reset unread count for admin (when admin opens chat)
  Future<void> resetAdminUnreadCount(String chatId) async {
    await _chatsCollection.doc(chatId).update({
      'unreadCountAdmin': 0,
    });
  }

  /// Stream all chats for admin panel (ordered by lastMessageTime)
  Stream<List<Chat>> streamAllChats() {
    return _chatsCollection
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Chat.fromFirestore(doc))
            .toList());
  }

  /// Get chat by ID
  Future<Chat?> getChatById(String chatId) async {
    final doc = await _chatsCollection.doc(chatId).get();
    if (doc.exists) {
      return Chat.fromFirestore(doc);
    }
    return null;
  }

  /// Stream single chat document
  Stream<Chat?> streamChat(String chatId) {
    return _chatsCollection.doc(chatId).snapshots().map((doc) {
      if (doc.exists) {
        return Chat.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Get user's chat ID (if exists)
  Future<String?> getUserChatId() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final existingChat = await _chatsCollection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingChat.docs.isNotEmpty) {
      return existingChat.docs.first.id;
    }
    return null;
  }

  /// Stream user's unread count
  Stream<int> streamUserUnreadCount() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value(0);
    }

    return _chatsCollection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0;
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return data['unreadCountUser'] ?? 0;
    });
  }

  /// Stream total unread count for admin
  Stream<int> streamAdminTotalUnreadCount() {
    return _chatsCollection.snapshots().map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['unreadCountAdmin'] ?? 0) as int;
      }
      return total;
    });
  }

  /// Load more messages (pagination)
  Future<List<ChatMessage>> loadMoreMessages(
    String chatId, {
    required DateTime beforeTimestamp,
    int limit = 20,
  }) async {
    final snapshot = await _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .where('timestamp', isLessThan: Timestamp.fromDate(beforeTimestamp))
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
  }

  /// Delete a chat (admin only)
  Future<void> deleteChat(String chatId) async {
    // Delete all messages first
    final messages = await _chatsCollection.doc(chatId).collection('messages').get();
    final batch = _firestore.batch();
    
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete chat document
    batch.delete(_chatsCollection.doc(chatId));
    
    await batch.commit();
  }
}
