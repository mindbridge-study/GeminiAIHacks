//
//  Generated code. Do not modify.
//  source: route_guide.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'route_guide.pb.dart' as $0;

export 'route_guide.pb.dart';

@$pb.GrpcServiceName('routeguide.RouteGuide')
class RouteGuideClient extends $grpc.Client {
  static final _$ping = $grpc.ClientMethod<$0.PingRequest, $0.PingResponse>(
      '/routeguide.RouteGuide/Ping',
      ($0.PingRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.PingResponse.fromBuffer(value));
  static final _$uploadImage = $grpc.ClientMethod<$0.ImageChunk, $0.UploadStatus>(
      '/routeguide.RouteGuide/UploadImage',
      ($0.ImageChunk value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.UploadStatus.fromBuffer(value));
  static final _$bidirectionalImageTransfer = $grpc.ClientMethod<$0.ImageChunk, $0.ImageChunk>(
      '/routeguide.RouteGuide/BidirectionalImageTransfer',
      ($0.ImageChunk value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ImageChunk.fromBuffer(value));

  RouteGuideClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.PingResponse> ping($0.PingRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$ping, request, options: options);
  }

  $grpc.ResponseFuture<$0.UploadStatus> uploadImage($async.Stream<$0.ImageChunk> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$uploadImage, request, options: options).single;
  }

  $grpc.ResponseStream<$0.ImageChunk> bidirectionalImageTransfer($async.Stream<$0.ImageChunk> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$bidirectionalImageTransfer, request, options: options);
  }
}

@$pb.GrpcServiceName('routeguide.RouteGuide')
abstract class RouteGuideServiceBase extends $grpc.Service {
  $core.String get $name => 'routeguide.RouteGuide';

  RouteGuideServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PingRequest, $0.PingResponse>(
        'Ping',
        ping_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PingRequest.fromBuffer(value),
        ($0.PingResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImageChunk, $0.UploadStatus>(
        'UploadImage',
        uploadImage,
        true,
        false,
        ($core.List<$core.int> value) => $0.ImageChunk.fromBuffer(value),
        ($0.UploadStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImageChunk, $0.ImageChunk>(
        'BidirectionalImageTransfer',
        bidirectionalImageTransfer,
        true,
        true,
        ($core.List<$core.int> value) => $0.ImageChunk.fromBuffer(value),
        ($0.ImageChunk value) => value.writeToBuffer()));
  }

  $async.Future<$0.PingResponse> ping_Pre($grpc.ServiceCall call, $async.Future<$0.PingRequest> request) async {
    return ping(call, await request);
  }

  $async.Future<$0.PingResponse> ping($grpc.ServiceCall call, $0.PingRequest request);
  $async.Future<$0.UploadStatus> uploadImage($grpc.ServiceCall call, $async.Stream<$0.ImageChunk> request);
  $async.Stream<$0.ImageChunk> bidirectionalImageTransfer($grpc.ServiceCall call, $async.Stream<$0.ImageChunk> request);
}
