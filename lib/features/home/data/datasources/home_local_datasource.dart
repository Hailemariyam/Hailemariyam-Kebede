import '../models/transaction_model.dart';

/// Serves the transactions feed. The mock backend has no such endpoint, so
/// this returns a fixed, realistic dataset. Async + interface so a remote
/// datasource can replace it transparently.
abstract class HomeLocalDataSource {
  Future<List<TransactionModel>> getRecentTransactions();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  const HomeLocalDataSourceImpl();

  static const List<Map<String, dynamic>> _seed = [
    {
      'id': 'txn_01',
      'title': 'Aster Mekuanint',
      'subtitle': 'From CBE · Today, 14:22',
      'amount': 1200.0,
      'type': 'received',
      'channel': 'CBE',
    },
    {
      'id': 'txn_02',
      'title': 'Marta Alemu',
      'subtitle': 'M-PESA transfer · Today, 11:05',
      'amount': 500.0,
      'type': 'sent',
      'channel': 'M-PESA',
    },
    {
      'id': 'txn_03',
      'title': 'EEU Prepaid',
      'subtitle': 'Bill payment · Yesterday',
      'amount': 220.0,
      'type': 'sent',
      'channel': 'M-PESA',
    },
    {
      'id': 'txn_04',
      'title': 'Airtime top-up',
      'subtitle': 'Telebirr · Yesterday, 19:40',
      'amount': 50.0,
      'type': 'sent',
      'channel': 'Telebirr',
    },
    {
      'id': 'txn_05',
      'title': 'Yonas Bekele',
      'subtitle': 'From CBE · 5 Sep',
      'amount': 1500.0,
      'type': 'received',
      'channel': 'CBE',
    },
  ];

  @override
  Future<List<TransactionModel>> getRecentTransactions() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _seed.map(TransactionModel.fromJson).toList();
  }
}
