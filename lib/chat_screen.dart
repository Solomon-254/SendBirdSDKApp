import 'package:chat_app/logger.dart';
import 'package:chat_app/util.dart';
import 'package:flutter/material.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

import 'model/request_model.dart';

class MyChatPage extends StatefulWidget {
  const MyChatPage({super.key});

  @override
  _MyChatPageState createState() => _MyChatPageState();
}

class _MyChatPageState extends State<MyChatPage> {
  String appId = 'BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF';
  String openChannelUrl =
      'sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211';
  String accessToken = 'sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211';
  var userName = 'Loading...';
  bool _isLoading = true;
  bool _isSendButtonEnabled = false;
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> messages = [];
  List<ChatMessage> othermessages = [];

  @override
  void initState() {
    super.initState();
    initializeSendbird();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllMessage();
      stopLoading();
    });  
    }

  @override
  void dispose() {
    SendbirdChat.disconnect();
    super.dispose();
  }

  Future<void> getAllMessage() async {
    if (SendbirdChat.isInitialized()) {
      logger.i('Sendbird is initialized. Fetching messages...');
      try {
        await fetchAllPreviousMessages();
      } catch (error) {
        logger.e('Error fetching messages: $error');
      }
    } else {
      logger.i('Sendbird is not initialized. Cannot fetch messages.');
    }
  }

  Future<void> fetchAllPreviousMessages() async {
    OpenChannel openChannel = await OpenChannel.getChannel(openChannelUrl);
    await openChannel.enter();

    // Set the timestamp to the minimum value to get all messages
    int allMessagesTimestamp = -999999999999;

    // Create a MessageListParams instance with the necessary parameters
    MessageListParams params = MessageListParams();

    List<RootMessage> allMessages = await openChannel.getMessagesByTimestamp(
      allMessagesTimestamp,
      params,
    );
    logger.i('All messages sent length: ${allMessages.length}');
    List<ChatMessage> chatMessages = allMessages.map((message) {
      if (message is UserMessage) {
        return ChatMessage(
          senderId: message.sender!.userId,
          message: message.message,
          timestamp: DateTime.fromMillisecondsSinceEpoch(message.createdAt),
        );
      } else {
        // Handle other message types if needed
        return ChatMessage(
          senderId: '',
          message: 'Unsupported Message Type',
          timestamp: DateTime.now(),
        );
      }
    }).toList();

    setState(() {
      messages.addAll(chatMessages);
    });
  }

  void stopLoading() {
    // Simulate a delay of 2 seconds
    Future.delayed(const Duration(seconds: 7), () {
      // Update the state to stop loading
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> initializeSendbird() async {
    // Step 1: Initialize the Chat SDK
    SendbirdChat.init(appId: appId);

    // Step 2: Connect to Sendbird server
    final user =
        await SendbirdChat.connect('solomon', accessToken: accessToken);
    logger.i(user.isActive);
    logger.i(user.userId);
    // Check if the connection is successful
    if (SendbirdChat.isInitialized()) {
      logger.i('Connected to Sendbird server successfully.');

      // Step 3: Enter the open channel
      final openChannel = await OpenChannel.getChannel(openChannelUrl);
      await openChannel.enter();

      logger.i('Participitant count ${openChannel.participantCount}');
      logger.i('First Operator ${openChannel.operators.first.nickname}');
      setState(() {
        userName = '강남스팟';
      });

      // Step 4: Send a message to the channel
      // final message = await openChannel.sendUserMessage(
      //     UserMessageCreateParams(message: 'Hello Juhyun Kim!'));
      // logger.i(message.message);

      // Step 5: Receive a message
      SendbirdChat.addChannelHandler(
        'unique_handler_id',
        MyOpenChannelHandler((chatMessage) {
          setState(() {
            othermessages.add(chatMessage);
            logger.i(othermessages.length);
          });
        }),
      );
    } else {
      logger.i('Connection to Sendbird server failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          userName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {

            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.pink,
            ))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: _buildMessageWidget(messages[index], true),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _buildMessageInput(),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20.0), // Set the desired border radius
        border:
            Border.all(color: Colors.grey), // Add a border with a grey color
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.pink,
                size: 30,
              ),
              onPressed: () {
                setState(() {});
              },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Theme.of(context).backgroundColor,
                ),
                child: TextField(
                  controller: _messageController,
                  onChanged: (text) {
                    setState(() {
                      _isSendButtonEnabled = text.isNotEmpty;
                    });
                  },
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: '안녕하세요...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_upward,
                  color: _isSendButtonEnabled ? Colors.pink : Colors.grey),
              onPressed: _isSendButtonEnabled
                  ? () {
                      sendMessage(_messageController.text);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendMessage(String messageText) async {
    dismissKeyboard();
    // Check if the connection is successful
    if (SendbirdChat.isInitialized()) {
      logger.i('Trying to send messages....');
      try {
        OpenChannel openChannel = await OpenChannel.getChannel(openChannelUrl);

        final user =
            await SendbirdChat.connect('solomon', accessToken: accessToken);
        logger.i(user.isActive);
        logger.i(user.userId);
        await openChannel.enter();

        final message = await openChannel
            .sendUserMessage(UserMessageCreateParams(message: messageText));
        logger.i(message.message);

        if (message != null) {
          ChatMessage chatMessage = ChatMessage(
            senderId: message.sender!.userId,
            message: messageText,
            timestamp: DateTime.now(),
          );

          _messageController.clear();
          setState(() {
            messages.add(chatMessage);
          });
        } else {
          logger.e('Failed to send message: $messageText');
        }
      } catch (error) {
        logger.e('Error sending message: $error');
      }
    }
  }

  Widget _buildMessageWidget(ChatMessage chatMessage, bool isDarkMode) {
    // Check if the message is sent by the current user
    bool isCurrentUser =
        chatMessage.senderId == SendbirdChat.currentUser?.userId;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Colors.pink
              : (isDarkMode ? Colors.grey : Colors.white),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Row(
                children: [
                  CircleAvatar(
                    // You need to set the profile image for other users
                    // chatMessage.senderProfileImage,
                    radius: 16.0,
                  ),
                  SizedBox(width: 8.0),
                ],
              ),
            Text(
              chatMessage.message,
              style:
                  TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
            ),
            Text(
              // Format timestamp as needed
              '${chatMessage.timestamp.hour}:${chatMessage.timestamp.minute}',
              style: TextStyle(
                  color: isCurrentUser ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class MyOpenChannelHandler extends OpenChannelHandler {
  final Function(ChatMessage) onMessageReceivedCallback;
  MyOpenChannelHandler(this.onMessageReceivedCallback);
  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    logger.i('Received message: ${message.message}');
    logger.i(message.sender);
    if (message is UserMessage) {
      ChatMessage chatMessage = ChatMessage(
        senderId: message.sender!.userId,
        message: message.message,
        timestamp: DateTime.fromMillisecondsSinceEpoch(message.createdAt),
      );

      // Call the callback function to update UI
      onMessageReceivedCallback(chatMessage);
    }
  }
}
