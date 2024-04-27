/*
* This Class exists to establish a connection to the gRPC backend with functionality
*/

import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:camera/camera.dart';
import 'generated/route_guide.pbgrpc.dart';
import 'package:path_provider/path_provider.dart';

class Client {
  late RouteGuideClient stub;
  late ClientChannel channel;

  Client() {
    channel = ClientChannel('0.0.0.0',
        port: 50051,
        options: const ChannelOptions(credentials: ChannelCredentials.insecure()));
    stub = RouteGuideClient(channel);
  }

  Future<void> shutdown() async {
    await channel.shutdown();
  }

  Future<bool> runPing() async {
    final response = await stub.ping(PingRequest(data: 'Hello Server!'));
    if (response.data == 'Hello Client!') {
      return true;
    } else {
      return false;
    }
  }

  Future<void> runUploadImage(XFile imageFile) async {
    Stream<ImageChunk> generateImageChunks(XFile file) async* {
      final fileStream = file.openRead();
      const chunkSize = 1024; // Define the size of chunks

      await for (final chunk in fileStream) {
        yield ImageChunk(data: chunk.sublist(0, chunk.length < chunkSize ? chunk.length : chunkSize));
      }
    }

    await stub.uploadImage(generateImageChunks(imageFile));
  }

  Future<XFile> runBidirectionalImageTransfer(XFile imageFile) async {
    Stream<ImageChunk> sendImageChunks(XFile file) async* {
      final fileStream = file.openRead();
      const chunkSize = 1024; // Define the size of chunks

      await for (final chunk in fileStream) {
        yield ImageChunk(data: chunk.sublist(0, chunk.length < chunkSize ? chunk.length : chunkSize));
      }
    }

    final call = stub.bidirectionalImageTransfer(sendImageChunks(imageFile));
    final List<int> receivedData = [];
    await for (var receivedChunk in call) {
      receivedData.addAll(receivedChunk.data);
    }
    // Write the received data to a file
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/received_image';
    final file = File(filePath);
    await file.writeAsBytes(receivedData);

    return XFile(filePath);
  }
}
