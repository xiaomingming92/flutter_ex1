import 'package:dio/dio.dart';

/// 请求取消管理器
class RequestCancelManager {
  static final Map<String, CancelToken> _cancelTokens = {};

  /// 创建或获取指定请求的CancelToken
  static CancelToken getCancelToken(String requestKey) {
    // 如果已存在，先取消之前的请求
    if (_cancelTokens.containsKey(requestKey)) {
      _cancelTokens[requestKey]!.cancel('请求被新的请求取代');
    }
    
    // 创建新的CancelToken
    final cancelToken = CancelToken();
    _cancelTokens[requestKey] = cancelToken;
    return cancelToken;
  }

  /// 取消指定请求
  static void cancelRequest(String requestKey) {
    if (_cancelTokens.containsKey(requestKey)) {
      _cancelTokens[requestKey]!.cancel('请求被取消');
      _cancelTokens.remove(requestKey);
    }
  }

  /// 取消所有请求
  static void cancelAllRequests() {
    for (final cancelToken in _cancelTokens.values) {
      cancelToken.cancel('所有请求被取消');
    }
    _cancelTokens.clear();
  }

  /// 移除已完成的请求的CancelToken
  static void removeCancelToken(String requestKey) {
    _cancelTokens.remove(requestKey);
  }
}