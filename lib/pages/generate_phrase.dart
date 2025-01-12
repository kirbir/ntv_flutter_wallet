import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:go_router/go_router.dart';
import 'package:ntv_flutter_wallet/widgets/custom_app_bar.dart';
import 'package:ntv_flutter_wallet/settings/custom_theme_extension.dart';
import 'package:ntv_flutter_wallet/services/logging_service.dart';

class GeneratePhraseScreen extends StatefulWidget {
  const GeneratePhraseScreen({super.key});

  @override
  State<GeneratePhraseScreen> createState() => _GeneratePhraseScreenState();
}

class _GeneratePhraseScreenState extends State<GeneratePhraseScreen> {
  String _mnemonic = "";
  List<String> _phraseList = [];
  Icon iconButton = const Icon(Icons.copy);
  bool _copied = false;
  bool _showBanner = true;

  // String _formatMnemonic(List<String> mnemonic) {
  //   return mnemonic.asMap().entries
  //       .map((entry) => entry.value + ((entry.key + 1) % 3 == 0 ? '\n' : ' '))
  //       .join('');
  // }

  Future<void> _generateMnemonic() async {
    String mnemonic = bip39.generateMnemonic();

    setState(() {
      _mnemonic = mnemonic;
      logger.i('Generated mnemonic: $_mnemonic');
      _phraseList = _mnemonic.split(' ');
    });
  }

  @override
  void initState() {
    super.initState();
    _generateMnemonic();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            Theme.of(context).extension<CustomThemeExtension>()?.pageGradient,
      ),
      child: Scaffold(
        appBar: const CustomAppBar(showSettings: false, showLogo: true),
        body: Column(
          children: [
            if (_showBanner)
              MaterialBanner(
                padding: const EdgeInsets.all(16),
                content: const Text(
                  'Important! Write down the recovery phrase and keep in a secure location. Do not share it with anyone! If you lose it, you will not be able to recover your account.',
                  style: TextStyle(height: 1.8),
                ),
                backgroundColor: const Color.fromARGB(255, 95, 37, 36),
                leading: const Icon(Icons.warning_amber_rounded,
                    color: Colors.white),
                contentTextStyle: const TextStyle(
                  color: Colors.white,
                  
                ),
               
                actions: [
                  TextButton(
                    onPressed: () => setState(() => _showBanner = false),
                    child: const Text('CLOSE',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            if (!_showBanner) 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Image.asset(
                  'assets/images/safe.gif',
                  height: 100, // Adjust size as needed
                ),
              ),
            Padding(
              padding: Theme.of(context).extension<CustomThemeExtension>()?.pageTheme.padding 
      ?? const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _phraseList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.transparent
                                    : Colors.black,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  _phraseList[index],
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    style: Theme.of(context).brightness == Brightness.dark
                        ? TextButton.styleFrom(foregroundColor: const Color.fromARGB(255, 255, 255, 255), iconColor: const Color.fromARGB(255, 255, 255, 255))
                        : TextButton.styleFrom(foregroundColor: Colors.black, iconColor: Colors.black),
                    label: const Text('Copy to clipboard'),
                    icon: iconButton,
                    
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _mnemonic));
                      setState(() {
                        iconButton = const Icon(Icons.check);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _copied,
                        onChanged: (value) {
                          setState(() {
                            _copied = value!;
                          });
                        },
                      ),
                      const Text("I Confirm secure storage"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 26),
                          ),
                          onPressed: _copied
                              ? () {
                                  GoRouter.of(context)
                                      .push("/passwordSetup/$_mnemonic");
                                }
                              : () {
                                  GoRouter.of(context).push("/");
                                },
                          child: Text(_copied ? 'Continue' : 'Go Back'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
