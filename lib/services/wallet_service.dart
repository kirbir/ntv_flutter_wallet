import 'package:solana/solana.dart';
import 'package:solana/dto.dart';
import '../models/my_tokens.dart';
import '../services/metadata_service.dart';
import 'package:ntv_flutter_wallet/services/logging_service.dart';
import 'package:ntv_flutter_wallet/services/token_service.dart';

class WalletService {

  final SolanaClient client;
  
  WalletService({required this.client});

  Future<({List<Token> tokens, double solBalance})> getBalanceAndTokens(String publicKey) async {
    return TokenCache.getCachedData('balance_and_tokens_$publicKey', () async {
      try {
        final getBalance = await client.rpcClient
            .getBalance(publicKey, commitment: Commitment.confirmed);

        final filter = TokenAccountsFilter.byProgramId(
          'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
        );

        final tokenAccounts = await client.rpcClient.getTokenAccountsByOwner(
          publicKey,
          filter,
          encoding: Encoding.jsonParsed,
          commitment: Commitment.confirmed,
        );

        final tokens = <Token>[];
        final solBalance = getBalance.value.toDouble() / lamportsPerSol;

        tokens.add(Token(
          mint: '11111111111111111111111111111111',
          symbol: 'SOL',
          name: 'Solana',
          decimals: 4,
          logoUri: 'https://assets.coingecko.com/coins/images/4128/standard/solana.png?1718769756',
          amount: solBalance,
        ));

        await _processTokenAccounts(tokenAccounts.value, tokens);
        return (tokens: tokens, solBalance: solBalance);
      } catch (e, stackTrace) {
        logger.e('Error in getBalanceAndTokens', error: e, stackTrace: stackTrace);
        rethrow;
      }
    });
  }

  Future<void> _processTokenAccounts(
    List<ProgramAccount> accounts,
    List<Token> tokens,
  ) async {
    for (final account in accounts) {
      try {
        if (account.account.data is ParsedAccountData) {
          final parsedData = account.account.data as ParsedAccountData;
          
          if (parsedData.parsed is TokenAccountData) {
            await _processTokenData(parsedData.parsed as TokenAccountData, tokens);
          }
        }
      } catch (e) {
        logger.e('Error processing token account: $e');
      }
    }
  }

  Future<void> _processTokenData(TokenAccountData tokenData, List<Token> tokens) async {
    final info = tokenData.info;


    final amount = double.tryParse(info.tokenAmount.uiAmountString ?? '0') ?? 0.0;
    if (amount <= 0) return;

    final metadata = await TokenMetadataService.getTokenMetadata(info.mint);
    
    tokens.add(Token(
      mint: info.mint,
      symbol: metadata['symbol'] ?? 'Unknown',
      name: metadata['name'],
      decimals: metadata['decimals'],
      logoUri: metadata['logoURI'],
      amount: amount,
    ));
  }

// Airdrop button in home page calls this function if user is on devnet
  Future <String> requestAirdrop(String pubKey, int lamports) async {
    try {
      final signature = await client.rpcClient.requestAirdrop(pubKey, lamports);
      logger.d('Airdrop requested: ${signature.toString()}');
      return signature;
    } catch (e) {
      logger.e('Error in requestAirdrop: $e');
      return '';
    }
  }
}