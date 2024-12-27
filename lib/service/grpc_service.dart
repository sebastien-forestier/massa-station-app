// Package imports:

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:massa/massa.dart';
import 'package:massa/src/grpc/generated/public.pbgrpc.dart';

// Project imports:
import 'package:mug/env/env.dart';

abstract interface class GrpcService {
  /// read only smart contract call
  Future<Uint8List> scReadOnlyCall(
      {required double maximumGas,
      required String smartContracAddress,
      required String functionName,
      required Uint8List functionParameters});

  Future<Uint8List> scCall(
      {required Account account,
      required double fee,
      required double maximumGas,
      required double coins,
      required String smartContracAddress,
      required String functionName,
      required Uint8List functionParameters});
}

class GrpcServiceImpl implements GrpcService {
  final _grpc = GRPCPublicClient(Env.grpcHost, Env.grpcPort);

  @override
  Future<Uint8List> scReadOnlyCall(
      {required double maximumGas,
      required String smartContracAddress,
      required String functionName,
      required Uint8List functionParameters}) async {
    try {
      final response = await _grpc.executeReadOnlyCall(
          minimumFee, maximumGas, smartContracAddress, functionName, functionParameters);
      return Uint8List.fromList(response.callResult);
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<Uint8List> scCall(
      {required Account account,
      required double fee,
      required double maximumGas,
      required double coins,
      required String smartContracAddress,
      required String functionName,
      required Uint8List functionParameters}) async {
    try {
      final status = await _grpc.getStatus();
      print('status: ${status.toProto3Json()}');
      final expirePeriod = status.lastExecutedFinalSlot.period + status.config.operationValidityPeriods * 10;

      final operation = await callSC(
          account, smartContracAddress, functionName, functionParameters, fee, maximumGas, coins, expirePeriod.toInt());
      Uint8List data = Uint8List.fromList([]);

      await for (final resp in _grpc.sendOperations([operation])) {
        print('service response: ${resp.toProto3Json()}');
        final opID = resp.operationIds.operationIds[0];
        print('operation id: $opID');
        while (true) {
          final filter = ScExecutionEventsFilter(originalOperationId: opID);
          final event = await _grpc.getScExecutionEvents([filter]);

          if (event.isNotEmpty) {
            print('service event: ${event[0].toProto3Json()}');
            var dataString = bytesToUtf8String(Uint8List.fromList(event[0].data));
            print(dataString);
            data = Uint8List.fromList(event[0].data);
            break;
          }
        }
        break;
      }
      return data;
    } catch (error) {
      throw Exception(error);
    }
  }
}
