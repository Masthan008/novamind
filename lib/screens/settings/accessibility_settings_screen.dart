import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/accessibility_provider.dart';
import '../../providers/theme_provider.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AccessibilityProvider, ThemeProvider>(
      builder: (context, accessibilityProvider, themeProvider, child) {
        return Container(
          decoration: themeProvider.getCurrentBackgroundDecoration(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Accessibility Settings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gesture Controls
                  _buildSectionCard(
                    context,
                    'Gesture Controls',
                    [
                      SwitchListTile(
                        title: Text(
                          'Enable Gesture Controls',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text(
                          'Navigate with swipe gestures',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: accessibilityProvider.gestureControlsEnabled,
                        onChanged: (value) {
                          accessibilityProvider.toggleGestureControls();
                          accessibilityProvider.provideFeedback(
                            text: value ? 'Gesture controls enabled' : 'Gesture controls disabled',
                          );
                        },
                      ),
                      if (accessibilityProvider.gestureControlsEnabled)
                        ListTile(
                          title: Text(
                            'Gesture Guide',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          subtitle: const Text(
                            '• Swipe right - Go back\n'
                            '• Swipe left - Open drawer\n'
                            '• Double tap - Select item\n'
                            '• Long press - Show options',
                          ),
                          trailing: const Icon(Icons.touch_app),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Other Accessibility Options
                  _buildSectionCard(
                    context,
                    'Other Options',
                    [
                      SwitchListTile(
                        title: Text(
                          'Haptic Feedback',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text(
                          'Vibration feedback for interactions',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: accessibilityProvider.hapticFeedbackEnabled,
                        onChanged: (value) {
                          accessibilityProvider.toggleHapticFeedback();
                          accessibilityProvider.provideFeedback(
                            text: value ? 'Haptic feedback enabled' : 'Haptic feedback disabled',
                            haptic: value,
                          );
                        },
                      ),
                      SwitchListTile(
                        title: Text(
                          'Reduce Animations',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text(
                          'Reduces motion for better accessibility',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: accessibilityProvider.reduceAnimations,
                        onChanged: (value) {
                          accessibilityProvider.toggleReduceAnimations();
                          accessibilityProvider.provideFeedback(
                            text: value ? 'Animations reduced' : 'Normal animations enabled',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}