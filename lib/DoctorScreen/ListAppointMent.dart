import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_ease/UpdateModels/UpdateDoctorModule.dart';

class ListAppointmentScreen extends StatefulWidget {
  ListAppointmentScreen({Key? key}) : super(key: key);

  @override
  _ListAppointmentScreenState createState() => _ListAppointmentScreenState();
}

class _ListAppointmentScreenState extends State<ListAppointmentScreen> {
  @override
  Widget build(BuildContext context) {
    final doctorModel = context.watch<DoctorBloc>().state;
    print(doctorModel!.applicationLeft.length);
    print("heoolo");
    return Scaffold(
        appBar: AppBar(
          title: Text("List of Appointments"),
        ),
        body: ListView.builder(
          itemCount: doctorModel.applicationLeft.length,
          itemBuilder: (BuildContext context, int index) {
            final appointment = doctorModel.applicationLeft[index];
            return Card(
              child: ListTile(
                title: Text('Appointment ID: ${appointment.id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User ID: ${appointment.userId}'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: appointment.appointMentDetails!.map((detail) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${detail.date}'),
                            Text('User ID: ${detail.userId}'),
                            Text('Is Complete: ${detail.isComplete}'),
                            Divider(),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
