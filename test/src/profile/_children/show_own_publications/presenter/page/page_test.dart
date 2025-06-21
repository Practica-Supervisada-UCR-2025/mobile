// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// import 'package:mobile/core/globals/publications/publications.dart';
// import 'package:mobile/src/profile/_children/_children.dart';

// void main() {
//   testWidgets(
//     'ShowOwnPublicationsPage builds the BlocProvider and displays PublicationsList',
//     (WidgetTester tester) async {
//       final router = GoRouter(
//         routes: [
//           GoRoute(
//             path: '/',
//             builder: (context, state) => const ShowOwnPublicationsPage(),
//           ),
//         ],
//       );

//       await tester.pumpWidget(MaterialApp.router(routerConfig: router));

//       await tester.pumpAndSettle();

//       expect(find.byType(BlocProvider<PublicationBloc>), findsOneWidget);
//       expect(find.byType(PublicationsList), findsOneWidget);
//     },
//   );

//   testWidgets(
//     'When PublicationsList fails and Retry is pressed, the error message reappears',
//     (WidgetTester tester) async {
//       final failureBloc = PublicationBloc(
//         publicationRepository: _FakeFailureRepository(),
//       );

//       await tester.pumpWidget(
//         MaterialApp(
//           home: BlocProvider<PublicationBloc>.value(
//             value: failureBloc,
//             child: const PublicationsList(scrollKey: "homePage", isFeed: true, isOtherUser: false),
//           ),
//         ),
//       );

//       failureBloc.add(LoadPublications());

//       await tester.pumpAndSettle();

//       expect(find.text('Failed to load posts'), findsOneWidget);
//       expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);

//       await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
//       failureBloc.add(LoadPublications());

//       await tester.pumpAndSettle();

//       expect(find.text('Failed to load posts'), findsOneWidget);
//       expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
//     },
//   );
// }

// class _FakeFailureRepository implements PublicationRepository {
//   @override
//   Future<PublicationResponse> fetchPublications({
//     required int page,
//     required int limit,
//     required String time,
//     required bool isOtherUser,
//   }) async {
//     await Future.delayed(const Duration(milliseconds: 50));
//     throw Exception('simulated failure');
//   }
// }
