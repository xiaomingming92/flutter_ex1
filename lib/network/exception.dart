abstract class APPException implements Exception {
  final String message;
  APPException(this.message);
}

enum NetworkError {
  timeout,
  cancelled,
  noInternet,
  unknown,
  serverError,
}

enum HttpStatusCategory {
  success,      // 2xx
  redirect,     // 3xx
  clientError,  // 4xx
  serverError,  // 5xx
}

class NetworkException extends APPException {
  final NetworkError error;
  final int? statusCode;
  NetworkException(this.error, super.message, {this.statusCode});
}

class HttpStatusException extends APPException {
  final int statusCode;
  final HttpStatusCategory category;
  final dynamic responseData; // 可能包含业务错误信息
  
  HttpStatusException(
    this.statusCode,
    this.category,
    super.message, {
    this.responseData,
  });
  
  /// 从 HTTP 状态码创建异常
  factory HttpStatusException.fromStatusCode(int statusCode, {dynamic responseData}) {
    HttpStatusCategory category;
    String message;
    
    if (statusCode >= 200 && statusCode < 300) {
      category = HttpStatusCategory.success;
      message = '请求成功';
    } else if (statusCode >= 300 && statusCode < 400) {
      category = HttpStatusCategory.redirect;
      message = '请求重定向';
    } else if (statusCode >= 400 && statusCode < 500) {
      category = HttpStatusCategory.clientError;
      switch (statusCode) {
        case 400:
          message = '请求参数错误';
          break;
        case 401:
          message = '未授权，请重新登录';
          break;
        case 403:
          message = '拒绝访问';
          break;
        case 404:
          message = '请求的资源不存在';
          break;
        default:
          message = '客户端错误';
      }
    } else {
      category = HttpStatusCategory.serverError;
      message = '服务器错误';
    }
    
    return HttpStatusException(statusCode, category, message, responseData: responseData);
  }
}

class BusinessExpection extends APPException {
  final int code;
  BusinessExpection(super.message, this.code);
}

class ProtocolException extends APPException {
  ProtocolException(super.message);
}