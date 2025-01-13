import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:ntv_flutter_wallet/settings/app_colors.dart';
import 'package:ntv_flutter_wallet/services/logging_service.dart';
import 'package:ntv_flutter_wallet/widgets/glowing_avatar.dart';
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
          appBar: const CustomAppBar(showSettings: false, showLogo: true),
          body: Padding(
            padding: Theme.of(context).extension<CustomThemeExtension>()?.pageTheme.padding 
      ?? const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: GlowingAvatar(
                        radius: 50,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.gray900
                                    : AppColors.backgroundLight,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Customize Avatar',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                    ),
                                    Flexible(
                                      child: SingleChildScrollView(
                                        child: FluttermojiCustomizer(
                                          theme: FluttermojiThemeData(
                                            primaryBgColor: Theme.of(context).brightness == Brightness.dark
                                                ? AppColors.gray900
                                                : AppColors.backgroundLight,
                                            secondaryBgColor: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.transparent
                                                : AppColors.gray300,
                                            labelTextStyle: Theme.of(context).brightness == Brightness.dark
                                                ? const TextStyle(color: Colors.white)
                                                : const TextStyle(color: Colors.black),
                                          ),
                                          scaffoldWidth: MediaQuery.of(context).size.width * 0.8,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24,),
                    Text(
                      'Account name',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: usernameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.person), 
                        hintText: 'Account name',
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
                      mainAxisSize: MainAxisSize.min,
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
    logger.i("Validating password");
    // rest of the validation code
  }
}
