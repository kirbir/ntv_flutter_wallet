import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solana/solana.dart';
import 'package:solana/encoder.dart' show SignedTx;

Future<void> showSendDialog(
  BuildContext context,
  SolanaClient? client,
  VoidCallback onSuccess,
) async {
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      final addressController = TextEditingController();
      final amountController = TextEditingController();
      
      return AlertDialog(
        title: const Text('Send SOL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Recipient Address',
                hintText: 'Enter Solana address',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (SOL)',
                hintText: '0.0',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final recipientAddress = addressController.text;
                final amount = double.parse(amountController.text);
                
                // Get the sender's keypair from your stored mnemonic
                final prefs = await SharedPreferences.getInstance();
                final mnemonic = prefs.getString('mnemonic');
                if (mnemonic == null) throw Exception('No wallet found');
                
                final senderKeypair = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
                final recipient = Ed25519HDPublicKey.fromBase58(recipientAddress);
                final lamports = (amount * lamportsPerSol).toInt();
                
                // Create the transfer instruction
                final instruction = SystemInstruction.transfer(
                  fundingAccount: senderKeypair.publicKey,
                  recipientAccount: recipient,
                  lamports: lamports,
                );

                // Create and send the transaction
                final message = Message(instructions: [instruction]);
                final latestBlockhash = await client!.rpcClient.getLatestBlockhash();
                final compiledMessage = message.compile(                    
                  recentBlockhash: latestBlockhash.value.blockhash,
                  feePayer: senderKeypair.publicKey,
                );

                // Sign the compiled message
                final signedTx = SignedTx(
                  compiledMessage: compiledMessage,
                  signatures: [await senderKeypair.sign(compiledMessage.toByteArray())],
                );

                final signature = await client.rpcClient.sendTransaction(
                  signedTx.encode(),
                  preflightCommitment: Commitment.confirmed,
                );

                // Handle success
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Transaction sent! Signature: ${signature.substring(0, 8)}...')),
                );
                onSuccess();
                
              } catch (e) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      );
    },
  );
}