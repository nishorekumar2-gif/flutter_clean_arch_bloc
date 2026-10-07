import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_clean_arch/data/datasources/dio_client.dart';
import 'package:flutter_clean_arch/data/models/home_details_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

HomeScreenBloc createHomeScreenViewModel() {
  final dataSource = HomeDataSource(dioClient);
  final repository = HomeRepositoryImpl(dataSource);
  return HomeScreenBloc(HomeScreenUseCases(repository));
}

abstract class HomeScreenEvent {}

class HomeScreenRequested extends HomeScreenEvent {
  final String userId;
  HomeScreenRequested(this.userId);
}

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final HomeScreenUseCases homeScreenUseCases;

  HomeScreenBloc(this.homeScreenUseCases) : super(HomeScreenState.initial()) {
    on<HomeScreenRequested>(_onHomeScreenRequested);
  }

  Future<void> execute(String userId) async {
    add(HomeScreenRequested(userId));
  }

  Future<void> _onHomeScreenRequested(
    HomeScreenRequested event,
    Emitter<HomeScreenState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final homedetails = await homeScreenUseCases.execute(event.userId);
      debugPrint("HomeDetails : ${homedetails.limit}");
      debugPrint("HomeDetails : ${homedetails.products![0].title}");
      emit(state.copyWith(isLoading: false, homedetails: homedetails));
    } catch (ex) {
      emit(state.copyWith(isLoading: false, error: "Something went to wrong"));
    }
  }
}

////// Domain layer /////////

class HomeScreenState {
  final bool isLoading;
  final String? error;
  final HomeDetailsModel? homedetails;

  const HomeScreenState({this.isLoading = false, this.error, this.homedetails});

  HomeScreenState copyWith({
    bool? isLoading,
    String? error,
    HomeDetailsModel? homedetails,
    bool clearError = false,
  }) {
    return HomeScreenState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      homedetails: homedetails ?? this.homedetails,
    );
  }

  factory HomeScreenState.initial() {
    return const HomeScreenState(isLoading: true);
  }
}

abstract class HomeRepository {
  Future<HomeDetailsModel> getHomeDetails(String userId);
}

class HomeRepositoryImpl extends HomeRepository {
  HomeDataSource homeDataSource;
  HomeRepositoryImpl(this.homeDataSource);
  @override
  Future<HomeDetailsModel> getHomeDetails(String userId) {
    return homeDataSource.getHomeDetails(userId);
  }
}

class HomeScreenUseCases {
  HomeRepository homeRepository;
  HomeScreenUseCases(this.homeRepository);
  Future<HomeDetailsModel> execute(String userId) {
    return homeRepository.getHomeDetails(userId);
  }
}

class HomeDataSource {
  Dio dio;
  HomeDataSource(this.dio);

  Future<HomeDetailsModel> getHomeDetails(String userId) async {
    final response = await dio.get("/products");
    debugPrint("Response home details: $response");
    return HomeDetailsModel.fromJson(response.data as Map<String, dynamic>);
  }
}
