import '../models/user_model.dart';
import '../models/message_model.dart';

class MockDataService {
  static final List<UserModel> mockUsers = [
    UserModel(
      uid: 'user_1',
      name: 'Sarah Jenkins',
      email: 'sarah.j@example.com',
      profileImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
      isOnline: true,
      status: 'Design is intelligence made visible. 🎨',
      lastSeen: DateTime.now(),
      typingTo: '',
    ),
    UserModel(
      uid: 'user_2',
      name: 'Marcus Chen',
      email: 'm.chen@example.com',
      profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
      isOnline: true,
      status: 'Fluttering around the world! 🚀 | Dev',
      lastSeen: DateTime.now(),
      typingTo: '',
    ),
    UserModel(
      uid: 'user_3',
      name: 'Elena Rostova',
      email: 'elena.r@example.com',
      profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
      isOnline: false,
      status: 'Offline but dreaming. ✨',
      lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      typingTo: '',
    ),
    UserModel(
      uid: 'user_4',
      name: 'David Kojo',
      email: 'd.kojo@example.com',
      profileImage: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
      isOnline: true,
      status: 'Let\'s build something that matters. 🛠️',
      lastSeen: DateTime.now(),
      typingTo: '',
    ),
    UserModel(
      uid: 'user_5',
      name: 'Aiko Tanaka',
      email: 'aiko.t@example.com',
      profileImage: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80',
      isOnline: false,
      status: 'Coding is poetry in motion. 💻',
      lastSeen: DateTime.now().subtract(const Duration(minutes: 45)),
      typingTo: '',
    ),
  ];

  static List<MessageModel> getMockMessages(String currentUserId, String otherUserId) {
    if (otherUserId == 'user_1') {
      return [
        MessageModel(
          id: 'm1',
          senderId: 'user_1',
          receiverId: currentUserId,
          message: 'Hey there! Did you take a look at the new UI designs for ConnectX?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: true,
          type: 'text',
        ),
        MessageModel(
          id: 'm2',
          senderId: currentUserId,
          receiverId: 'user_1',
          message: 'Yes! They look absolutely stunning. Love the glassmorphic styling.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
          isRead: true,
          type: 'text',
        ),
        MessageModel(
          id: 'm3',
          senderId: 'user_1',
          receiverId: currentUserId,
          message: 'Awesome! We are implementing the dark theme palette next. Let me know what you think of it!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
          isRead: false,
          type: 'text',
        ),
      ];
    } else if (otherUserId == 'user_2') {
      return [
        MessageModel(
          id: 'm4',
          senderId: 'user_2',
          receiverId: currentUserId,
          message: 'Hey! Is GoRouter working perfectly on Web and mobile for you?',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: true,
          type: 'text',
        ),
        MessageModel(
          id: 'm5',
          senderId: currentUserId,
          receiverId: 'user_2',
          message: 'Yep, it handles nested shell routes like a charm! Clean navigation flow.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 50)),
          isRead: true,
          type: 'text',
        ),
        MessageModel(
          id: 'm6',
          senderId: 'user_2',
          receiverId: currentUserId,
          message: 'Brilliant! I will merge my branch soon then.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
          isRead: true,
          type: 'text',
        ),
      ];
    } else {
      return [
        MessageModel(
          id: 'm_gen_1',
          senderId: otherUserId,
          receiverId: currentUserId,
          message: 'Hey! How is everything going?',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          type: 'text',
        ),
        MessageModel(
          id: 'm_gen_2',
          senderId: currentUserId,
          receiverId: otherUserId,
          message: 'All good here! Working on the frontend implementation.',
          timestamp: DateTime.now().subtract(const Duration(hours: 20)),
          isRead: true,
          type: 'text',
        ),
      ];
    }
  }

  static final List<String> mockReplies = [
    "That sounds amazing! Let's schedule a call to talk about the final details.",
    "Wow, I really love how smooth the transitions are feeling in this build!",
    "Could you review the pull request when you get a second? I added some improvements.",
    "Absolutely! Let's get started on that right away. 🚀",
    "I'm currently grabing a coffee ☕. Will jump on my laptop in 10 minutes and check it!",
    "Interesting! Let's discuss it in our daily standup tomorrow morning.",
  ];
}
