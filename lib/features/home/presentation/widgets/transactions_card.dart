import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/home_bloc.dart';
import 'transaction_tile.dart';

/// White card: "Transactions" header with a "See all" action, then the list —
/// or a loading / error / empty state.
class TransactionsCard extends StatelessWidget {
  const TransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                AppStrings.transactions,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Text(
                    AppStrings.seeAll,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              switch (state.status) {
                case HomeStatus.initial:
                case HomeStatus.loading:
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                case HomeStatus.failure:
                  return Column(
                    children: [
                      const Icon(Iconsax.warning_2,
                          color: AppColors.error, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage ??
                            'Could not load transactions.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => context
                            .read<HomeBloc>()
                            .add(const HomeRefreshed()),
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                case HomeStatus.success:
                  if (state.transactions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No transactions yet')),
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < state.transactions.length; i++)
                        TransactionTile(
                          transaction: state.transactions[i],
                          isLast: i == state.transactions.length - 1,
                        ),
                    ],
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}
