import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_arch/data/datasources/dio_client.dart';
import 'package:flutter_clean_arch/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/////Registration view model//////

///////Presentation layer//////
RegistrationBloc createRegistrationViewModel() {
  final registrationDataStore = RegistrationDataSource(dioClient);
  final repository = RegistrationRepositoryImpl(registrationDataStore);
  return RegistrationBloc(RegistrationUseCase(repository));
}

abstract class RegistrationEvent {}

class RegistrationSubmitted extends RegistrationEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;

  RegistrationSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}

class RegistrationState {
  final UserModel? user;
  final String? error;
  final bool isLoading;

  const RegistrationState({this.user, this.error, this.isLoading = false});

  RegistrationState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool clearError = false,
  }) {
    return RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final RegistrationUseCase registrationUseCase;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RegistrationBloc(this.registrationUseCase)
    : super(const RegistrationState()) {
    on<RegistrationSubmitted>(_onRegistrationSubmitted);
  }

  Future<void> register(
    String firstName,
    String lastName,
    String email,
    String password,
    String confirmPassword,
  ) async {
    add(
      RegistrationSubmitted(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      ),
    );
  }

  Future<void> _onRegistrationSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    if (event.password != event.confirmPassword) {
      emit(state.copyWith(isLoading: false, error: 'Passwords do not match'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final user = await registrationUseCase.execute(
        event.firstName,
        event.lastName,
        event.email,
        event.password,
        event.confirmPassword,
      );
      emit(state.copyWith(isLoading: false, user: user, clearError: true));
      firstNameController.text = user.firstName ?? '';
      lastNameController.text = user.lastName ?? '';
      emailController.text = user.email ?? '';
    } catch (ex) {
      emit(state.copyWith(isLoading: false, error: 'Registration failed'));
    }
  }

  @override
  Future<void> close() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}

/////// Domain layer //////
class RegistrationUseCase {
  final RegistrationRepository registrationRepository;

  RegistrationUseCase(this.registrationRepository);

  Future<UserModel> execute(
    String firstName,
    String lastName,
    String email,
    String password,
    String confirmPassword,
  ) {
    return registrationRepository.registrationCall(
      firstName,
      lastName,
      email,
      password,
      confirmPassword,
    );
  }
}

abstract class RegistrationRepository {
  Future<UserModel> registrationCall(
    String firstName,
    String lastName,
    String email,
    String password,
    String confirmPassword,
  );
}

///// Data layer//////
class RegistrationRepositoryImpl extends RegistrationRepository {
  final RegistrationDataSource registrationDataStore;

  RegistrationRepositoryImpl(this.registrationDataStore);

  @override
  Future<UserModel> registrationCall(
    String firstName,
    String lastName,
    String email,
    String password,
    String confirmPassword,
  ) {
    return registrationDataStore.registrationCall(
      firstName,
      lastName,
      email,
      password,
      confirmPassword,
    );
  }
}

class RegistrationDataSource {
  final Dio dio;

  RegistrationDataSource(this.dio);

  Future<UserModel> registrationCall(
    String firstName,
    String lastName,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final response = await dio.post(
      '/users',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
