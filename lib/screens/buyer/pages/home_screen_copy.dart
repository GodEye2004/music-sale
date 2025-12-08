// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/screens/producer/dashboard_screen.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_application_1/config/supabase_config.dart';
// import 'package:flutter_application_1/config/theme.dart';
// import 'package:flutter_application_1/models/beat_model.dart';
// import 'package:flutter_application_1/services/auth_service.dart';
// import 'package:flutter_application_1/screens/buyer/pages/beat_detail_screen.dart';
// import 'package:flutter_application_1/widgets/beat_card.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final AuthService _auth = AuthService();
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     // Listen to search changes to update UI
//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery = _searchController.text.toLowerCase().trim();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = _auth.currentUser;

//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       appBar: AppBar(
//         title: const Text('فروشگاه بیت'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.exit_to_app),
//             onPressed: () async {
//               await _auth.logout();
//               if (mounted) {
//                 Navigator.of(context).pushReplacementNamed('/');
//               }
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar & Welcome Header
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: const BoxDecoration(
//               color: AppTheme.surfaceColor,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(24),
//                 bottomRight: Radius.circular(24),
//               ),
//             ),
//             child: Column(
//               children: [
//                 if (user != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           backgroundColor: AppTheme.primaryColor,
//                           child: Text(
//                             user.displayName[0].toUpperCase(),
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'سلام، ${user.displayName}',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             Text(
//                               user.isProducer() ? 'پنل پرودیوسر' : 'خریدار',
//                               style: const TextStyle(
//                                 color: AppTheme.primaryColor,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: 'جستجوی بیت (نام، ژانر...)',
//                     prefixIcon: const Icon(Icons.search),
//                     filled: true,
//                     fillColor: AppTheme.backgroundColor,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Real-time Beat List
//           Expanded(
//             child: StreamBuilder<List<Map<String, dynamic>>>(
//               stream: Supabase.instance.client
//                   .from(SupabaseConfig.beatsTable)
//                   .stream(primaryKey: ['id'])
//                   .order('created_at', ascending: false),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (snapshot.hasError) {
//                   return Center(
//                     child: Text(
//                       'خطا در دریافت اطلاعات: ${snapshot.error}',
//                       style: const TextStyle(color: AppTheme.errorColor),
//                     ),
//                   );
//                 }

//                 final beatMaps = snapshot.data ?? [];

//                 if (beatMaps.isEmpty) {
//                   print('⚠️ No beats found in Supabase response');
//                   return const Center(child: Text('هنوز بیتی آپلود نشده است'));
//                 }

//                 print('✅ Fetched ${beatMaps.length} beats from Supabase');
//                 // print('First beat raw data: ${beatMaps.first}');

//                 // 1. Convert to Objects
//                 final allBeats = beatMaps
//                     .map((map) {
//                       try {
//                         return Beat.fromJson(map);
//                       } catch (e) {
//                         print('❌ Error parsing beat: $e');
//                         return null;
//                       }
//                     })
//                     .whereType<Beat>()
//                     .toList();

//                 // 2. Client-side Filtering
//                 final filteredBeats = allBeats.where((beat) {
//                   return beat.title.toLowerCase().contains(_searchQuery) ||
//                       beat.genre.toLowerCase().contains(_searchQuery) ||
//                       (beat.tags
//                               ?.join(' ')
//                               .toLowerCase()
//                               .contains(_searchQuery) ??
//                           false);
//                 }).toList();

//                 if (filteredBeats.isEmpty) {
//                   return const Center(child: Text('نتیجه‌ای یافت نشد'));
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: filteredBeats.length,
//                   itemBuilder: (context, index) {
//                     final beat = filteredBeats[index];
//                     return Container(
//                       height: 280,
//                       margin: const EdgeInsets.only(bottom: 16),
//                       child: BeatCard(
//                         beat: beat,
//                         onTap: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (_) => BeatDetailScreen(beat: beat),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
