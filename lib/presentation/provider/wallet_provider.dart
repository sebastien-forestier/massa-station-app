// Dart imports:
import 'dart:developer';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mug/data/model/wallet_model.dart';

// Project imports:
import 'package:mug/domain/usecase/wallet_use_case.dart';
import 'package:mug/domain/usecase/wallet_use_case_impl.dart';
import 'package:mug/presentation/state/wallets_state.dart';
import 'package:mug/service/local_storage_service.dart';
import 'package:mug/service/provider.dart';
import 'package:mug/utils/exception_handling.dart';

abstract base class WalletProvider extends StateNotifier<WalletsState> {
  WalletProvider() : super(WalletInitial());

  late WalletData wallets;
  Future<void> loadWallets();
  Future<void> createWallet();
  Future<void> deleteWallet(String address);
  Future<void> importWallet(String privateKey);
  (bool, WalletModel?) isAccountExisting(String address);
  bool setDefaultAccount(String address);
  Future<bool> isAccountDefault(String address);
  //Future<bool> isWalletEmpty();
  Future<String?> getWallet(String address);

  //Future<Result<(String, bool), Exception>> transfer(double amount, String recipientAddress);

  //Future<void> setPassphrase(String passphrase);
  //Future<String> getPassphrase();
  //Future<bool> isPassphraseSet();
}

base class WalletProviderImpl extends StateNotifier<WalletsState> implements WalletProvider {
  final WalletUseCase useCase;
  final LocalStorageService localStorageService;
  @override
  late WalletData wallets;
  @override
  WalletProviderImpl({required this.useCase, required this.localStorageService}) : super(WalletInitial());

  @override
  Future<void> createWallet() async {
    print("create wallet is called..");
    state = WalletLoading();
    final result = await useCase.createWallet();
    switch (result) {
      case Success(value: final response):
        if (response.wallets.isNotEmpty) {
          state = WalletSuccess(wallets: response);
        } else {
          state = WalletEmpty(message: "No wallet and no passphrase set");
        }

      case Failure(exception: final exception):
        state = WalletFailure(message: 'Something went wrong: $exception');
    }
    _debug();
  }

  @override
  Future<void> loadWallets() async {
    state = WalletLoading();

    print("I am here... but wallet is empty");
    final result = await useCase.loadWallets();
    switch (result) {
      case Success(value: final response):
        print("I am here... but wallet is empty");
        if (response.wallets.isNotEmpty) {
          wallets = response;
          state = WalletSuccess(wallets: response);
        } else {
          state = WalletEmpty(message: "It feels lonely here! No wallet is created yet.");
        }

      case Failure(exception: final exception):
        state = WalletFailure(message: 'Something went wrong: $exception');
    }
    _debug();
  }

  @override
  Future<void> importWallet(String privateKey) async {
    state = WalletLoading();
    final result = await useCase.restoreWallet(privateKey);
    switch (result) {
      case Success(value: final response):
        if (response.wallets.isNotEmpty) {
          state = WalletSuccess(wallets: response);
        } else {
          state = WalletEmpty(message: "No wallet and no passphrase set");
        }
      case Failure(exception: final exception):
        state = WalletFailure(message: 'Something went wrong while importing wallet: $exception');
    }
    _debug();
  }

  @override
  Future<void> deleteWallet(String address) async {
    state = WalletLoading();
    final result = await useCase.deleteWallet(address);
    switch (result) {
      case Success(value: final response):
        if (response.wallets.isNotEmpty) {
          state = WalletSuccess(wallets: response);
        } else {
          state = WalletEmpty(message: "No wallet and no passphrase set");
        }

      case Failure(exception: final exception):
        state = WalletFailure(message: 'Something went wrong: $exception');
    }
    _debug();
  }

  @override
  (bool, WalletModel?) isAccountExisting(String address) {
    bool isExisting = false;
    WalletModel? wallet;
    if (wallets.wallets.isNotEmpty) {
      for (var element in wallets.wallets) {
        if (element.address == address) {
          isExisting = true;
          wallet = element;
          break;
        }
      }
    }
    return (isExisting, wallet);
  }

  @override
  bool setDefaultAccount(String address) {
    final wallet = isAccountExisting(address);
    if (wallet.$1) {
      localStorageService.setDefaultWallet(address);
      state = WalletLoading();
      return true;
    }
    return false;
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
  Future<String?> getWallet(String address) async {
    return await localStorageService.getWalletKey(address);
  }

  // @override
  // Future<void> setPassphrase(String passphrase) async {
  //   final result = await useCase.setPassphrase(passphrase);
  //   switch (result) {
  //     case Success():
  //       state = WalletEmpty(message: "No wallet");

  //     case Failure(exception: final exception):
  //       state = WalletFailure(message: 'Something went wrong: $exception');
  //   }
  //   _debug();
  // }

  // @override
  // Future<String> getPassphrase() async {
  //   final result = await useCase.getPassphrase();
  //   switch (result) {
  //     case Success(value: final result):
  //       return result;

  //     case Failure(exception: final exception):
  //       state = WalletFailure(message: 'Something went wrong: $exception');
  //   }
  //   _debug();
  // }

  // @override
  // Future<bool> isPassphraseSet() async {
  //   final result = await useCase.isPassphraseSet();
  //   switch (result) {
  //     case Success(value: final result):
  //       return result;
  //     case Failure():
  //       return false;
  //   }
  // }

  void _debug() {
    log('User state: $state');
  }
}

final walletProvider = StateNotifierProvider<WalletProvider, WalletsState>((ref) {
  print("wallet provider initalised...");
  return WalletProviderImpl(
      useCase: ref.watch(walletUseCaseProvider), localStorageService: ref.watch(localStorageServiceProvider));
});
