import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final bool isListening;
  final bool isPlaying;
  final Animation<double> pulseAnimation;
  final VoidCallback onMicPressed;
  final VoidCallback onMicReleased;
  final VoidCallback onSpeakerPressed;

  const ActionButtons({
    Key? key,
    required this.isListening,
    required this.isPlaying,
    required this.pulseAnimation,
    required this.onMicPressed,
    required this.onMicReleased,
    required this.onSpeakerPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Microphone button
        GestureDetector(
          onTapDown: (_) => onMicPressed(),
          onTapUp: (_) => onMicReleased(),
          onTapCancel: () => onMicReleased(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: isListening
                  ? theme.colorScheme.primary.withOpacity(0.8)
                  : theme.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isListening
                      ? theme.colorScheme.primary.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.3),
                  spreadRadius: isListening ? 4 : 1,
                  blurRadius: isListening ? 8 : 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isListening ? pulseAnimation.value : 1.0,
                    child: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: isListening
                          ? Colors.white
                          : theme.colorScheme.primary,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // TTS button
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: isPlaying
                ? theme.colorScheme.primary.withOpacity(0.8)
                : theme.colorScheme.secondaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isPlaying
                    ? theme.colorScheme.primary.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.3),
                spreadRadius: isPlaying ? 4 : 1,
                blurRadius: isPlaying ? 8 : 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onSpeakerPressed,
            icon: Icon(
              isPlaying ? Icons.stop : Icons.volume_up,
              color: isPlaying ? Colors.white : theme.colorScheme.primary,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}