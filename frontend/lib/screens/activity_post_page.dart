import 'package:flutter/material.dart';
import '../models/activity_post.dart';
import '../services/activity_post_service.dart';

class ActivityPostPage extends StatefulWidget {
  final int portId;

  const ActivityPostPage({super.key, required this.portId});

  @override
  State<ActivityPostPage> createState() => _ActivityPostPageState();
}

class _ActivityPostPageState extends State<ActivityPostPage> {
  late Future<List<ActivityPost>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = ActivityPostService.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text("Activity"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<ActivityPost>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("เกิดข้อผิดพลาด"));
          }

          final posts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 Header
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        post.title ?? "No Title",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(post.description ?? ""),
                    ),

                    /// 🔹 Image
                    if (post.picture != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                        child: Image.network(
                          post.picture!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
