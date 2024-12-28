import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Account Setup', showSettings: true),
      body: Padding(
        padding: const EdgeInsets.all(56),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Text(
                'Choose a name for your account',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              TextFormField(
                textAlign: TextAlign.center,
                controller: usernameController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 80),
              Text(
                'Create a password: ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                         hintText: 'Password',
                  floatingLabelAlignment: FloatingLabelAlignment.center,
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
                  obscureText: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'Confirm password',
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    border: const OutlineInputBorder(),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  void _submit() async {
    if (formKey.currentState!.validate()) {
      print("validate");
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
}
