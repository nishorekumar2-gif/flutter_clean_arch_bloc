import 'package:dio/dio.dart';
import 'package:flutter_clean_arch/data/datasources/auth_data_source.dart';
import 'package:flutter_clean_arch/data/datasources/dio_client.dart';
import 'package:flutter_clean_arch/data/models/user_model.dart';
import 'package:flutter_clean_arch/data/repository_impl/repository_impl.dart';
import 'package:flutter_clean_arch/domain/usecases/use_cases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

LoginBloc createLoginBloc() {
  final dataSource = AuthRemoteDataSource(dioClient);
  final repository = AuthRepositoryImpl(dataSource);
  return LoginBloc(LoginUseCase(repository));
}

abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String username;
  final String password;

  LoginSubmitted({required this.username, required this.password});
}

class LoginReset extends LoginEvent {}

class LoginState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool isLoggedIn;

  const LoginState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isLoggedIn = false,
  });

  LoginState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: clearError ? null : error ?? this.error,
      isLoggedIn: user != null || this.user != null,
    );
  }
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc(this.loginUseCase) : super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>((event, emit) => emit(const LoginState()));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final username = event.username.trim();
    final password = event.password.trim();

    if (username.isEmpty || password.isEmpty) {
      emit(state.copyWith(error: 'Enter required fields'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final user = await loginUseCase.execute(username, password);
      print("User details: ${user.firstName}");
      emit(state.copyWith(isLoading: false, user: user, clearError: true));
    } catch (ex) {
      final errorMessage = ex is DioException
          ? (ex.response?.data is Map
                ? (ex.response?.data['message'] ??
                      ex.response?.data['error'] ??
                      'Login failed')
                : (ex.message ?? 'Login failed'))
          : 'Login failed';
      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }
}

void cancelToken() {
  try {
    dioClient.get(
      "/users",
      cancelToken: CancelToken(),
      queryParameters: {"limit": "50", "page": 1},
    );
  } on DioException catch (ex) {
    if (ex.type == DioExceptionType.connectionTimeout) {
      print("Connection timeout");
    } else if (ex.type == DioExceptionType.receiveTimeout) {
      print("Receieve timeout");
    } else if (ex.type == DioExceptionType.sendTimeout) {
      print("Send timeout");
    } else if (ex.response!.statusCode == 400) {
      print("400 - Bad request -  status code");
    } else if (ex.response!.statusCode == 401) {
      print("401 - UnAuthorized  -  status code");
    } else if (ex.response!.statusCode == 404) {
      print("404 - Page not found -  status code");
    } else if (ex.response!.statusCode == 500) {
      print("500 → Internal Server Error");
    }
  }
}
