import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_ambient_background.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/auth_brand_header.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_animated_entrance.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_card.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_google_button.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/login_or_divider.dart';
import 'package:flutter_ecommerce/features/auth/presentation/widgets/terms_agreement_footer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _hideBlocLoginError = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _hideBlocLoginError = false);
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          const AuthAmbientBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXl,
                  vertical: AppSizes.paddingXl,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LoginAnimatedEntrance(
                      delay: 0,
                      controller: _animationController,
                      child: const AuthBrandHeader(),
                    ),
                    const SizedBox(height: AppSizes.paddingXl + 8),
                    LoginAnimatedEntrance(
                      delay: 150,
                      controller: _animationController,
                      child: LoginCard(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        showError: !_hideBlocLoginError,
                        onSubmitted: _onSubmit,
                        onEmailChanged: () {
                          if (!_hideBlocLoginError) {
                            setState(() => _hideBlocLoginError = true);
                          }
                        },
                        onPasswordChanged: () {
                          if (!_hideBlocLoginError) {
                            setState(() => _hideBlocLoginError = true);
                          }
                        },
                        onToggleObscure: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingLg),
                    LoginAnimatedEntrance(
                      delay: 250,
                      controller: _animationController,
                      child: const LoginOrDivider(),
                    ),
                    const SizedBox(height: AppSizes.paddingLg),
                    LoginAnimatedEntrance(
                      delay: 300,
                      controller: _animationController,
                      child: const LoginGoogleButton(),
                    ),
                    const SizedBox(height: AppSizes.paddingXl + 4),
                    LoginAnimatedEntrance(
                      delay: 400,
                      controller: _animationController,
                      child: const TermsAgreementFooter(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
