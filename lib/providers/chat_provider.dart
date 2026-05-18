import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../services/firebase_service.dart';
import '../services/mock_data_service.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;

  List<UserModel> _users = [];
  List<MessageModel> _activeMessages = [];
  final Map<String, int> _unreadCounts = {};
  
  String _searchQuery = '';
  String? _activeChatUserId;
  bool _isLoading = false;
  bool _isScrollNeeded = false;
  bool _activeUserTyping = false;

  // Stream subscriptions for clean teardown and data leaks prevention
  StreamSubscription<List<UserModel>>? _usersSubscription;
  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  StreamSubscription<bool>? _typingSubscription;

  // Debounce helper for typing indicator thrashing prevention
  Timer? _typingDebounce;

  List<UserModel> get users {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    return _users
        .where((user) => user.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<MessageModel> get activeMessages => _activeMessages;
  String? get activeChatUserId => _activeChatUserId;
  bool get isScrollNeeded => _isScrollNeeded;
  bool get isTypingActive => _activeUserTyping;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  int getUnreadCount(String userId) => _unreadCounts[userId] ?? 0;
  bool getIsTyping(String userId) => userId == _activeChatUserId ? _activeUserTyping : false;

  ChatProvider() {
    _startUsersListener();
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingDebounce?.cancel();
    super.dispose();
  }

  void resetScrollNeeded() {
    _isScrollNeeded = false;
  }

  // --- CORE LISTENERS & STREAMS ARCHITECTURE ---

  void _startUsersListener() {
    _isLoading = true;
    notifyListeners();

    _usersSubscription = _firebaseService.usersStream().listen((List<UserModel> updatedUsers) {
      _users = updatedUsers;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      print("⚠️ Users stream error: $err");
      _isLoading = false;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveChat(String? userId) {
    _activeChatUserId = userId;
    
    // Clean up previous conversations and typing configurations
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _activeMessages = [];
    _activeUserTyping = false;

    if (userId != null) {
      _unreadCounts[userId] = 0; // Clear unread on open
      _isLoading = true;
      notifyListeners();

      // 1. Subscribe to realtime chat log stream
      _messagesSubscription = _firebaseService.messagesStream(userId).listen((List<MessageModel> updatedMessages) {
        _activeMessages = updatedMessages;
        _isScrollNeeded = true;
        _isLoading = false;
        notifyListeners();
      }, onError: (err) {
        print("⚠️ Messages stream error: $err");
        _isLoading = false;
        notifyListeners();
      });

      // 2. Subscribe to typing state stream
      _typingSubscription = _firebaseService.typingStream(userId).listen((bool typingState) {
        _activeUserTyping = typingState;
        if (typingState) {
          _isScrollNeeded = true;
        }
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  List<MessageModel> getMessagesForUser(String userId) {
    if (userId == _activeChatUserId) {
      return _activeMessages;
    }
    // Return empty list or fall back mock if looking up background histories
    return [];
  }

  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.uid == userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> sendMessage(String message, {String type = "text", String? attachmentUrl}) async {
    if (_activeChatUserId == null) return;
    final otherUserId = _activeChatUserId!;

    final newMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      receiverId: otherUserId,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
      type: type,
      attachmentUrl: attachmentUrl,
    );

    // If using real backend, push to Firebase. Otherwise execute local mock replies
    if (_firebaseService.isFirebaseInitialized) {
      await _firebaseService.sendMessage(otherUserId, newMessage);
    } else {
      // Local mockup response system compatibility
      _activeMessages.add(newMessage);
      _isScrollNeeded = true;
      notifyListeners();
      _triggerMockAutoReply(otherUserId);
    }
  }

  void _triggerMockAutoReply(String userId) {
    Timer(const Duration(milliseconds: 1200), () {
      _activeUserTyping = true;
      _isScrollNeeded = true;
      notifyListeners();

      Timer(const Duration(milliseconds: 2000), () {
        _activeUserTyping = false;
        
        final randomReply = MockDataService.mockReplies[Random().nextInt(MockDataService.mockReplies.length)];
        final replyMessage = MessageModel(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: userId,
          receiverId: 'current_user',
          message: randomReply,
          timestamp: DateTime.now(),
          isRead: _activeChatUserId == userId,
          type: 'text',
        );

        _activeMessages.add(replyMessage);
        
        if (_activeChatUserId != userId) {
          _unreadCounts[userId] = (_unreadCounts[userId] ?? 0) + 1;
        }

        _isScrollNeeded = true;
        notifyListeners();
      });
    });
  }

  // --- PRESENCE SETTER ACTIONS ---

  void setTyping(bool isTyping) {
    if (_activeChatUserId == null) return;
    final otherUserId = _activeChatUserId!;

    // Debounce database calls to prevent excessive network operations
    if (_typingDebounce?.isActive ?? false) _typingDebounce!.cancel();

    _typingDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_firebaseService.isFirebaseInitialized) {
        _firebaseService.setTypingState(otherUserId, isTyping);
      }
    });
  }

  // Clear chat (useful for testing/resets)
  void clearChat(String userId) {
    _activeMessages = [];
    notifyListeners();
  }
}
