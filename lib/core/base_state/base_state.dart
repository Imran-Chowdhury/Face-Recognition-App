// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// enum Status {
//   initial,
//   loading,
//   success,
//   error,
// }
//
// class BaseState<T> {
//   final Status status;
//   final T? data;
//   final String? errorMessage;
//
//   BaseState({
//     required this.status,
//     this.data,
//     this.errorMessage,
//   });
//
//   factory BaseState.initial() {
//     return BaseState(status: Status.initial);
//   }
//
//   factory BaseState.loading() {
//     return BaseState(status: Status.loading);
//   }
//
//   factory BaseState.success(T data) {
//     return BaseState(status: Status.success, data: data);
//   }
//
//   factory BaseState.error(String errorMessage) {
//     return BaseState(status: Status.error, errorMessage: errorMessage);
//   }
// }
//



abstract class BaseState{
  const BaseState();
}

class InitialState extends BaseState{
  const InitialState();
}

class LoadingState<T> extends BaseState{
  const  LoadingState({this.data});

  final T? data;
}

class SuccessState<T> extends BaseState {
  const SuccessState({this.data, this.name});

  final T? data;
  final T? name;
}


class ErrorState extends BaseState {
  final String errorMessage;

  const ErrorState(this.errorMessage);
}