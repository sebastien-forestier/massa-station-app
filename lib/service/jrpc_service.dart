// Package imports:
import 'package:massa/massa.dart';

// Project imports:
import 'package:mug/env/env.dart';

abstract interface class JrpcService {
  Future<Stakers> getStakers();
  Future<Address?> getAddress(String address);
  Future<List<Address>?> getAddresses(List<String> addresses);
}

class JrpcServiceImpl implements JrpcService {
  final _jrpc = JsonrpcPublicApi(Uri.https(Env.jrpcHost, Env.jrpcVersion));

  @override
  Future<Stakers> getStakers() async {
    try {
      return await _jrpc.getStakers();
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<Address?> getAddress(String address) async {
    try {
      var response = await _jrpc.getAddresses([address]);
      if (response!.isNotEmpty) {
        return response[0];
      } else {
        return null;
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<List<Address>?> getAddresses(List<String> addresses) async {
    try {
      var response = await _jrpc.getAddresses(addresses);
      if (response!.isNotEmpty) {
        return response;
      } else {
        return null;
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}
