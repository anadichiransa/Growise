import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; //

class ActivityPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String videoPath;

  const ActivityPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.videoPath,
  });

    @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late VideoPlayerController _controller;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    // Initialize the video controller with the provided asset path
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the tree
    _controller.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      // Set volume to 0 for mute, or 1 for full sound
      _controller.setVolume(_isMuted ? 0 : 1); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B0B3B),
      body: SafeArea(
        child: Column(
          children: [
            // 1. App Bar with Back Button and Mute Toggle
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circularIconButton(Icons.arrow_back, Colors.white12, () {
                    Navigator.pop(context); // Go back to the menu
                  }),
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  _circularIconButton(
                    _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    const Color(0xFFD9A577),
                    _toggleMute,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(
              widget.subtitle,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 2. Video Player Container
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.black,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : const Center(
                          child: CircularProgressIndicator(color: Color(0xFFD9A577)),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 3. Instructional Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Follow the steps in the video to complete your task!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, height: 1.5),
              ),
            ),

            const SizedBox(height: 30),

            // 4. "I DID IT!" Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  _controller.pause(); // Stop video before leaving
                  Navigator.pop(context); // Return to the menu page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  elevation: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "I DID IT!",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for the circular buttons in the app bar
  Widget _circularIconButton(IconData icon, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}