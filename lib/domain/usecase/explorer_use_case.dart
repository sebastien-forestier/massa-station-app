// Project imports:
import 'package:mug/domain/entity/entity.dart';
import 'package:mug/utils/exception_handling.dart';

abstract interface class ExplorerUseCase {
  Future<Result<AddressEntity, Exception>> getAddress(String address, bool getTokenBalance);
  Future<Result<BlockEntity, Exception>> getBlock(String hash);
  Future<Result<OperationEntity, Exception>> getOperation(String hash);
  Future<Result<DomainEntity, Exception>> getDomain(String domainName);
  Future<Result<StakersEntity, Exception>> getStakers(int pageNumber);
}
