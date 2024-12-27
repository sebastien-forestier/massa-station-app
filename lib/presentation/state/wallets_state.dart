// Project imports:

// Project imports:
import 'package:mug/data/model/wallet_model.dart';

sealed class WalletsState {}

final class WalletInitial extends WalletsState {}

final class WalletLoading extends WalletsState {}

final class WalletEmpty extends WalletsState {
  final String message;
  WalletEmpty({required this.message});
}

final class WalletSuccess extends WalletsState {
  final WalletData wallets;
  WalletSuccess({required this.wallets});
}

final class WalletFailure extends WalletsState {
  final String message;
  WalletFailure({required this.message});
}
