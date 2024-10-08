import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:med_ease/Modules/testModule.dart';
import 'package:med_ease/Utils/Colors.dart';
import 'package:med_ease/Utils/errorHandiling.dart';
import 'package:meta/meta.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';

part 'all_doctors_event.dart';
part 'all_doctors_state.dart';

class AllDoctorsBloc extends Bloc<AllDoctorsEvent, AllDoctorsState> {
  AllDoctorsBloc() : super(AllDoctorsInitial()) {
    on<AllDoctorsDataEvent>((event, emit) async {
      emit(AllDoctorsDataLoding());
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('x-auth-token-w');
        if (token == null) {
          return emit(AllDoctorsDataFailure(error: "No Auth token"));
        }
        final String searchh = event.search;
        print(searchh);
        http.Response res = await http.post(
            Uri.parse("$ip/User/SearchDoctor?name=$searchh"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token-w': token,
            });
        _httpErrorHandle(res, emit, event.context);
        print(res.body);
        List<Doctor> allDoctors = [];

        List<dynamic> jsonResponse =
            jsonDecode(res.body); // Parse the response here
        int length = jsonResponse.length;
        print(length);

        for (int i = 0; i < length; i++) {
          final jsonData = jsonResponse[i];
          print(jsonData);
          Doctor doctor = Doctor.fromJson(jsonData);

          allDoctors.add(doctor);
        }

        print(allDoctors);
        return emit(AllDoctorsDataSuccess(allDoctorsData: allDoctors));
      } catch (e) {
        return emit(AllDoctorsDataFailure(error: e.toString()));
      }
    });
  }
}
