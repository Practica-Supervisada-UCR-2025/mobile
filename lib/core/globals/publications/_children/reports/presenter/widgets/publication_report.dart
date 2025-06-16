import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';

class ReportBottomSheet extends StatefulWidget {
  final String publicationId;

  const ReportBottomSheet({super.key, required this.publicationId});

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  String selectedReason = 'Inappropriate content';
  String otherReasonText = '';

  final List<String> reasons = [
    'Inappropriate content',
    'It\'s spam',
    'Harassment or bullying',
    'False information',
    'Other reason',
  ];

  void onReasonSelected(String reason) {
    setState(() {
      selectedReason = reason;
      if (reason != 'Other reason') {
        otherReasonText = '';
      }
    });
  }

  void onOtherReasonChanged(String text) {
    setState(() {
      otherReasonText = text;
    });
  }

  String get finalReason {
    if (selectedReason == 'Other reason') {
      return otherReasonText.trim();
    }
    return selectedReason;
  }

  bool get isFormValid {
    if (selectedReason == 'Other reason') {
      return otherReasonText.trim().isNotEmpty;
    }
    return true;
  }

  void _closeAndReset() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ReportPublicationBloc, ReportPublicationState>(
      builder: (context, state) {
        Widget content;

        if (state is ReportPublicationSuccess) {
          content = FeedbackContent(
            icon: Icons.check_circle_outline,
            color: Colors.green,
            title: "Report sent",
            message:
                'Your report has been sent successfully.\nA moderator will review the post.',
            onClose: () => _closeAndReset(),
          );
        } else if (state is ReportPublicationFailure) {
          content = FeedbackContent(
            icon: Icons.cancel_outlined,
            color: Colors.red,
            title: 'An error occurred.',
            message: state.error,
            onClose: () => _closeAndReset(),
          );
        } else {
          final isLoading = state is ReportPublicationLoading;

          content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Report content',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Why are you reporting this post?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children:
                    reasons.map((reason) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ReportOption(
                          label: reason,
                          isSelected: selectedReason == reason,
                          onTap: () => onReasonSelected(reason),
                        ),
                      );
                    }).toList(),
              ),
              if (selectedReason == 'Other reason') ...[
                const SizedBox(height: 20),
                TextField(
                  maxLength: 255,
                  maxLines: 3,
                  onChanged: onOtherReasonChanged,
                  decoration: InputDecoration(
                    labelText: 'Describe the reason',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: () {
                    context.read<ReportPublicationBloc>().add(
                      ReportPublicationRequest(
                        publicationId: widget.publicationId,
                        reason: finalReason,
                      ),
                    );
                  },
                  text: "Send report",
                  isLoading: isLoading,
                  isEnabled: isFormValid && !isLoading,
                ),
              ),
            ],
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: content,
          ),
        );
      },
    );
  }
}
