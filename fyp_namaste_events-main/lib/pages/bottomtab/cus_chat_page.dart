import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:roopkatha/UI/pages/customer/bottomtab/bottomtab.dart';

import '../../service/notification_page.dart';
import 'package:roopkatha/UI/pages/customer/bottomtab/chat_screen.dart';
import 'package:roopkatha/UI/pages/customer/bottomtab/new_chat.dart';
import '../customer_shared_preferences.dart';

class CusChatPage extends StatefulWidget {
  const CusChatPage({super.key});

  @override
  State<CusChatPage> createState() => _CusChatPageState();
}

class _CusChatPageState extends State<CusChatPage> {
  List<dynamic> conversations = [];
  bool isLoading = false;
  String? customerId;

  @override
  void initState() {
    super.initState();
    _loadCustomerIdAndConversations();
  }

  Future<void> _loadCustomerIdAndConversations() async {
    customerId = await CustomerSharedPreferences.getCustomerID();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() {
      isLoading = true;
    });
    // Use participantId and participantModel as per backend
    final response = await http.get(Uri.parse(
      'http://10.0.2.2:8000/api/chats?participantId=$customerId&participantModel=Customer'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        conversations = data['chats'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Failed to load conversations');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _createNewChat() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewChatPage()),
    );
    if (result == true) {
      _fetchConversations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Messages', style: TextStyle(color: Colors.pink)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.pink),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(token: ''),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.pink),
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : conversations.isEmpty
                    ? const Center(child: Text('No conversations yet'))
                    : ListView.separated(
                        itemCount: conversations.length,
                        separatorBuilder: (_, __) => const Divider(indent: 85),
                        itemBuilder: (context, idx) {
                          final conv = conversations[idx];
                          final participants = conv['participants'] as List<dynamic>;
                          final artist = participants.firstWhere(
                            (p) => p['participantModel'] == 'Artist',
                            orElse: () => null,
                          );

                          String artistName = 'Artist';
                          String artistAvatar = 'https://via.placeholder.com/100';

                          if (artist != null) {
                            final participantId = artist['participantId'];
                            if (participantId is Map) {
                              artistName = participantId['name'] ?? 'Artist';
                              artistAvatar = participantId['profilePictureUrl'] ?? 'https://via.placeholder.com/100';
                            } else if (participantId is String) {
                              // Fetch artist details from backend if only ID is present
                              return FutureBuilder<http.Response>(
                                future: http.get(Uri.parse('http://10.0.2.2:8000/api/artist/$participantId')),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.pink.shade50,
                                        radius: 25,
                                      ),
                                      title: Text('Loading...'),
                                    );
                                  }
                                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.statusCode != 200) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.pink.shade50,
                                        radius: 25,
                                      ),
                                      title: Text('Artist'),
                                    );
                                  }
                                  final artistData = jsonDecode(snapshot.data!.body);
                                  final name = artistData['name'] ?? 'Artist';
                                  final avatar = artistData['profilePictureUrl'] ?? 'https://via.placeholder.com/100';
                                  final lastMessage = conv['lastMessage']?['content'] ?? '';
                                  final lastMessageTime = conv['lastMessage']?['createdAt'] != null
                                      ? DateTime.parse(conv['lastMessage']['createdAt'])
                                      : null;
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(avatar),
                                      radius: 25,
                                    ),
                                    title: Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: lastMessageTime != null
                                        ? Text(
                                            DateFormat('hh:mm a').format(lastMessageTime),
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                          )
                                        : null,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatScreen(
                                            chatId: conv['_id'],
                                            customerId: customerId!,
                                            customerModel: 'Customer',
                                            otherUserName: name,
                                            otherUserAvatar: avatar,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          }

                          final lastMessage = conv['lastMessage']?['content'] ?? '';
                          final lastMessageTime = conv['lastMessage']?['createdAt'] != null
                              ? DateTime.parse(conv['lastMessage']['createdAt'])
                              : null;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(artistAvatar),
                              radius: 25,
                            ),
                            title: Text(
                              artistName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: lastMessageTime != null
                                ? Text(
                                    DateFormat('hh:mm a').format(lastMessageTime),
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  )
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    chatId: conv['_id'],
                                    customerId: customerId!,
                                    customerModel: 'Customer',
                                    otherUserName: artistName,
                                    otherUserAvatar: artistAvatar,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: CusBottomTabs(currentIndex: 3),
    );
  }
}