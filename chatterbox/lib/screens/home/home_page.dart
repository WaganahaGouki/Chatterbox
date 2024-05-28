import 'package:chatterbox/components/my_tile.dart';
import 'package:chatterbox/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import '../../components/my_drawer.dart';
import '../chat/chat_page.dart';
import 'package:chatterbox/services/auth/auth_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: _chatService.getUsersStream(),
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return const Text("Error!");
          }
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }

          return ListView(
            children: snapshot.data!.map<Widget>((userData) => _buildUserListItem(userData, context)).toList(),
          );
        }
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    if(userData["email"] != _authService.getCurrentUser()!.email) {
      return MyTile(
        text: userData["username"],
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                    username: userData["username"],
                    receiverID: userData["uid"],
                  )
              )
          );
        },
      );
    }
    else {
      return Container();
    }
  }
}