import 'package:mug/domain/entity/transaction_entity.dart';

class BlockEntity {
  String? hash;
  bool? isFinal;
  String? blockTime;
  String? creatorAddress;
  int? operationCount;
  int? endorsements;
  List<String>? parents;
  bool? isInBlockclique;
  int? blockReward;
  int? blockSize;
  int? thread;
  int? period;
  String? signature;
  String? creatorPublicKey;
  List<TransactionEntity>? latestOps;

  BlockEntity(
      {this.hash,
      this.isFinal,
      this.blockTime,
      this.creatorAddress,
      this.operationCount,
      this.endorsements,
      this.parents,
      this.isInBlockclique,
      this.blockReward,
      this.blockSize,
      this.thread,
      this.period,
      this.signature,
      this.creatorPublicKey,
      this.latestOps});
}
