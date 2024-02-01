import 'package:chat_app/chatlist.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sendbird Chat App',
      theme: ThemeData.light(), // Set your default light theme
      darkTheme: ThemeData.dark(), // Set your default dark theme
      themeMode: ThemeMode.system,
      home: const ChatListScreen(),
    );
  }
}
