import 'package:clarity/core/error/exceptions.dart';
import 'package:clarity/core/error/failure.dart';
import 'package:dio/dio.dart';

class ApiErrorHandler {
  /// Converts Dio or generic errors into domain-level Failures
  static Failure handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ServerFailure(ErrorMessages.requestTimeout);

        case DioExceptionType.connectionError:
          return ServerFailure(ErrorMessages.noInternet);

        case DioExceptionType.cancel:
          return ServerFailure('Request cancelled by user');

        case DioExceptionType.badResponse:
          return _handleBadResponse(error.response);

        default:
          return ServerFailure(ErrorMessages.unexpectedError);
      }
    } else if (error is CustomException) {
      // custom logic exception (from fake or local)
      return CacheFailure(error.message);
    } else if (error is Exception) {
      return ServerFailure(ErrorMessages.getErrorMessage(error));
    } else {
      return ServerFailure(ErrorMessages.unexpectedError);
    }
  }

  /// Handles server-level HTTP errors (400–500)
  static Failure _handleBadResponse(Response? response) {
    if (response == null) return ServerFailure(ErrorMessages.unexpectedError);

    final data = response.data;

    if (data is Map<String, dynamic>) {
      // If API returns message
      if (data.containsKey('message') && data['message'] is String) {
        return ServerFailure(data['message']);
      }

      // If API returns structured validation errors
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        if (errors.containsKey('email')) {
          final emailErrors = errors['email'];
          if (emailErrors is List && emailErrors.isNotEmpty) {
            return ServerFailure(emailErrors.first.toString());
          }
        }

        if (errors.containsKey('generalErrors')) {
          final general = errors['generalErrors'];
          if (general is List && general.isNotEmpty) {
            return ServerFailure(general.first.toString());
          }
        }
      }
    }

    // Fallback: map by status code
    switch (response.statusCode) {
      case 400:
        return ServerFailure(ErrorMessages.badRequest);
      case 401:
        return ServerFailure(ErrorMessages.unauthorized);
      case 403:
        return ServerFailure(ErrorMessages.forbidden);
      case 404:
        return ServerFailure(ErrorMessages.notFound);
      case 409:
        return ServerFailure(ErrorMessages.emailAlreadyExists);
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerFailure(ErrorMessages.serverError);
      default:
        return ServerFailure(ErrorMessages.unexpectedError);
    }
  }
}

class ErrorMessages {
  static const String requestTimeout = "Request timed out. Please try again.";
  static const String noInternet =
      "No internet connection. Please check your network.";
  static const String unexpectedError =
      "An unexpected error occurred. Please try again.";
  static const String badRequest = "Bad request. Please check your input.";
  static const String unauthorized = "Unauthorized access. Please log in.";
  static const String forbidden =
      "Forbidden. You don't have permission to access this resource.";
  static const String notFound = "Resource not found.";
  static const String emailAlreadyExists =
      "The email address is already registered.";
  static const String serverError = "Server error. Please try again later.";

  static String getErrorMessage(Exception error) {
    return error.toString();
  }
}
