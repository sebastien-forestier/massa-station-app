class Env {
  static const grpcHost = String.fromEnvironment(
    'grpc_host',
    defaultValue: 'buildnet.massa.net',
  );
  static const grpcPort = int.fromEnvironment(
    'grpc_port',
    defaultValue: 33037,
  );

  static const jrpcHost = String.fromEnvironment(
    'jrpc_host',
    defaultValue: 'mainnet.massa.net',
  );
  static const jrpVersion = String.fromEnvironment(
    'jrpc_port',
    defaultValue: "api/v2",
  );
}
