import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:thryve/src/components/big_button.dart';
import 'package:thryve/src/components/thryve_textfield.dart';
import 'package:thryve/src/data_models/user_state.dart';
import 'package:thryve/src/utilities/backend.dart';
import 'package:thryve/src/utilities/helpers.dart';
import 'package:thryve/src/views/home_view.dart';
import 'package:thryve/src/views/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  static const routeName = '/login';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String _email = '';
  String _password = '';

  @override
  void initState() {
    super.initState();
    GetIt.I<UserState>()
        .addListener(_handleUserInit); // listener is removed in _handleUserInit
    GetIt.I<UserState>().initUser();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: !GetIt.I<UserState>().userInitialised
            ? const SizedBox() // show blank screen for a moment while user is being initialised
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 0.75,
                      child: Center(
                        child: Hero(
                          tag: 'logo',
                          child: Image.asset('assets/images/thryve.png'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    ThryveTextField(
                      labelText: 'Email',
                      onChanged: _setEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    ThryveTextField(
                      labelText: 'Password',
                      onChanged: _setPassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    BigButton(
                      text: 'Login',
                      onPressed: _login,
                      iconTrailing: Icons.arrow_forward,
                    ),
                    const SizedBox(height: 10),
                    const _RegisterText(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
      ),
    );
  }

  void _setEmail(String email) {
    _email = email;
  }

  void _setPassword(String password) {
    _password = password;
  }

  void _login() async {
    final success = await Backend.login(_email, _password);
    if (!success) {
      showToast('Invalid email or password');
      return;
    }

    if (mounted) {
      // Clear navigation stack so home view is the only view in the stack
      Navigator.pushNamedAndRemoveUntil(
          context, HomeView.routeName, (r) => false);
    }
  }

  void _handleUserInit() {
    // if init is done, no need to keep listening, let _login method handle the navigation
    GetIt.I<UserState>().removeListener(_handleUserInit);
    if (GetIt.I<UserState>().userInitialised) {
      if (GetIt.I<UserState>().user != null) {
        // Clear navigation stack so home view is the only view in the stack
        Navigator.pushNamedAndRemoveUntil(
            context, HomeView.routeName, (r) => false);
      }
    }
    setState(() {});
  }
}

class _RegisterText extends StatelessWidget {
  const _RegisterText();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'Don\'t have an account yet? '),
          TextSpan(
            text: 'Register',
            style: const TextStyle(decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(context, RegisterView.routeName);
              },
          ),
        ],
      ),
      style: const TextStyle(fontSize: 12),
    );
  }
}
