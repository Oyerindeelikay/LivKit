import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> statuses = [
    {
      "name": "Samuel",
      "avatar": "https://i.pravatar.cc/150?img=1",
      "time": "5m ago",
      "type": "image",
      "file": null
    },
    {
      "name": "John",
      "avatar": "https://i.pravatar.cc/150?img=2",
      "time": "10m ago",
      "type": "video",
      "file": null
    },
  ];

  File? myStatusFile;

  Future<void> _pickStatus(ImageSource source, String type) async {
    final XFile? pickedFile;
    if (type == "image") {
      pickedFile = await _picker.pickImage(source: source);
    } else {
      pickedFile = await _picker.pickVideo(source: source);
    }

    if (pickedFile != null) {
      setState(() {
        myStatusFile = File(pickedFile.path);
        statuses.insert(0, {
          "name": "Your Status",
          "avatar": "https://i.pravatar.cc/150?img=10",
          "time": "Just now",
          "type": type,
          "file": myStatusFile
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkAsh = const Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: darkAsh,
      appBar: AppBar(
        backgroundColor: darkAsh,
        elevation: 0,
        title: const Text(
          "Status",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isMyStatus = status["name"] == "Your Status";

          return ListTile(
            leading: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      isMyStatus ? Colors.grey[800] : Colors.transparent,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(status["avatar"]),
                  ),
                ),
                if (!isMyStatus)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.redAccent,
                        width: 2,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              status["name"],
              style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              status["time"],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            trailing: isMyStatus
                ? IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: darkAsh,
                        builder: (_) => SizedBox(
                          height: 150,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo, color: Colors.white),
                                title: const Text(
                                  "Upload Image",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickStatus(ImageSource.gallery, "image");
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.videocam, color: Colors.white),
                                title: const Text(
                                  "Upload Video",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickStatus(ImageSource.gallery, "video");
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : null,
            onTap: () {
              // Show full screen status
              if (status["file"] != null) {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.black,
                    child: status["type"] == "image"
                        ? Image.file(status["file"])
                        : const Center(
                            child: Icon(Icons.videocam, color: Colors.white),
                          ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
