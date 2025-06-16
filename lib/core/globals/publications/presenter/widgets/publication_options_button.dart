import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';

class PublicationOptionsButton extends StatelessWidget {
  final String publicationId;
  final String publicationUsername;

  const PublicationOptionsButton({
    super.key,
    required this.publicationId,
    required this.publicationUsername,
  });

  void showReportBottomSheet(BuildContext context) {
    context.read<ReportPublicationBloc>().add(ReportPublicationReset());
    final publicationBloc = context.read<PublicationBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => BlocProvider.value(
            value: publicationBloc,
            child: ReportBottomSheet(publicationId: publicationId),
          ),
    );
  }

  void showDeleteBottomSheet(BuildContext context) {
    context.read<DeletePublicationBloc>().add(DeletePublicationReset());
    final publicationBloc = context.read<PublicationBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => BlocProvider.value(
            value: publicationBloc,
            child: DeleteBottomSheet(publicationId: publicationId),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = LocalStorage().username == publicationUsername;

    return Builder(
      builder:
          (safeContext) => PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'report') {
                showReportBottomSheet(safeContext);
              } else if (value == 'delete') {
                showDeleteBottomSheet(safeContext);
              }
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[];

              if (isOwner) {
                items.add(
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                );
              } else {
                items.add(
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Report'),
                      ],
                    ),
                  ),
                );
              }
              return items;
            },
          ),
    );
  }
}
