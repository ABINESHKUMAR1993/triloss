// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

// class VideoCallScreen extends StatefulWidget {
//   final String userName;
//   final String callID;

//   const VideoCallScreen({
//     super.key,
//     required this.userName,
//     required this.callID,
//   });

//   @override
//   VideoCallScreenState createState() => VideoCallScreenState();
// }

// class VideoCallScreenState extends State<VideoCallScreen> {
//   bool isMuted = false;
//   int elapsedSeconds = 0;
//   late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         elapsedSeconds++;
//       });
//     });
//   }

//   String _formatTime(int seconds) {
//     int hours = seconds ~/ 3600;
//     int minutes = (seconds % 3600) ~/ 60;
//     int remainingSeconds = seconds % 60;
//     return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }

//   void toggleMute() {
//     setState(() {
//       isMuted = !isMuted;
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           ZegoUIKitPrebuiltVideoConference(
//             appID: 939412768, // Replace with your actual App ID
//             appSign:
//                 "ef0bafcc33a7499b9efd4cc2f3cd051c239fc9c63b2bec6610904cd3e0fe4707", // Replace with your actual App Sign
//             userID: widget.userName, // Ensure this is not empty
//             userName: widget.userName,
//             conferenceID: widget.callID, // Ensure this is not empty
//             config: ZegoUIKitPrebuiltVideoConferenceConfig(),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 30.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   FloatingActionButton(
//                     heroTag: 'mute',
//                     onPressed: toggleMute,
//                     backgroundColor: Colors.grey.shade200,
//                     child: Icon(
//                       isMuted ? Icons.mic_off : Icons.mic,
//                       color: Colors.blue,
//                     ),
//                   ),
//                   FloatingActionButton(
//                     heroTag: 'end_call',
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     backgroundColor: Colors.red,
//                     child: Icon(Icons.call_end, color: Colors.white),
//                   ),
//                   FloatingActionButton(
//                     heroTag: 'toggle_video',
//                     onPressed: () {
//                       // Implement video toggle logic if needed
//                     },
//                     backgroundColor: Colors.grey.shade200,
//                     child: Icon(Icons.videocam, color: Colors.blue),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 300,
//             left: 20,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.userName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   _formatTime(elapsedSeconds),
//                   style: const TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
