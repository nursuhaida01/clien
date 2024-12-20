// import 'package:flutter/material.dart';
// import '../providers/queue_provider.dart';
// import 'package:provider/provider.dart';

// class Tab1 extends StatefulWidget {
//   @override
//   _Tab1State createState() => _Tab1State();
// }

// class _Tab1State extends State<Tab1> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<QueueProvider>(context, listen: false);
//       provider.fetchServices();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<QueueProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tab1 Example'),
//       ),
//       body: Center(
//         child: Text(
//           provider.services.length.toString(),
//           style: Theme.of(context).textTheme.headlineMedium,
//         ),
//       ),
//     );
//   }
// }
