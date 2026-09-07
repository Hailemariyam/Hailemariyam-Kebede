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
import '../widgets/promo_banner.dart';
import '../widgets/quick_actions.dart';
import '../widgets/transaction_tile.dart';

/// Home dashboard. Reads the signed-in [User] from [AuthRepository] and the
/// activity feed from [HomeBloc].
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
      bottomNavigationBar: const _HomeBottomNav(),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            context.read<HomeBloc>().add(const HomeRefreshed());
            await context
                .read<HomeBloc>()
                .stream
                .firstWhere((s) => s.status != HomeStatus.loading);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  user: user,
                  onSignOut: () => _confirmSignOut(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -36),
                  child: BalanceCard(user: user),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: QuickActions(currency: user.currency),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -4),
                  child: const PromoBanner(),
                ),
              ),
              const SliverToBoxAdapter(child: _RecentActivityHeader()),
              const _RecentActivitySliver(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityHeader extends StatelessWidget {
  const _RecentActivityHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 4, 24, 12),
      child: Row(
        children: [
          Text(
            AppStrings.recentActivity,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Spacer(),
          Text(
            AppStrings.seeAll,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySliver extends StatelessWidget {
  const _RecentActivitySliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        switch (state.status) {
          case HomeStatus.loading:
          case HomeStatus.initial:
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            );
          case HomeStatus.failure:
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    const Icon(Iconsax.warning_2,
                        color: AppColors.error, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? 'Could not load recent activity.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context
                          .read<HomeBloc>()
                          .add(const HomeRefreshed()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          case HomeStatus.success:
            if (state.transactions.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No recent activity')),
                ),
              );
            }
            return SliverList.builder(
              itemCount: state.transactions.length,
              itemBuilder: (context, i) => TransactionTile(
                transaction: state.transactions[i],
                isLast: i == state.transactions.length - 1,
              ),
            );
        }
      },
    );
  }
}

class _HomeBottomNav extends StatefulWidget {
  const _HomeBottomNav();

  @override
  State<_HomeBottomNav> createState() => _HomeBottomNavState();
}

class _HomeBottomNavState extends State<_HomeBottomNav> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        height: 66,
        destinations: const [
          NavigationDestination(
            icon: Icon(Iconsax.home_2),
            selectedIcon: Icon(Iconsax.home_15),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.arrange_square),
            selectedIcon: Icon(Iconsax.arrange_square5),
            label: 'Transact',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.document_text),
            selectedIcon: Icon(Iconsax.document_text5),
            label: 'Statement',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.user),
            selectedIcon: Icon(Iconsax.user5),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
