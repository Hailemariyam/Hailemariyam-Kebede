import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/pin_input.dart';

/// Sign-in screen: PIN entry backed by [AuthBloc], with inline validation,
/// a loading state on the button, and error surfacing.
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatefulWidget {
  const _SignInView();

  @override
  State<_SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<_SignInView> {
  final GlobalKey<PinInputState> _pinKey = GlobalKey<PinInputState>();

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(const AuthLoginSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(AppStrings.signInTitle),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (_, __, ___) => const HomePage(),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            );
          } else if (state.status == AuthStatus.failure) {
            _pinKey.currentState?.clear();
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Iconsax.lock_1,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.signInTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.signInSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PinInput(
                    key: _pinKey,
                    hasError: state.pinError != null ||
                        state.status == AuthStatus.failure,
                    enabled: !state.isLoading,
                    onChanged: (pin) => context
                        .read<AuthBloc>()
                        .add(AuthPinChanged(pin)),
                    onCompleted: (_) => _submit(),
                  ),
                  const SizedBox(height: 14),
                  _MessageRow(
                    message: state.errorMessage ?? state.pinError,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed:
                        state.isPinValid && !state.isLoading ? _submit : null,
                    child: state.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(AppStrings.signInCta),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: state.isLoading ? null : () {},
                      child: const Text(
                        AppStrings.forgotPin,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: message == null
          ? const SizedBox(height: 18, key: ValueKey('empty'))
          : Row(
              key: const ValueKey('msg'),
              children: [
                const Icon(Iconsax.info_circle,
                    color: AppColors.error, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    message!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
