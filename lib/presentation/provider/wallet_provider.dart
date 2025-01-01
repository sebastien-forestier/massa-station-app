// Dart imports:
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:mug/domain/usecase/explorer_use_case.dart';
import 'package:mug/domain/usecase/explorer_use_case_impl.dart';
import 'package:mug/presentation/state/wallet_state.dart';
import 'package:mug/service/local_storage_service.dart';
import 'package:mug/service/provider.dart';
import 'package:mug/utils/exception_handling.dart';

abstract base class WalletProvider extends StateNotifier<WalletState> {
  WalletProvider() : super(WalletLoading());
  Future<void> getWalletInformation(String address, bool getTokenBalance);
  bool setDefaultAccount(String address);
  Future<bool> isAccountDefault(String address);
  Future<String?> getWalletKey(String address);
}

base class WalletProviderImpl extends StateNotifier<WalletState> implements WalletProvider {
  final ExplorerUseCase explorerUseCase;
  final LocalStorageService localStorageService;

  WalletProviderImpl({
    required this.explorerUseCase,
    required this.localStorageService,
  }) : super(WalletLoading());

  @override
  Future<void> getWalletInformation(String address, bool getTokenBalance) async {
    state = WalletLoading();
    final result = await explorerUseCase.getAddress(address, getTokenBalance);
    switch (result) {
      case Success(value: final response):
        state = WalletSuccess(addressEntity: response);
      case Failure(exception: final exception):
        state = WalletFailure(message: 'Something went wrong: $exception');
    }
  }

  @override
  bool setDefaultAccount(String address) {
    localStorageService.setDefaultWallet(address);
    return true;
  }

  @override
  Future<bool> isAccountDefault(String address) async {
    final defaultAddress = await localStorageService.getDefaultWallet();
    if (address == defaultAddress) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<String?> getWalletKey(String address) async {
    return await localStorageService.getWalletKey(address);
  }
}

final walletProvider = StateNotifierProvider<WalletProvider, WalletState>((ref) {
  return WalletProviderImpl(
      explorerUseCase: ref.watch(explorerUseCaseProvider), localStorageService: ref.watch(localStorageServiceProvider));
});
