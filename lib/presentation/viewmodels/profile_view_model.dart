import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_arch/data/datasources/dio_client.dart';
import 'package:flutter_clean_arch/data/models/user_details_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProfileBloc createProfileViewModel() {
  final dataSource = ProfileDataSource(dioClient);
  final repository = ProfileRepositoryImpl(dataSource);
  return ProfileBloc(ProfileUseCase(repository));
}

abstract class ProfileEvent {}

class ProfileRequested extends ProfileEvent {
  final String userId;
  ProfileRequested(this.userId);
}

class ProfileUpdateRequested extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String email;

  ProfileUpdateRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
  });
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileUseCase profileUsecases;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  ProfileBloc(this.profileUsecases) : super(const ProfileState()) {
    on<ProfileRequested>((event, emit) async {
      _onProfileRequested(event, emit);
    });
    on<ProfileUpdateRequested>((event, emit) async {
      _onProfileUpdateRequested(event, emit);
    });
  }

  void viewUpdate(User userDetails) {
    firstNameController.text = userDetails.firstName ?? '';
    lastNameController.text = userDetails.lastName ?? '';
    emailController.text = userDetails.email ?? '';
  }

  Future<void> getProfile(String userId) async {
    add(ProfileRequested(userId));
  }

  Future<void> updateProfile(
    String? firstName,
    String? lastName,
    String? email,
  ) async {
    if (firstName == null || lastName == null || email == null) {
      emit(state.copyWith(isLoading: false, error: 'Update Profile error'));
      return;
    }

    add(
      ProfileUpdateRequested(
        firstName: firstName,
        lastName: lastName,
        email: email,
      ),
    );
  }

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final userDetails = await profileUsecases.executeGetProfile(event.userId);
      emit(
        state.copyWith(
          isLoading: false,
          userDetails: userDetails,
          clearError: true,
        ),
      );
      viewUpdate(userDetails);
    } catch (ex) {
      emit(state.copyWith(isLoading: false, error: 'Get Profile failed'));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final userDetails = await profileUsecases.executeUpdateProfile(
        event.firstName,
        event.lastName,
        event.email,
      );
      emit(
        state.copyWith(
          isLoading: false,
          userDetails: userDetails,
          clearError: true,
        ),
      );
      viewUpdate(userDetails);
    } catch (ex) {
      emit(state.copyWith(isLoading: false, error: 'Update Profile error'));
    }
  }

  @override
  Future<void> close() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    return super.close();
  }
}

///// Domain layer //////
//Entities
class ProfileState {
  final bool isLoading;
  final User? userDetails;
  final String? error;

  const ProfileState({this.isLoading = false, this.userDetails, this.error});

  ProfileState copyWith({
    bool? isLoading,
    User? userDetails,
    String? error,
    bool clearError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      userDetails: userDetails ?? this.userDetails,
      error: clearError ? null : error ?? this.error,
    );
  }
}

abstract class ProfileRepository {
  Future<User> getProfile(String userId);
  Future<User> updateProfile(
    String? firstName,
    String? lastName,
    String? email,
  );
}

class ProfileUseCase {
  final ProfileRepository profileRepository;

  ProfileUseCase(this.profileRepository);

  Future<User> executeGetProfile(String userId) {
    return profileRepository.getProfile(userId);
  }

  Future<User> executeUpdateProfile(
    String? firstName,
    String? lastName,
    String? email,
  ) {
    return profileRepository.updateProfile(firstName, lastName, email);
  }
}

///// Data layer /////
class ProfileDataSource {
  final Dio dio;

  ProfileDataSource(this.dio);

  Future<User> updateProfile(
    String? firstName,
    String? lastName,
    String? email,
  ) async {
    final pref = await SharedPreferences.getInstance();
    final userId = pref.getInt("user_id");
    print("Update profile userId : $userId");

    final response = await dio.put(
      '/users/$userId',
      data: {'firstName': firstName, 'lastName': lastName, 'email': email},
      options: Options(headers: {'content-type': 'application/json'}),
    );
    print("Update Response :$response");
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> getProfile(String userId) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accessToken = sharedPreferences.getString("access_token");
    print("Access Token Get in profile: $accessToken");
    final response = await dio.get(
      '/user/me',
      options: Options(
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    print("Get Profile :$response");
    return User.fromJson(response.data as Map<String, dynamic>);
  }
}

class ProfileRepositoryImpl extends ProfileRepository {
  final ProfileDataSource profileDataSource;

  ProfileRepositoryImpl(this.profileDataSource);

  @override
  Future<User> getProfile(String userId) {
    return profileDataSource.getProfile(userId);
  }

  @override
  Future<User> updateProfile(
    String? firstName,
    String? lastName,
    String? email,
  ) {
    return profileDataSource.updateProfile(firstName, lastName, email);
  }
}
