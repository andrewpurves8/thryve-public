import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:thryve/src/components/big_button.dart';
import 'package:thryve/src/components/thryve_textfield.dart';
import 'package:thryve/src/utilities/backend.dart';
import 'package:thryve/src/utilities/helpers.dart';
import 'package:thryve/src/views/home_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  static const routeName = '/register';

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  static const _errorTextFirstName = 'Enter your first name';
  static const _errorTextLastName = 'Enter your last name';
  static const _errorTextEmail = 'Enter a valid email address';
  static const _errorTextPassword = 'Enter a password longer than 6 characters';
  static const _errorTextPasswordConfirm = 'Passwords do not match';

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';

  bool _validFirstName = true;
  bool _validLastName = true;
  bool _validEmail = true;
  bool _validPassword = true;
  bool _validPasswordConfirm = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.width * 0.6,
                child: Center(
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset('assets/images/thryve.png'),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ThryveTextField(
                labelText: 'First name',
                onChanged: _setFirstName,
                errorText: _validFirstName ? null : _errorTextFirstName,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 10),
              ThryveTextField(
                labelText: 'Last name',
                onChanged: _setLastName,
                errorText: _validLastName ? null : _errorTextLastName,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 10),
              ThryveTextField(
                labelText: 'Email',
                onChanged: _setEmail,
                errorText: _validEmail ? null : _errorTextEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              ThryveTextField(
                labelText: 'Password',
                onChanged: _setPassword,
                errorText: _validPassword ? null : _errorTextPassword,
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ThryveTextField(
                labelText: 'Confirm password',
                onChanged: _setPasswordConfirm,
                errorText:
                    _validPasswordConfirm ? null : _errorTextPasswordConfirm,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              BigButton(
                text: 'Register',
                onPressed: _register,
                enabled: _validPasswordConfirm,
                iconTrailing: Icons.arrow_forward,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _setFirstName(String firstName) {
    _firstName = firstName;
    setState(() {
      _validFirstName = true;
    });
  }

  void _setLastName(String lastName) {
    _lastName = lastName;
    setState(() {
      _validLastName = true;
    });
  }

  void _setEmail(String email) {
    _email = email;
    setState(() {
      _validEmail = true;
    });
  }

  void _setPassword(String password) {
    _password = password;
    setState(() {
      _validPassword = true;
    });
  }

  void _setPasswordConfirm(String passwordConfirm) {
    setState(() {
      _validPasswordConfirm = passwordConfirm == _password;
    });
  }

  bool _validateInputs() {
    setState(() {
      _firstName = _firstName.trim();
      _validFirstName = _firstName.isNotEmpty;

      _lastName = _lastName.trim();
      _validLastName = _lastName.isNotEmpty;

      _email = _email.trim();
      _validEmail = EmailValidator.validate(_email);

      _validPassword = _password.length >= 6;
    });

    return _validFirstName && _validLastName && _validEmail && _validPassword;
  }

  void _register() async {
    if (!_validateInputs()) {
      return;
    }

    final success = await Backend.register(
      _email,
      _password,
      _firstName,
      _lastName,
    );

    if (!success) {
      showToast('Error registering');
      return;
    }

    if (mounted) {
      // Clear navigation stack so home view is the only view in the stack
      Navigator.pushNamedAndRemoveUntil(
          context, HomeView.routeName, (r) => false);
    }
  }
}
