import 'package:event_bus/event_bus.dart';

EventBus bus = EventBus();

class WebsocketMSG {
  late int level;
  late String msg;
  WebsocketMSG({required this.level, required this.msg});
}

class ClearLogMSG {
  late String msg;
  ClearLogMSG({required this.msg});
}


