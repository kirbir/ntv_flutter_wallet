import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
import 'package:logging/logging.dart';

// Page where the user set's his Account name and password

class SetupPasswordScreen extends StatefulWidget {
  final String? mnemonic;
  const SetupPasswordScreen({super.key, required this.mnemonic});

  @override
  State<SetupPasswordScreen> createState() => _SetupPasswordScreenState();
}

class _SetupPasswordScreenState extends State<SetupPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final _log = Logger('SetupPassword');
  bool _isObscured = true;

  @override
  void initState() {

    super.initState();
    _isObscured=true;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Container(
        decoration: BoxDecoration(
          gradient:
              Theme.of(context).extension<CustomThemeExtension>()?.pageGradient,
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: const CustomAppBar(showSettings: true, showLogo: true),
          body: Padding(
            padding: const EdgeInsets.all(56),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Account name',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: usernameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: '',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Account name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 80),
                    Text(
                      'Create a password ',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: passwordController,
                        obscureText: _isObscured,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isObscured =! _isObscured;
                              });
                            },
                            icon: _isObscured
                                ? const Icon(Icons.visibility)
                                : const Icon(Icons.visibility_off),
                          ),
                          hintText: 'Password',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        }),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: confirmPasswordController,
                        obscureText: _isObscured,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isObscured =! _isObscured;
                              });
                            },
                            icon: _isObscured
                                ? const Icon(Icons.visibility)
                                : const Icon(Icons.visibility_off),
                          ),
                          hintText: 'Confirm password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Confirm password is required';
                          }
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        }),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 26),
                            ),
                            onPressed: _submit,
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (formKey.currentState!.validate()) {
      _validate();
      if (passwordController.text != confirmPasswordController.text) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('password', passwordController.text);
      await prefs.setString('mnemonic', widget.mnemonic!);
      await prefs.setString('username', usernameController.text);

      if (!mounted) return; //Check if the widget is mounted
      GoRouter.of(context).push("/");
    }
  }

  void _validate() {
    _log.info("Validating password");
    // rest of the validation code
  }
}
