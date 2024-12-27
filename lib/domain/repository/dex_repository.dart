// Project imports:
import 'package:dusa/dusa.dart';
import 'package:mug/domain/entity/entity.dart';
import 'package:mug/utils/exception_handling.dart';

abstract interface class DexRepository {
  Future<Result<QuoterEntity, Exception>> findBestPathFromAmountIn(TokenName token1, TokenName token2, double amount);
  Future<Result<QuoterEntity, Exception>> findBestPathFromAmountOut(TokenName token1, TokenName token2, double amount);
  Future<Result<AddressEntity, Exception>> getMASBalance();
  Future<Result<BigInt, Exception>> getTokenBalance(TokenName tokenType);
  Future<Result<(String, bool), Exception>> swapToken(SwapEntity data);
}
