import 'package:flutter/material.dart';
import '../models/activity_post.dart';
import '../services/activity_post_service.dart';
import 'package:intl/intl.dart';
import 'activity_history_page.dart';
import 'activity_port_detail.dart';
import 'create_activity_page.dart';

class ActivityPostPage extends StatefulWidget {
  final int portId;
  final int userId;

  const ActivityPostPage({
    super.key,
    required this.portId,
    required this.userId,
  });

  @override
  State<ActivityPostPage> createState() => _ActivityPostPageState();
}

class _ActivityPostPageState extends State<ActivityPostPage> {
  late Future<List<ActivityPost>> _futurePosts;
  Map<int, bool> followStatus = {};

  @override
  void initState() {
    super.initState();
    _futurePosts = ActivityPostService.fetchPosts();
    _loadFollowStatus();
  }

  void _loadFollowStatus() async {
    final followedIds = await ActivityPostService.getFollowedActivities(
      widget.userId,
    );

    setState(() {
      for (var id in followedIds) {
        followStatus[id] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// 🔥 TABS (เหมือนหน้า Port)
              Row(
                children: [
                  _TabButton(
                    title: 'MY ACTIVITY',
                    isActive: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActivityPortDetailPage(
                            portId: widget.portId,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const _TabButton(title: 'ACTIVITY', isActive: true),
                  const SizedBox(width: 8),
                  _TabButton(
                    title: 'HISTORY',
                    isActive: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActivityHistoryPage(
                            portId: widget.portId,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 🔙 BACK
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back_ios, size: 14, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        'BACK',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔥 LIST
              Expanded(
                child: FutureBuilder<List<ActivityPost>>(
                  future: _futurePosts,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final posts = snapshot.data!;

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];

                        final formattedDate = post.datetimeOfActivity != null
                            ? DateFormat(
                                'dd MMM yyyy • HH:mm',
                              ).format(post.datetimeOfActivity!)
                            : "-";

                        final isFollowed =
                            followStatus[post.activityPostID] ?? false;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// STAFF HEADER
                              const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Color(0xFFE5E5EA),
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "STAFF",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              /// TITLE
                              Text(
                                post.title ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 8),

                              /// DESCRIPTION
                              Text(
                                post.description ?? "",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF3C3C43),
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// DATE
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Color(0xFF8E8E93),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Color(0xFF8E8E93),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      post.location ?? "-",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8E8E93),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              /// HOUR
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Color(0xFF34C759),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${post.hourOfActivity ?? 0} ชั่วโมงกิจกรรม",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF34C759),
                                    ),
                                  ),
                                ],
                              ),

                              /// IMAGE
                              if (post.picture != null &&
                                  post.picture!.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.network(
                                    post.picture!,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  /// FOLLOW BUTTON
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: isFollowed
                                          ? Colors.red
                                          : Colors.deepPurple,
                                    ),
                                    onPressed: () async {
                                      final result =
                                          await ActivityPostService.toggleFollow(
                                            activitypostId:
                                                post.activityPostID!,
                                            userId: widget.userId,
                                          );

                                      setState(() {
                                        followStatus[post.activityPostID!] =
                                            result;
                                      });
                                    },
                                    icon: Icon(
                                      isFollowed
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 16,
                                    ),
                                    label: Text(
                                      isFollowed ? "Following" : "Follow",
                                    ),
                                  ),

                                  /// ทำกิจกรรม
                                  TextButton.icon(
                                    onPressed: () {
                                      // โค้ดเดิมของมอส
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                    ),
                                    label: const Text("ทำกิจกรรม"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback? onTap;

  const _TabButton({required this.title, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
