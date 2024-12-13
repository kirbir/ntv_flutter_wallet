import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  bool validationFailed = false;
  String? password;
  bool _loading = true;
  String? key;

  @override
  void initState() {
    super.initState();

    _checkForSavedLogin().then((credentialsFound) {
      if (!credentialsFound) {
        GoRouter.of(context).push("/setup");
      } else {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: CustomAppBar(title: 'Login', showSettings: true),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 40),
          Center(
            child: Image.asset(
              'assets/images/Viking.png',
              width: 200,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != password) {
                          setState(() {
                            validationFailed = true;
                          });
                          return;
                        }
                        GoRouter.of(context).push("/home");
                        // Validation
                      }),
                  const SizedBox(height: 8),
                  Text(validationFailed ? 'Invalid Password' : '',
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _onSubmit,
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        onDifferentAccountPressed(context);
                      },
                      child: const Text('Use different Account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<bool> _checkForSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    key = prefs.getString('mnemonic');
    password = prefs.getString('password');
    if (key == null || password == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<dynamic> onDifferentAccountPressed(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: const Text(
                'Access to current account will be lost if seed phrase is lost.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  GoRouter.of(context).go("/setup");
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
  }
}
