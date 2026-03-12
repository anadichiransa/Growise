import 'package:flutter/material.dart';
import 'activity_page.dart';

class PlayAndLearnMenu extends StatelessWidget {
  const PlayAndLearnMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {"title": "How to wash hands ?", "icon": Icons.back_hand, "step": 1},
      {"title": "How to brush teeth ?", "icon": Icons.brush, "step": 1},
      {"title": "type here", "icon": Icons.email_outlined, "step": 1},
      {"title": "type here", "icon": Icons.email_outlined, "step": 1},
      {"title": "type hete", "icon": Icons.email_outlined, "step": 1},
      {"title": "type here", "icon": Icons.email_outlined, "step": 1},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Play & Learn"), // [cite: 1]
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B1B45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: Icon(items[index]['icon'], color: const Color(0xFFD9A577)),
              title: Text(items[index]['title'], style: const TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {
                // Example navigation to the activity page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActivityPage(
                    title: "Washing Hands", 
                    subtitle: "Let's Get Wet!", 
                    videoPath: "assets/washing_hands.mp4",
                  )),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2, // [cite: 16] Highlights 'Education'
      backgroundColor: const Color(0xFF1B0B3B),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFD9A577),
      unselectedItemColor: Colors.white38,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"), // [cite: 14]
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Tracker"), // [cite: 15]
        BottomNavigationBarItem(icon: Icon(Icons.school), label: "Education"), // [cite: 16]
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Support"), // [cite: 17]
      ],
    );
  }
}