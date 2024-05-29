import 'dart:io';
import 'package:chatterbox/components/chat_buble.dart';
import 'package:chatterbox/components/my_textfield.dart';
import 'package:chatterbox/services/auth/auth_service.dart';
import 'package:chatterbox/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../permissions/permissions.dart';
import '../../services/audio/audio_recorder_service.dart';
import '../../themes/theme_provider.dart';

class ChatPage extends StatefulWidget {
  final String username;
  final String receiverID;

  const ChatPage({
    super.key,
    required this.username,
    required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  File? galleryFile;
  final picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  FocusNode myFocusNode = FocusNode();

  Future<void> initializeRecorder() async {
    await requestMicrophonePermission();
    await _audioRecorder.init();
  }

  @override
  void initState() {
    super.initState();
    initializeRecorder();

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void scrollDown(){
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickAndUploadImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickAndUploadImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        String downloadURL = await _uploadFile(imageFile);
        _sendMessage(downloadURL);
      } catch (e) {
        print('Upload Error: $e');
      }
    }
  }

  Future<String> _uploadFile(File file) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('chat_images/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  void _sendMessage(String imageUrl) {
    _chatService.sendMessage(widget.receiverID, imageUrl, true, false);

    scrollDown();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty){
      await _chatService.sendMessage(widget.receiverID, _messageController.text, false, false);
      _messageController.clear();
    }

    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.username),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError){
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      });
  }

  Widget _buildMessageItem(DocumentSnapshot doc){
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
        child: ChatBubble(message: data["message"], isCurrentUser: isCurrentUser, isImage: data["isImage"], isVoice: data["isVoice"],)
    );
  }

  Widget _buildUserInput(){
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.green.shade500 : Colors.green.shade400,
                shape: BoxShape.circle
              ),
              margin: const EdgeInsets.only(left: 15),
              child: IconButton(
                onPressed: () => _showPicker(context),
                icon: const Icon(Icons.image),
                color: Colors.white,)
            ),
            Expanded(child: MyTextfield(
              focusNode: myFocusNode,
              controller: _messageController,
              hintText: "Type a message",
              obscureText: false)),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.green.shade500 : Colors.green.shade400,
                shape: BoxShape.circle
              ),
              margin: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: sendMessage,
                icon: const Icon(Icons.arrow_upward),
                color: Colors.white,)
            ),
            Container(
              decoration: BoxDecoration(
                  color: isDarkMode ? Colors.green.shade500 : Colors.green.shade400,
                  shape: BoxShape.circle
              ),
              margin: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: () async {
                  if (_audioRecorder.isRecording) {
                    await _audioRecorder.stopRecording();
                    await ChatService().sendVoiceMessage(widget.receiverID, _audioRecorder.filePath!);
                  } else {
                    await _audioRecorder.startRecording();
                  }
                  setState(() {});
                },
                icon: Icon(_audioRecorder.isRecording ? Icons.stop : Icons.mic),
                color: Colors.white,
              )
            )
          ],
        )
    );
  }
}