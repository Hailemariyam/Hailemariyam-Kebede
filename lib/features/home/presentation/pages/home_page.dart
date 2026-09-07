import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';
import '../bloc/home_bloc.dart';
import '../widgets/balance_card.dart';
import '../widgets/home_header.dart';
import '../widgets/services_card.dart';
import '../widgets/transactions_card.dart';

/// Home dashboard. Reads the signed-in [User] from [AuthRepository] and the
/// transactions feed from [HomeBloc]. No bottom navigation bar — a single
/// scrolling surface with a scan FAB.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = sl<AuthRepository>().currentSession;

    // Defensive: without a session there is nothing to show — bounce to login.
    if (session == null) {
      return const SignInPage();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (_) => sl<HomeBloc>()..add(const HomeStarted()),
        ),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
      ],
      child: _HomeView(user: session.user),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({required this.user});

  final User user;

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.signOutConfirmTitle),
        content: const Text(AppStrings.signOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text(AppStrings.signOut),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(Iconsax.scan_barcode),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            context.read<HomeBloc>().add(const HomeRefreshed());
            await context
                .read<HomeBloc>()
                .stream
                .firstWhere((s) => s.status != HomeStatus.loading);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              GestureDetector(
                onLongPress: () => _confirmSignOut(context),
                child: HomeHeader(
                  user: user,
                  onNotifications: () {},
                ),
              ),
              const SizedBox(height: 4),
              BalanceCard(user: user),
              const ServicesCard(),
              const TransactionsCard(),
            ],
          ),
        ),
      ),
    );
  }
}
