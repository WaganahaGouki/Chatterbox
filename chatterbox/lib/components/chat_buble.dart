import 'dart:convert';
import 'package:chatterbox/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final bool isImage;
  final bool isVoice;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.isImage,
    required this.isVoice,
  });

  @override
  Widget build(BuildContext context){
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    if (isVoice) {
      return GestureDetector(
        onTap: () async {
          final player = FlutterSoundPlayer();
          await player.openPlayer();
          await player.startPlayer(fromDataBuffer: base64Decode(message));
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isCurrentUser
                ? (isDarkMode ? Colors.green.shade600 : Colors.green.shade400)
                : (isDarkMode ? Colors.green.shade800 : Colors.green.shade200),
          ),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
          child: Icon(
            Icons.play_arrow,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      );
    }
    else {
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
}