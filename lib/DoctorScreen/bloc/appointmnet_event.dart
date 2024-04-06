part of 'appointmnet_bloc.dart';

@immutable
sealed class AppointmnetEvent {}

class AppointMentDetailsEvent extends AppointmnetEvent {
  final String price;
  final List<TimeSlot> timeSlots;
  final BuildContext context;

  AppointMentDetailsEvent(
      {required this.context, required this.price, required this.timeSlots});
}
