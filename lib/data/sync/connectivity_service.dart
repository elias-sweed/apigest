import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final BehaviorSubject<bool> _onlineSubject;

  ConnectivityService() : _onlineSubject = BehaviorSubject<bool>.seeded(true) {
    _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      _onlineSubject.add(online);
    });
  }

  Stream<bool> get onConnectivityChanged => _onlineSubject.stream;

  bool get isOnline => _onlineSubject.value;

  void dispose() => _onlineSubject.close();
}
