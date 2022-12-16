import 'package:event_bus/event_bus.dart';

EventBus bus = EventBus();

class WebsocketMSG {
  late int level;
  late String msg;
  late String time;
  WebsocketMSG({required this.level, required this.msg,required this.time});
}

class ClearLogMSG {
  late String msg;
  ClearLogMSG({required this.msg});
}


