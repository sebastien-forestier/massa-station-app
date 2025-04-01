// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:massa/massa.dart';
import 'package:mug/data/model/wallet_model.dart';
import 'package:mug/env/env.dart';
import 'package:mug/service/explorer_api.dart';

// Project imports:
import 'package:mug/service/grpc_service.dart';
import 'package:mug/service/jrpc_service.dart';
import 'package:mug/service/local_storage_service.dart';
import 'package:mug/service/smart_contract_client.dart';
import 'package:mug/utils/encryption/aes_encryption.dart';

//local storage provider
final asyncInitProvider = Provider<AsyncInit>((ref) => AsyncInit(ref: ref));

final localStorageServiceProvider = Provider<LocalStorageService>(
    (ref) => LocalStorageService(sharedPreferences: ref.read(asyncInitProvider).sharedPreferences));

final jrpcServiceProvider = Provider<JrpcService>((ref) {
  return JrpcServiceImpl();
});

final grpcServiceProvider = Provider<GrpcService>((ref) {
  return GrpcServiceImpl();
});

final explorerApiServiceProvider = Provider<ExplorerApi>((ref) {
  final uri = Uri(scheme: 'https', host: Env.explorerHost);
  return ExplorerApi(uri);
});

final accountProvider = FutureProvider<Account?>((ref) async {
  //final localStorageService = ref.watch(localStorageServiceProvider);
  final isMainnet = ref.read(localStorageServiceProvider).isMainnet;
  final defaultAccountKey = await ref.read(localStorageServiceProvider).getDefaultWalletKey();
  print("default private key: $defaultAccountKey");
  if (defaultAccountKey == null) {
    // //create a default account
    // final account = await Wallet().newAccount(AddressType.user, isMainnet ? NetworkType.MAINNET : NetworkType.BUILDNET);
    // final passphrase = await localStorageService.passphrase;
    // final walletEntity = WalletModel(
    //     address: account.address(),
    //     encryptedKey: encryptAES(account.privateKey(), passphrase),
    //     name: account.address().substring(account.address().length - 4));
    // //store default wallet
    // List<WalletModel> wallets;
    // final walletString = await localStorageService.getStoredWallets();
    // if (walletString.isNotEmpty) {
    //   wallets = WalletModel.decode(walletString);
    //   wallets.add(walletEntity);
    //   await localStorageService.storeWallets(WalletModel.encode(wallets));
    // } else {
    //   wallets = [walletEntity];
    //   await localStorageService.storeWallets(WalletModel.encode(wallets));
    //   await localStorageService.setDefaultWallet(account.address());
    // }
    // return account;
    return null;
  }

  final account = await Wallet().addAccountFromSecretKey(
      defaultAccountKey, AddressType.user, isMainnet ? NetworkType.MAINNET : NetworkType.BUILDNET);
  return account;
});

final smartContractServiceProvider = Provider<SmartContractService?>((ref) {
  final isMainnet = ref.read(localStorageServiceProvider).isMainnet;
  final isBuildnet = !isMainnet;

  final account = ref.watch(accountProvider).value; // Get the account from the FutureProvider
  if (account == null) {
    return null;
  }
  return SmartContractService(account: account, isBuildnet: isBuildnet);
});
