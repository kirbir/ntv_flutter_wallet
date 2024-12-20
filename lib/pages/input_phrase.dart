import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';

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
    return Scaffold(
      appBar: const CustomAppBar(title: 'Login', showSettings: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Please enter your recovery phrase',
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 32),
          Center(
            child: Form(
              key: _formKey,
              child: SizedBox(
                  width: 300,
                  height: 400,
                  child: GridView.count(
                    padding: const EdgeInsets.all(3),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 3,
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    children: List.generate(12, (index) {
                      return SizedBox(
                        height: 50,
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: '${index + 1}',
                          ),
                          onSaved: (value) {
                            _words[index] = value!;
                          },
                        ),
                      );
                    }),
                  )),
            ),
          ),
          Text(validationFailed ? 'Invalid keyphrase' : '',
              style: const TextStyle(color: Colors.red)),
          const Spacer(),
          SizedBox(
            width: 200,
            child: TextButton(
              onPressed: () {
                _onSubmit(context);
              },
              child: const Text('Continue'),
            ),
          ),
        ],
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
