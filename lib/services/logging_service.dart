import 'package:logging/logging.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

void setupLogging() {
  // Set different log levels based on debug/release mode
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  
  hierarchicalLoggingEnabled = true;

  Logger.root.onRecord.listen((record) {
    // Use developer.log for better formatting and integration with dev tools
    developer.log(
      '${record.level.name}: ${record.message}',
      time: record.time,
      name: record.loggerName,
      level: record.level.value,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });

  // Set up specific levels for different loggers if needed
  Logger('TokenService').level = Level.INFO;
  Logger('WalletService').level = Level.INFO;
  Logger('MetadataService').level = Level.INFO;
  
  // More verbose logging for transaction-related operations
  Logger('SendTx').level = Level.FINE;
  Logger('Transactions').level = Level.FINE;
} 