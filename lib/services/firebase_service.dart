import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../firebase_options.dart';
import 'mock_data_service.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._();
  FirebaseService._();

  bool _isFirebaseInitialized = false;
  bool get isFirebaseInitialized => _isFirebaseInitialized;

  FirebaseAuth? _auth;
  FirebaseDatabase? _database;

  // Stream controllers to push real-time updates to providers
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  // Initialize Core and check status
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _auth = FirebaseAuth.instance;
      _database = FirebaseDatabase.instance;
      _database!.setPersistenceEnabled(true); // Enable local caching/offline capability
      _isFirebaseInitialized = true;
      print("🚀 [FirebaseService] Real Firebase backend initialized successfully.");
      
      // Wire up auth state changes listener
      _auth!.authStateChanges().listen((User? user) async {
        if (user == null) {
          _authStateController.add(null);
        } else {
          final userModel = await fetchUserData(user.uid);
          _authStateController.add(userModel);
          // Set user as online upon successful authentication
          setUserPresence(user.uid, true);
        }
      });
    } catch (e) {
      _isFirebaseInitialized = false;
      print("⚠️ [FirebaseService] Firebase setup failed. Error: $e");
    }
  }

  // --- AUTHENTICATION BACKEND SERVICES ---

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_isFirebaseInitialized) {
      try {
        final credential = await _auth!.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = credential.user!.uid;
        
        final newUser = UserModel(
          uid: uid,
          name: name,
          email: email,
          profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
          isOnline: true,
          status: 'Excited to join ConnectX! 🎉',
          lastSeen: DateTime.now(),
          typingTo: '',
        );

        // Upload to database
        await _database!.ref('users/$uid').set(newUser.toMap());
        return newUser;
      } on FirebaseAuthException catch (e) {
        throw Exception(_handleAuthError(e.code));
      } catch (e) {
        throw Exception('An unexpected error occurred during sign up.');
      }
    } else {
      // Offline mock signup
      await Future.delayed(const Duration(milliseconds: 1000));
      final mockUser = UserModel(
        uid: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
        isOnline: true,
        status: 'Excited to join ConnectX! 🎉',
        lastSeen: DateTime.now(),
        typingTo: '',
      );
      _authStateController.add(mockUser);
      return mockUser;
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (_isFirebaseInitialized) {
      try {
        final credential = await _auth!.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = credential.user!.uid;
        final userModel = await fetchUserData(uid);
        setUserPresence(uid, true);
        return userModel;
      } on FirebaseAuthException catch (e) {
        throw Exception(_handleAuthError(e.code));
      } catch (e) {
        throw Exception('Authentication failed.');
      }
    } else {
      // Offline mock login
      await Future.delayed(const Duration(milliseconds: 1000));
      final mockUser = UserModel(
        uid: 'current_user',
        name: email.split('@')[0].toUpperCase(),
        email: email,
        profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
        isOnline: true,
        status: 'Connecting people and ideas. 🌐',
        lastSeen: DateTime.now(),
        typingTo: '',
      );
      _authStateController.add(mockUser);
      return mockUser;
    }
  }

  Future<void> logout(String? uid) async {
    if (_isFirebaseInitialized) {
      if (uid != null) {
        await setUserPresence(uid, false);
      }
      await _auth!.signOut();
    } else {
      _authStateController.add(null);
    }
  }

  Future<UserModel> fetchUserData(String uid) async {
    if (_isFirebaseInitialized) {
      final snapshot = await _database!.ref('users/$uid').get();
      if (snapshot.exists) {
        final map = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel.fromMap(map);
      } else {
        throw Exception('User profile data does not exist.');
      }
    } else {
      return UserModel(
        uid: 'current_user',
        name: 'Mock User',
        email: 'mock@example.com',
        profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
        isOnline: true,
        status: 'Offline mock engine.',
        lastSeen: DateTime.now(),
        typingTo: '',
      );
    }
  }

  Future<void> updateProfileData(String uid, Map<String, dynamic> data) async {
    if (_isFirebaseInitialized) {
      await _database!.ref('users/$uid').update(data);
    }
  }

  // --- DATABASE CHAT INTERFACE & STREAMS ---

  String getChatId(String uid1, String uid2) {
    // Sort alphabetically to maintain the same Room ID for both users
    final sortedList = [uid1, uid2]..sort();
    return '${sortedList[0]}_${sortedList[1]}';
  }

  Stream<List<UserModel>> usersStream() {
    if (_isFirebaseInitialized) {
      return _database!.ref('users').onValue.map((event) {
        final users = <UserModel>[];
        if (event.snapshot.value != null) {
          final rawMap = event.snapshot.value as Map;
          rawMap.forEach((key, value) {
            final userMap = Map<String, dynamic>.from(value as Map);
            // Skip currently authenticated user from chat lists
            if (userMap['uid'] != _auth?.currentUser?.uid) {
              users.add(UserModel.fromMap(userMap));
            }
          });
        }
        return users;
      });
    } else {
      // Mock Users list stream
      return Stream.value(MockDataService.mockUsers);
    }
  }

  Stream<List<MessageModel>> messagesStream(String otherUserId) {
    if (_isFirebaseInitialized) {
      final currentUserId = _auth!.currentUser!.uid;
      final roomId = getChatId(currentUserId, otherUserId);
      return _database!.ref('chat_rooms/$roomId/messages').orderByChild('timestamp').onValue.map((event) {
        final messages = <MessageModel>[];
        if (event.snapshot.value != null) {
          final rawMap = event.snapshot.value as Map;
          // Sort messages chronologically by timestamp
          final sortedEntries = rawMap.entries.toList()
            ..sort((a, b) {
              final aVal = Map<String, dynamic>.from(a.value as Map);
              final bVal = Map<String, dynamic>.from(b.value as Map);
              return aVal['timestamp'].compareTo(bVal['timestamp']);
            });
            
          for (var entry in sortedEntries) {
            final msgMap = Map<String, dynamic>.from(entry.value as Map);
            messages.add(MessageModel.fromMap(msgMap));
          }
        }
        return messages;
      });
    } else {
      // Fallback local mock stream
      return Stream.value(MockDataService.getMockMessages('current_user', otherUserId));
    }
  }

  Future<void> sendMessage(String otherUserId, MessageModel message) async {
    if (_isFirebaseInitialized) {
      final currentUserId = _auth!.currentUser!.uid;
      final roomId = getChatId(currentUserId, otherUserId);
      final newMsgRef = _database!.ref('chat_rooms/$roomId/messages').push();
      final messageWithId = message.copyWith(id: newMsgRef.key);
      await newMsgRef.set(messageWithId.toMap());
    }
  }

  // --- PRESENCE & TYPING INDICATORS ---

  Future<void> setUserPresence(String uid, bool isOnline) async {
    if (_isFirebaseInitialized) {
      final presenceRef = _database!.ref('users/$uid');
      await presenceRef.update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().toIso8601String(),
      });

      if (isOnline) {
        // Setup disconnect hooks to mark offline automatically on app termination
        final disconnectRef = _database!.ref('users/$uid');
        disconnectRef.onDisconnect().update({
          'isOnline': false,
          'lastSeen': DateTime.now().toIso8601String(),
          'typingTo': '',
        });
      }
    }
  }

  Future<void> setTypingState(String otherUserId, bool isTyping) async {
    if (_isFirebaseInitialized) {
      final currentUserId = _auth!.currentUser!.uid;
      await _database!.ref('users/$currentUserId').update({
        'typingTo': isTyping ? otherUserId : '',
      });
    }
  }

  Stream<bool> typingStream(String otherUserId) {
    if (_isFirebaseInitialized) {
      final currentUserId = _auth!.currentUser!.uid;
      return _database!.ref('users/$otherUserId/typingTo').onValue.map((event) {
        return event.snapshot.value == currentUserId;
      });
    } else {
      return Stream.value(false);
    }
  }

  String _handleAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account exists with this email.';
      case 'wrong-password':
        return 'Incorrect password entered.';
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'weak-password':
        return 'The password entered is too weak.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
