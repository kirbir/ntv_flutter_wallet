import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
class InputPhraseScreen extends StatefulWidget {
  const InputPhraseScreen({super.key});

  @override
  State<InputPhraseScreen> createState() => _InputPhraseScreenState();
}

class _InputPhraseScreenState extends State<InputPhraseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _words = List<String>.filled(12, '');
  bool validationFailed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: Theme.of(context).extension<CustomThemeExtension>()?.pageGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'Import Account', showSettings: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Please enter your recovery phrase',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: SizedBox(
                    width: 300,
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.5,
                      children: List.generate(12, (index) {
                        return TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            hintText: '${index + 1}',
                          ),
                          onSaved: (value) {
                            _words[index] = value!;
                          },
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (validationFailed)
                  const Text(
                    'Invalid keyphrase',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _onSubmit(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit(context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String wordsString = _words.join(' ');
      final t = bip39.validateMnemonic(wordsString);
      if (t) {
        GoRouter.of(context).push("/passwordSetup/$wordsString");
      } else {
        setState(() {
          validationFailed = true;
        });
      }
    }
  }
}
