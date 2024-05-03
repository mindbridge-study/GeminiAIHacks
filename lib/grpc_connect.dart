import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:camera/camera.dart';
import 'generated/route_guide.pbgrpc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Client {
  late RouteGuideClient stub;
  late ClientChannel channel;

  Client() {
    channel = ClientChannel('0.0.0.0',
        port: 50051,
        options:
            const ChannelOptions(credentials: ChannelCredentials.insecure()));
    stub = RouteGuideClient(channel);
  }

  Future<void> shutdown() async {
    await channel.shutdown();
  }

  Future<bool> runPing() async {
    final callOptions = await _getCallOptions();
    final response = await stub.ping(PingRequest(data: 'Hello Server!'),
        options: callOptions);
    return response.data == 'Hello Client!';
  }

  Future<void> runUploadImage(File imageFile) async {
    // Converts File to Stream<ImageChunk> for gRPC streaming
    Stream<ImageChunk> generateImageChunks(File file) async* {
      final fileStream = file.openRead();
      const chunkSize = 1024; // Size of each chunk

      await for (final chunk in fileStream) {
        yield ImageChunk(
            data: chunk.sublist(
                0, chunk.length < chunkSize ? chunk.length : chunkSize));
      }
    }

    final callOptions = await _getCallOptions();
    await stub.uploadImage(generateImageChunks(imageFile),
        options: callOptions);
  }

  Future<String?> getIdToken() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    throw Exception('Not authenticated');
  }

  Future<CallOptions> _getCallOptions() async {
    String? token = await getIdToken();
    return CallOptions(metadata: {'authorization': 'Bearer $token'});
  }
}
