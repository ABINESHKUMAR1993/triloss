// class UserCard extends StatelessWidget {
//   final UserModel user;

//   const UserCard({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final TextStyle infoTextStyle = TextStyle(
//       color: Colors.grey[600],
//       fontSize: 14,
//     );

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => UserProfile(userName: user.name),
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey[200]!),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildUserAvatar(),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildHeader(),
//                       const SizedBox(height: 4),
//                       Text('${user.gender}, ${user.age}', style: infoTextStyle),
//                       Text(user.location, style: infoTextStyle),
//                       const SizedBox(height: 4),
//                       Text(user.languages.join(', '), style: infoTextStyle),
//                       const SizedBox(height: 8),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Text(
//                     'Expert on: ${user.interests.join(', ')}',
//                     style: TextStyle(fontSize: 13, color: Colors.grey),
//                   ),
//                 ),
//                 _buildActionButtons(),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildUserAvatar() {
//     return Container(
//       width: 80,
//       height: 80,
//       decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.pink),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(30),
//         child: Image.asset(
//           'assets/images/png/image.png',
//           width: 80,
//           height: 80,
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Text(
//               user.name,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(width: 8),
//           ],
//         ),
//         Row(
//           children: [
//             Container(
//               width: 8,
//               height: 8,
//               decoration: const BoxDecoration(
//                 color: Colors.green,
//                 shape: BoxShape.circle,
//               ),
//             ),
//             const Text(
//               '  Online',
//               style: TextStyle(color: Colors.green, fontSize: 12),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         _ActionButton(
//           icon: Icons.phone,
//           onTap: () {
//             Get.to(() => AudioCallScreen());
//           },
//         ),
//         const SizedBox(width: 8),
//         _ActionButton(
//           icon: Icons.message,
//           onTap: () {
//             Get.to(() => ChatPage());
//           },
//         ),
//         const SizedBox(width: 8),
//         _ActionButton(
//           icon: Icons.video_call,
//           onTap: () {
//             Get.to(() => VideoCallScreen());
//           },
//         ),
//       ],
//     );
//   }
// }class UserModel {
//   final String name;
//   final int age;
//   final String gender;
//   final String location;
//   final List<String> languages;
//   final List<String> interests;

//   UserModel({
//     required this.name,
//     required this.age,
//     required this.gender,
//     required this.location,
//     required this.languages,
//     required this.interests,
//   });
// }
