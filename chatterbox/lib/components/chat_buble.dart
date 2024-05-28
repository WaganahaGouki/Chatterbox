import 'package:chatterbox/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final bool isImage;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.isImage
  });

  @override
  Widget build(BuildContext context){
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    if(isImage) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Image.network(
              message,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            )
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:isCurrentUser ?
            (isDarkMode ? Colors.green.shade600 : Colors.green.shade400 )
                : (isDarkMode ? Colors.grey.shade800: Colors.grey.shade200)
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        child: Text(
          message,
          style: TextStyle(color:
          (isDarkMode ? Colors.white : Colors.black)),),
      );
    }
  }
}