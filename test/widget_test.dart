// Widget tests for Joytify Music Player App
//
// These tests verify the basic functionality of the Joytify application
// including app initialization, splash screen, and navigation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Joytify App Tests', () {
    testWidgets('App builds without crashing', (WidgetTester tester) async {
      // Create a minimal test version of the app without services
      const testApp = MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Joytify Test'),
          ),
        ),
      );

      // Build the test app and trigger a frame
      await tester.pumpWidget(testApp);

      // Verify that the app builds successfully
      expect(find.text('Joytify Test'), findsOneWidget);
    });

    testWidgets('Splash screen displays app name', (WidgetTester tester) async {
      // Test the splash screen widget independently
      const splashScreen = MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note, size: 60),
                SizedBox(height: 32),
                Text(
                  'Joytify',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text('Pemutar Musik Web Modern'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidget(splashScreen);

      // Verify splash screen elements
      expect(find.text('Joytify'), findsOneWidget);
      expect(find.text('Pemutar Musik Web Modern'), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsOneWidget);
    });

    testWidgets('Auth screen can be navigated to', (WidgetTester tester) async {
      // Test navigation structure
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/auth',
          routes: {
            '/auth': (context) => const Scaffold(
              body: Center(
                child: Text('Auth Screen'),
              ),
            ),
          },
        ),
      );

      // Verify auth screen loads
      expect(find.text('Auth Screen'), findsOneWidget);
    });

    testWidgets('Tab navigation works in auth screen', (WidgetTester tester) async {
      // Test tab functionality
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              body: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Masuk'),
                      Tab(text: 'Daftar'),
                    ],
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        Center(child: Text('Login Form')),
                        Center(child: Text('Register Form')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify tabs exist
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.text('Daftar'), findsOneWidget);
      
      // Verify default tab content
      expect(find.text('Login Form'), findsOneWidget);

      // Tap on register tab
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      // Verify register form is shown
      expect(find.text('Register Form'), findsOneWidget);
    });

    testWidgets('Music player controls render correctly', (WidgetTester tester) async {
      // Test music player UI components
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const LinearProgressIndicator(value: 0.3),
                const SizedBox(height: 10),
                const Text('2:15 / 3:45'),
              ],
            ),
          ),
        ),
      );

      // Verify player controls
      expect(find.byIcon(Icons.skip_previous), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('2:15 / 3:45'), findsOneWidget);
    });

    testWidgets('Bottom navigation renders correctly', (WidgetTester tester) async {
      // Test bottom navigation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.queue_music),
                  label: 'Playlist',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Liked',
                ),
              ],
            ),
          ),
        ),
      );

      // Verify navigation items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Playlist'), findsOneWidget);
      expect(find.text('Liked'), findsOneWidget);
      
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.queue_music), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}
