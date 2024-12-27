import 'package:mug/service/explorer_api.dart';

void main(List<String> args) async {
  const ipAddress = 'explorer-api.massa.net';
  final uri = Uri(scheme: 'https', host: ipAddress);
  final client = ExplorerApi(uri);

  //address
  // const address = 'AU12Vi9V6Fsq9HMh9ge88WJ5cgymBGc3oUX2F6WpRqA5HdabPcPt5';
  // final resp = await client.getAddress(address);
  // print("address: ${resp!.encode()}");

  // //block
  const block = 'B1EseudYR3DqKWKivJzbUtwiqNmc2k8Q7rUaH8t6s5Vxsghau9P';
  final blockResp = await client.getBlock(block);
  print("block: ${blockResp!.encode()}");

  // const operation = 'O1rn46o4simA333wN1VPRM5rcTpEYEMepSnuBxcfgx5vRTRgSWz';
  // final operationResp = await client.getOperation(operation);
  // print("operation: ${operationResp!.encode()}");

  // const page = 2;
  // final stakersResp = await client.getStakers(page);
  // print("number of stakes in page $page is ${stakersResp?.stakers?.length}");
  // //print("stakers: ${stakersResp!.encode()}");

  // //address history
  // bool from = true;
  // bool to = true;
  // final history = await client.getAddressHistory(address, from, to);
  // //print('history: ${history?.encode()}');
  // final history2 = await client.getAddressHistory(address, from, to,
  //     cursorCreated: history?.nextCursorCreated, cursorReceived: history?.nextCursorReceived);
  // print('history2: ${history2?.encode()}');

  // //get domains
  // const domainAddress = 'AU12AJNexMD9wGyoq78rL8P6pH851eEdLNwimMfHgcCCwU48dQuRR';
  // final domains = await client.getAddressDomains(domainAddress);
  // print('domains: $domains');

  // //get domain details
  // const domain = 'sendhere';
  // final details = await client.getDomainDetails(domain);
  // print('domain details: ${details?.encode()}');
}
