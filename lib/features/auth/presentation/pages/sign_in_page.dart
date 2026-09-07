import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/number_keypad.dart';
import '../widgets/pin_dots.dart';
import '../widgets/sign_in_footer.dart';
import '../widgets/sign_in_header.dart';

/// Sign-in screen: rounded brand header with the user identity, a lock prompt,
/// four PIN boxes, a custom numeric keypad, a full-width Continue button, and a
/// row of footer links. Backed by [AuthBloc].
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  static const int pinLength = 4;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatelessWidget {
  const _SignInView();

  void _onDigit(BuildContext context, String digit) {
    final current = context.read<AuthBloc>().state.pin;
    if (current.length >= SignInPage.pinLength) return;
    context.read<AuthBloc>().add(AuthPinChanged(current + digit));
  }

  void _onBackspace(BuildContext context) {
    final current = context.read<AuthBloc>().state.pin;
    if (current.isEmpty) return;
    context
        .read<AuthBloc>()
        .add(AuthPinChanged(current.substring(0, current.length - 1)));
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(const AuthLoginSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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
          }
        },
        builder: (context, state) {
          final filled = state.pin.length;
          final showError = state.status == AuthStatus.failure ||
              state.pinError != null;
          final message = state.errorMessage ?? state.pinError;

          return Column(
            children: [
              const SignInHeader(
                name: AppStrings.placeholderName,
                phoneNumber: AppStrings.placeholderPhone,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                            child: Column(
                              children: [
                                const Spacer(flex: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Iconsax.lock_1,
                                      color: AppColors.textPrimary,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      AppStrings.signInTitle,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                PinDots(
                                  length: SignInPage.pinLength,
                                  filledCount: filled,
                                  hasError: showError,
                                ),
                                SizedBox(
                                  height: 24,
                                  child: message == null
                                      ? null
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Text(
                                            message,
                                            style: const TextStyle(
                                              color: AppColors.error,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                ),
                                const Spacer(flex: 3),
                                NumberKeypad(
                                  enabled: !state.isLoading,
                                  onDigit: (d) => _onDigit(context, d),
                                  onBackspace: () => _onBackspace(context),
                                ),
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: state.isPinValid &&
                                              !state.isLoading
                                          ? () => _submit(context)
                                          : null,
                                      child: state.isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2.4,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(AppStrings.signInCta),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SignInFooter(
                                  onForgotPin: () {},
                                  onContactUs: () {},
                                  onTerms: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
