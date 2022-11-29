import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sshello/utils/eventBus.dart';

class ListLogPage extends StatefulWidget {
  const ListLogPage({super.key});

  @override
  State<ListLogPage> createState() => _nameState();
}

class _nameState extends State<ListLogPage> {
  List<Widget> listWsMsg = [];
  StreamSubscription? streamSubscription;
  StreamSubscription? clearLogMSGstreamSubscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("ListLogPage----init执行");
    streamSubscription = bus.on<WebsocketMSG>().listen((event) {
      print(listWsMsg);
      setState(() {
        print("监听执行。。。");
        listWsMsg.insert(
            0,
            MyListTile(
                nowTime: DateTime.now().toString().substring(11, 23),
                wsMsg: event.msg));
      });
    });

    clearLogMSGstreamSubscription = bus.on<ClearLogMSG>().listen((event) {
      print(listWsMsg);
      setState(() {
        print("ClearLogMSG监听执行。。。");
        if (event.msg == "ClearLog") {
          listWsMsg.clear();
          
        }
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (streamSubscription != null) {
      streamSubscription?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("ListLogPage----build执行");
    print(listWsMsg);
    return Container(
      margin: const EdgeInsets.all(15),
      child: ListView.builder(
          itemCount: listWsMsg.length,
          itemBuilder: (context, index) => listWsMsg[index]),
    );
  }

  // @override
  // // TODO: implement wantKeepAlive
  // bool get wantKeepAlive => true;
}

//listTile组件
class MyListTile extends StatefulWidget {
  String nowTime;
  String wsMsg;
  MyListTile({super.key, required this.nowTime, required this.wsMsg});

  @override
  State<MyListTile> createState() => _MyListTilenameState();
}

class _MyListTilenameState extends State<MyListTile> {
  @override
  Widget build(BuildContext context) {
    print("MyListTile----build执行");
    return Container(
        decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Colors.black12, width: 0.5))),
        child: Row(
          children: [
            Expanded(
                flex: 3,
                child: Text(
                  widget.nowTime,
                  style: const TextStyle(fontSize: 12),
                )),
            Expanded(
              flex: 9,
              child: Text(
                widget.wsMsg,
                style: const TextStyle(fontSize: 12),
              ),
            )
          ],
        ));
  }
}

// print("MyListTile----build执行");
//     return SizedBox(
//       height: 15,
//       child: ListTile(
//           leading: Text(
//             DateTime.now().toString().substring(11, 23),
//             style: const TextStyle(fontSize: 13),
//           ),
//           title: Text(
//             widget.wsMsg,
//             style: const TextStyle(fontSize: 13),
//           )),
//     );
