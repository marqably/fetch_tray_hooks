import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fetch_tray/fetch_tray.dart';

import 'package:flutter/widgets.dart';
import 'package:mockito/mockito.dart';

import './use_make_tray_request.mocks.dart';

// @GenerateMocks([http.Client])
class LazyTrayRequestHookResponse {
  final Future<TrayRequestResponse<ResultType>> Function<ResultType>(
    TrayRequest request, {
    FetchTrayDebugLevel? requestDebugLevel,
  }) makeRequest;

  LazyTrayRequestHookResponse({
    required this.makeRequest,
  });
}

/// a simple hook to make an http request
///
/// If [lazyRun] is set to true, the mutation will not run directly, but has to be triggered manually. This is useful for POST/PUT/DELETE requests.
LazyTrayRequestHookResponse useMakeLazyTrayRequest({
  Dio? client,
  TrayRequestMock? mock,
  FetchTrayDebugLevel? requestDebugLevel,
}) {
  // final fetchResult = useState<LazyTrayRequestHookResponse<ResultType>?>(
  //   LazyTrayRequestHookResponse<ResultType>(),
  // );

  // create the mock client
  final mockClient = MockDio();

  return LazyTrayRequestHookResponse(makeRequest: <ResultType>(
    TrayRequest request, {
    FetchTrayDebugLevel? requestDebugLevel,
  }) async {
    // await values
    final url = Uri.parse(await request.getUrlWithParams());
    final headers = await request.getHeaders();
    final body = await request.getBody();

    // mock request response
    when(mockClient.request(
      url.toString(),
      data: body,
      options: Options(
        headers: headers,
        responseType: ResponseType.json,
      ),
    )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        data: mock?.result ?? '',
        statusCode: mock?.statusCode ?? 200,
      ),
    );

    // if we are in mocking mode -> take `makeTrayTestingRequest` otherwise use `makeTrayRequest`
    final makeTrayRequestMethod = (mock != null)
        ? makeTrayTestingRequest<ResultType>(request, mock)
        : makeTrayRequest<ResultType>(request,
            client: client, requestDebugLevel: requestDebugLevel);

    try {
      final response =
          await makeTrayRequestMethod.catchError((error, stacktrace) async {
        // log error
        log(
          'SHOULD NOT SHOW: An error happened with url: ${await request.getUrlWithParams()}: $error',
          error: error,
          stackTrace: stacktrace,
        );

        // print out the source if something is sent along
        return TrayRequestResponse<ResultType>(
          error: TrayRequestError(
            errors: error.toString(),
            message: 'There was an unexpected error while fetching data!',
            statusCode: 500,
          ),
          data: null,
        );
      });

      // log error
      // if (debugLevel == FetchTrayDebugLevel.) {
      //   log('${request.method} REQUEST: ${request.getUrlWithParams()}: ');
      // }

      return response;
    } catch (err, stacktrace) {
      // log error
      log(
        'An error happened with url: ${request.getUrlWithParams()}: $err',
        error: err,
        stackTrace: stacktrace,
      );

      // print out the source if something is sent along
      debugPrint(err.toString());

      return TrayRequestResponse(
        error: TrayRequestError(
          errors: err.toString(),
          message: 'There was an unexpected error while fetching data!',
          statusCode: 500,
        ),
        data: null,
      );
    }
  });
}
