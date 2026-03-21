import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpRecoveryScreen extends StatefulWidget {
  const HelpRecoveryScreen({super.key});

  @override
  State<HelpRecoveryScreen> createState() => _HelpRecoveryScreenState();
}

class _HelpRecoveryScreenState extends State<HelpRecoveryScreen> {
  final List<Map<String, dynamic>> _allHelpItems = [
    {
      "title": "How to reset my password?",
      "icon": Icons.vpn_key_outlined,
      "content":
          "To reset your password, tap on 'Forgot Password' on the login screen. Enter your registered email address, and we will send you a link to set a new password.",
      "isExpanded": true,
    },
    {
      "title": "Didn't receive reset email?",
      "icon": Icons.email_outlined,
      "content":
          "Check your spam folder. If it's not there, wait 5 minutes before requesting a new link. Ensure your email matches your registered account.",
      "isExpanded": false,
    },
    {
      "title": "How to recover my username?",
      "icon": Icons.person_outline,
      "content":
          "Tap 'Forgot Username' on the login page. We will send your username to your registered mobile number via SMS.",
      "isExpanded": false,
    },
    {
      "title": "Account lockout issues",
      "icon": Icons.shield_outlined,
      "content":
          "Accounts are temporarily locked after 5 failed attempts. Please wait 30 minutes or contact support to verify your identity.",
      "isExpanded": false,
    },
  ];

  late List<Map<String, dynamic>> _filteredItems;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _filteredItems = _allHelpItems;
  }

  void _filterSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredItems = _allHelpItems;
      } else {
        _filteredItems = _allHelpItems
            .where(
              (item) => item['title'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1335),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1335),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Help & Recovery",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2D1B3D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: _filterSearch,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search for issues...",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ExpandableHelpCard(
                    key: ValueKey(item['title']),
                    title: item['title'],
                    icon: item['icon'],
                    description: item['content'],
                    isInitiallyExpanded: _searchQuery.isEmpty
                        ? item['isExpanded']
                        : false,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed('/support'),
                icon: const Icon(Icons.headset_mic, color: Colors.black),
                label: const Text(
                  "Contact Support",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9A577),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SimpleBottomNav(),
    );
  }
}

class ExpandableHelpCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String description;
  final bool isInitiallyExpanded;

  const ExpandableHelpCard({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.isInitiallyExpanded = false,
  });

  @override
  State<ExpandableHelpCard> createState() => _ExpandableHelpCardState();
}

class _ExpandableHelpCardState extends State<ExpandableHelpCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B1B45),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: widget.isInitiallyExpanded,
          onExpansionChanged: (bool expanded) =>
              setState(() => _isExpanded = expanded),
          leading: Icon(widget.icon, color: const Color(0xFFD9A577)),
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.white,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => debugPrint("Action: ${widget.title}"),
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 2.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "GO TO RESET",
                              style: TextStyle(
                                color: Color(0xFFD9A577),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              color: Color(0xFFD9A577),
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleBottomNav extends StatelessWidget {
  const SimpleBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      backgroundColor: const Color(0xFF150B25),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFD9A577),
      unselectedItemColor: Colors.white54,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: "Tracker",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: "Education",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Support",
        ),
      ],
      onTap: (index) {},
    );
  }
}
