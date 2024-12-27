import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:massa/massa.dart';
import 'package:mug/data/data_source/network/wallet_network_data_source_impl.dart';
import 'package:mug/data/model/wallet_model.dart';
import 'package:mug/data/repository/wallet_repository_impl.dart';
import 'package:mug/domain/usecase/wallet_use_case_impl.dart';
import 'package:mug/service/local_storage_service.dart';
import 'package:mug/service/provider.dart';
import 'package:mug/utils/encryption/aes_encryption.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalletInitNotifier extends AsyncNotifier<bool> {
  late final LocalStorageService localStorageService;

  @override
  Future<bool> build() async {
    // Access LocalStorageService through the dependency injection
    localStorageService = ref.read(localStorageServiceProvider);

    // Check if wallets are already initialized
    final walletString = await localStorageService.getStoredWallets();
    return walletString.isNotEmpty;
  }

  /// Creates the initial wallet
  Future<void> createInitialWallet() async {
    state = const AsyncValue.loading(); // Set state to loading
    try {
      final wallet = Wallet();
      final passphrase = await localStorageService.passphrase;
      final account = await wallet.newAccount(AddressType.user, NetworkType.MAINNET);

      final walletEntity = WalletModel(
        address: account.address(),
        encryptedKey: encryptAES(account.privateKey(), passphrase),
      );

      // Get existing stored wallets
      List<WalletModel> wallets;
      final walletString = await localStorageService.getStoredWallets();
      if (walletString.isNotEmpty) {
        wallets = WalletModel.decode(walletString);
        wallets.add(walletEntity);
      } else {
        wallets = [walletEntity];
      }

      // Store the updated wallet list
      await localStorageService.storeWallets(WalletModel.encode(wallets));

      // Set the new wallet as the default
      await localStorageService.setDefaultWallet(account.address());
      ref.invalidate(accountProvider);
      //ref.invalidate(jrpcServiceProvider);
      ref.invalidate(smartContractServiceProvider);
      // ref.invalidate(walletUseCaseProvider);
      // ref.invalidate(walletRepositoryProvider);
      // ref.invalidate(walletNetworkDatasourceProvider);

      ref.read(accountProvider.future);
      //ref.read(jrpcServiceProvider);
      ref.read(smartContractServiceProvider);
      // ref.read(walletUseCaseProvider);
      // ref.read(walletRepositoryProvider);
      // ref.read(walletNetworkDatasourceProvider);
      // Update state to true
      state = const AsyncValue.data(true);
    } catch (e, stack) {
      // Handle errors and update state
      state = AsyncValue.error(e, stack);
    }
  }

  /// Creates the initial wallet
  Future<void> importInitialWallet(String privateKey) async {
    state = const AsyncValue.loading(); // Set state to loading
    try {
      final wallet = Wallet();
      final passphrase = await localStorageService.passphrase;
      final account = await wallet.addAccountFromSecretKey(privateKey, AddressType.user, NetworkType.MAINNET);

      final walletEntity = WalletModel(
        address: account.address(),
        encryptedKey: encryptAES(account.privateKey(), passphrase),
      );

      // Get existing stored wallets
      List<WalletModel> wallets;
      final walletString = await localStorageService.getStoredWallets();
      if (walletString.isNotEmpty) {
        wallets = WalletModel.decode(walletString);
        wallets.add(walletEntity);
      } else {
        wallets = [walletEntity];
      }

      // Store the updated wallet list
      await localStorageService.storeWallets(WalletModel.encode(wallets));

      // Set the new wallet as the default
      await localStorageService.setDefaultWallet(account.address());
      ref.invalidate(accountProvider);
      ref.invalidate(jrpcServiceProvider);
      ref.invalidate(smartContractServiceProvider);
      // ref.invalidate(walletUseCaseProvider);
      // ref.invalidate(walletRepositoryProvider);
      // ref.invalidate(walletNetworkDatasourceProvider);

      ref.read(accountProvider.future);
      ref.read(jrpcServiceProvider);
      ref.read(smartContractServiceProvider);
      // ref.read(walletUseCaseProvider);
      // ref.read(walletRepositoryProvider);
      // ref.read(walletNetworkDatasourceProvider);
      // Update state to true
      state = const AsyncValue.data(true);
    } catch (e, stack) {
      // Handle errors and update state
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider using AsyncNotifier with dependency on localStorageServiceProvider
final walletInitProvider = AsyncNotifierProvider<WalletInitNotifier, bool>(() {
  print("wallet init provider initalised...");
  return WalletInitNotifier();
});







// class WalletInitNotifier extends AsyncNotifier<List<WalletModel>> {
//   late final LocalStorageService localStorageService;

//   @override
//   Future<List<WalletModel>> build() async {
//     localStorageService = ref.read(localStorageServiceProvider);

//     // Fetch existing wallets
//     final walletString = await localStorageService.getStoredWallets();
//     if (walletString.isNotEmpty) {
//       return WalletModel.decode(walletString);
//     }
//     return [];
//   }

//   Future<void> createNewWallet() async {
//     final wallet = Wallet();
//     final passphrase = await localStorageService.passphrase;
//     final account = await wallet.newAccount(AddressType.user, NetworkType.MAINNET);

//     final walletEntity = WalletModel(
//         address: account.address(),
//         encryptedKey: encryptAES(account.privateKey(), passphrase),
//         name: account.address().substring(account.address().length - 4));

//     List<WalletModel> wallets;
//     final walletString = await localStorageService.getStoredWallets();
//     if (walletString.isNotEmpty) {
//       wallets = WalletModel.decode(walletString);
//       wallets.add(walletEntity);
//       await localStorageService.storeWallets(WalletModel.encode(wallets));
//     } else {
//       wallets = [walletEntity];
//       await localStorageService.storeWallets(WalletModel.encode(wallets));
//       await localStorageService.setDefaultWallet(account.address());
//     }
//     state = AsyncData(await _fetchWallets()); //Re-fetch the wallets to update the state
//   }

//   Future<List<WalletModel>> _fetchWallets() async {
//     final walletString = await localStorageService.getStoredWallets();
//     if (walletString.isNotEmpty) {
//       return WalletModel.decode(walletString);
//     }
//     return [];
//   }
// }

// final walletInitProvider = AsyncNotifierProvider<WalletInitNotifier, List<WalletModel>>(() {
//   return WalletInitNotifier();
// });





// // StateNotifier to manage the title state
// class WalletInitNotifier extends StateNotifier<bool> {
//   final LocalStorageService localStorageService;
//   WalletInitNotifier({required this.localStorageService}) : super(false);

//   Future<bool> createInitialWallet() async {
//     final wallet = Wallet();
//     final passphrase = await localStorageService.passphrase;
//     final account = await wallet.newAccount(AddressType.user, NetworkType.MAINNET);
//     final WalletModel walletEntity =
//         WalletModel(address: account.address(), encryptedKey: encryptAES(account.privateKey(), passphrase));
//     //get existing storated wallets
//     List<WalletModel> wallets;
//     final walletString = await localStorageService.getStoredWallets();
//     if (walletString.isNotEmpty) {
//       wallets = WalletModel.decode(walletString);
//       wallets.add(walletEntity);
//     } else {
//       wallets = [walletEntity];
//     }
//     await localStorageService.storeWallets(WalletModel.encode(wallets));

//     //make this wallet as a default wallet
//     await localStorageService.setDefaultWallet(account.address());
//     return true;
//   }
// }

// // Provider for
// final walletInitProvider = StateNotifierProvider<WalletInitNotifier, bool>((ref) {
//   return WalletInitNotifier(localStorageService: ref.watch(localStorageServiceProvider));
// });

// final checkWalletInitProvider = FutureProvider<bool>((ref) async {
//   final walletString = await ref.read(localStorageServiceProvider).getStoredWallets();
//   if (walletString.isNotEmpty) {
//     return true;
//   }
//   return false;
// });
