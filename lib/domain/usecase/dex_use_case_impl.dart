// Package imports:
import 'package:dusa/dusa.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mug/data/repository/dex_repository_impl.dart';
import 'package:mug/domain/entity/entity.dart';

// Project imports:
import 'package:mug/domain/repository/dex_repository.dart';
import 'package:mug/domain/usecase/dex_use_case.dart';
import 'package:mug/utils/exception_handling.dart';

class DexUseCaseImpl implements DexUseCase {
  final DexRepository repository;

  DexUseCaseImpl({
    required this.repository,
  });

  @override
  Future<Result<QuoterEntity, Exception>> findBestPathFromAmountIn(
      TokenName token1, TokenName token2, double amount) async {
    try {
      return await repository.findBestPathFromAmountIn(token1, token2, amount);
    } on Exception catch (error) {
      return Failure(exception: error);
    }
  }

  @override
  Future<Result<QuoterEntity, Exception>> findBestPathFromAmountOut(
      TokenName token1, TokenName token2, double amount) async {
    try {
      return await repository.findBestPathFromAmountOut(token1, token2, amount);
    } on Exception catch (error) {
      return Failure(exception: error);
    }
  }

  @override
  Future<Result<AddressEntity, Exception>> getMASBalance() async {
    try {
      return await repository.getMASBalance();
    } on Exception catch (error) {
      return Failure(exception: error);
    }
  }

  @override
  Future<Result<double, Exception>> getTokenBalance(TokenName tokenType) async {
    try {
      final result = await repository.getTokenBalance(tokenType);
      return switch (result) {
        Success(value: final value) => Success(value: bigIntToDecimal(value, getTokenDecimal(tokenType))),
        Failure(exception: final exception) => Failure(exception: Exception("unable to get token balance: $exception"))
      };
    } on Exception catch (error) {
      return Failure(exception: error);
    }
  }

  @override
  Future<Result<(String, bool), Exception>> swapToken(SwapEntity data) async {
    try {
      return await repository.swapToken(data);
    } on Exception catch (error) {
      return Failure(exception: error);
    }
  }
}

final dexUseCaseProvider = Provider<DexUseCase>((ref) {
  return DexUseCaseImpl(repository: ref.watch(dexRepositoryProvider));
});
