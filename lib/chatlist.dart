import 'package:chat_app/chat_screen.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<Map<String, dynamic>> chatLists = [
    {
      "profilePictureUrl": "assets/images/image1.jpg",
      "username": "Juhyun Kim,...",
      "lastMessage": "[중고] 하루 만에 품절되는 오늘 입고 상",
      "messageTime": "16:47",
      "isOnline": true,
      "lastSeen": "23/12/2022"
    },
  ];
  // Function to convert date strings to DateTime objects
  DateTime convertToDateTime(String dateString) {
    // Assuming the date format is either "yesterday" or "dd/MM/yyyy"
    if (dateString == "yesterday") {
      return DateTime.now().subtract(Duration(days: 1));
    } else {
      try {
        final dateParts = dateString.split('/');
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        return DateTime(year, month, day);
      } catch (e) {
        // In case of any parsing error, return the current date
        return DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort the chatLists based on the date of the last message
    chatLists.sort((a, b) {
      final aDateTime = convertToDateTime(a["messageTime"]);
      final bDateTime = convertToDateTime(b["messageTime"]);
      return bDateTime.compareTo(aDateTime); // Descending order
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SendBird',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: chatLists.length,
          itemBuilder: (context, index) {
            final chatList = chatLists[index];
            return InboxChatListLayout(
              profilePictureUrl: chatList["profilePictureUrl"],
              username: chatList["username"],
              lastMessage: chatList["lastMessage"],
              messageTime: chatList["messageTime"],
              isOnline: chatList["isOnline"],
              lastSeen: chatList["lastSeen"],
            );
          },
        ),
      ),
    );
  }
}

class InboxChatListLayout extends StatelessWidget {
  final String? profilePictureUrl;
  final String? username;
  final String? lastMessage;
  final String? messageTime;
  final bool? isOnline;
  final String? lastSeen;

  const InboxChatListLayout({
    Key? key,
    this.profilePictureUrl,
    this.username,
    this.lastMessage,
    this.messageTime,
    this.isOnline,
    this.lastSeen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Handle the container click event
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyChatPage()),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipOval(
                    child: Image.asset(
                      profilePictureUrl!,
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover, // Make the image fit inside the circle
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shortenText(lastMessage!, 4),
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      Text(
                        messageTime!,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String shortenText(String text, int maxWords) {
    List<String> words = text.split(' ');
    if (words.length > maxWords) {
      words = words.sublist(0, maxWords);
      return '${words.join(' ')}...';
    } else {
      return text;
    }
  }
}
