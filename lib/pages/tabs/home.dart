import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart' as homeGet;
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'package:sshello/setting.dart';
import 'package:sshello/utils/eventBus.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sshello/utils/sharedPreferences.dart';

import 'package:web_socket_channel/status.dart' as wschannelstatus;
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _nameState();
}

final _formKey = GlobalKey<FormState>();
final _form2Key = GlobalKey<FormState>();
bool globalRunStatus = false;

AudioPlayer player = AudioPlayer();
List sucessfulOrders = [];

class _nameState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    print("HomePage----initState----build");
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    print("HomePage----build");
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
            backgroundColor: Colors.white,
            bottom: TabBar(
                isScrollable: true,
                indicatorColor: Colors.yellow,
                indicatorWeight: 2,
                indicatorPadding: const EdgeInsets.all(5),
                // indicatorSize:TabBarIndicatorSize.label,
                labelColor: Colors.black,
                // unselectedLabelColor: Colors.white,
                labelStyle: const TextStyle(fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                indicator: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10)),
                controller: _tabController, //???????????????controller????????????TabBar?????????const
                tabs: const [
                  Tab(
                    child: Text("????????????"),
                  ),
                  Tab(
                    child: Text("???????????????"),
                  ),
                ])),
      ),
      body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Container(margin: const EdgeInsets.all(10), child: FormPage()),
            Container(margin: const EdgeInsets.all(10), child: FormPage2())
          ]),
    );
  }
}

// form ??????
class FormPage extends StatefulWidget {
  const FormPage({
    super.key,
  });

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _tokenTextEditingController =
      TextEditingController(); //Token
  final TextEditingController _match_car_typeTextEditingController =
      TextEditingController(); //????????????
  final TextEditingController _screen_car_typeTextEditingController =
      TextEditingController(); //????????????
  final TextEditingController _target_addressTextEditingController =
      TextEditingController(); //???????????????
  final TextEditingController _screen_addressTextEditingController =
      TextEditingController(); //???????????????
  final TextEditingController _min_distanceTextEditingController =
      TextEditingController(); //????????????
  final TextEditingController _max_distanceTextEditingController =
      TextEditingController(); //????????????
  final TextEditingController _min_priceTextEditingController =
      TextEditingController(); //????????????

  String _phone = ""; //????????????
  String _token = ""; //TokenR
  String _match_car_type = ""; //????????????
  String _screen_car_type = ""; //????????????
  String _target_address = ""; //???????????????
  String _screen_address = ""; //???????????????
  int _min_distance = 0; //????????????
  int _max_distance = 1000; //????????????
  int _min_price = 0; //????????????
  int _time_interval = 1000; //????????????
  List<String> deliver_times = ['????????????', '????????????', '????????????', '????????????'];
  List<bool> deliver_bool = [true, true, true, true];

  bool runStatus = false;
  int loopNumber = 0;
  IOWebSocketChannel? wschannel;

  //????????????????????????
  var lastPopTime = DateTime.now();
  var clickInterval = 2;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _min_distanceTextEditingController.text = _min_distance.toString();
    _max_distanceTextEditingController.text = _max_distance.toString();
    _min_priceTextEditingController.text = _min_price.toString();
  }

  @override
  Widget build(BuildContext context) {
    // print("FormPage----build");
    return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: ListView(children: [
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    // autovalidateMode: AutovalidateMode.onUserInteraction,

                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      _phone = value!;
                    },
                    onChanged: (value) => _phone = value,
                    // focusNode: FocusNode(),
                    validator: (String? value) {
                      return value!.trim().isNotEmpty &&
                              value.trim().length == 11
                          ? null
                          : "????????????11???!";
                    },
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      height: 30,
                      width: 20,
                      child: ElevatedButton(
                          onPressed: () {
                            if (_phone.toString().length == 11) {
                              print("??????11??????,??????????????????http");
                              if (lastPopTime == null ||
                                  DateTime.now().difference(lastPopTime) >
                                      Duration(seconds: clickInterval)) {
                                lastPopTime = DateTime.now();
                                print("????????????");
                                pullPhoneInfo();
                              } else {
                                print("??????????????????");
                              }
                            }
                          },
                          child: const Text("??????")),
                    )),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "Token",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: _tokenTextEditingController,
                    obscureText: true,
                    // readOnly:true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      _token = value!;
                    },
                    validator: (String? value) {
                      return value != null && value.isNotEmpty ? null : "????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: _match_car_typeTextEditingController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      _match_car_type = value!;
                    },
                    validator: (String? value) {
                      return value != null && value.isNotEmpty ? null : "????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: _screen_car_typeTextEditingController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      if (value != null) {
                        _screen_car_type = value;
                      }
                    },
                    // validator: (String? value) {
                    //   return value != null ? null : "????????????";
                    // },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "???????????????",
                      style: TextStyle(fontSize: 12),
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: _target_addressTextEditingController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      _target_address = value!;
                    },
                    validator: (String? value) {
                      return value != null ? null : "????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "???????????????",
                      style: TextStyle(fontSize: 12),
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: _screen_addressTextEditingController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      _screen_address = value!;
                    },
                    validator: (String? value) {
                      return value != null ? null : "????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: _min_distanceTextEditingController,
                    // initialValue: _min_distance.toString(),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      if (value != null) {
                        _min_distance = int.parse(value);
                      }
                    },
                    validator: (String? value) {
                      return value != null &&
                              value.isNotEmpty &&
                              int.tryParse(value) != null
                          ? null
                          : "???????????????????????????";
                    },
                  ),
                ),
                const Expanded(
                    flex: 1,
                    child: Text(
                      "--",
                      textAlign: TextAlign.center,
                    )),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: _max_distanceTextEditingController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      if (value != null) {
                        _max_distance = int.parse(value);
                      }
                    },
                    validator: (String? value) {
                      return value != null &&
                              value.isNotEmpty &&
                              int.tryParse(value) != null
                          ? null
                          : "???????????????????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: _min_priceTextEditingController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      if (value != null) {
                        _min_price = int.parse(value);
                      }
                    },
                    validator: (String? value) {
                      return value != null &&
                              value.isNotEmpty &&
                              int.tryParse(value) != null
                          ? null
                          : "???????????????????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                    )),
                Expanded(
                    flex: 8,
                    child:
                        // TextFormField(
                        //   textAlign: TextAlign.center,
                        //   decoration: const InputDecoration(
                        //     enabledBorder: InputBorder.none,
                        //     focusedBorder: InputBorder.none,
                        //     errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                        //   ),
                        //   onSaved: (value) {
                        //     _times = value;
                        //   },
                        //   validator: (String? value) {
                        //     return value != null ? null : "????????????";
                        //   },
                        // ),
                        Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              child: Text(
                                deliver_times[0],
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                setState(() {
                                  deliver_bool[0] = !deliver_bool[0];
                                  print(deliver_bool);
                                });
                              },
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(1)),
                                  backgroundColor: deliver_bool[0]
                                      ? MaterialStateProperty.all(
                                          const Color.fromARGB(
                                              255, 130, 126, 126))
                                      : MaterialStateProperty.all(Colors.white),
                                  foregroundColor: deliver_bool[0]
                                      ? MaterialStateProperty.all(Colors.white)
                                      : MaterialStateProperty.all(Colors.black),
                                  animationDuration:
                                      const Duration(milliseconds: 1)),
                            )),
                        Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              child: Text(
                                deliver_times[1],
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                setState(() {
                                  deliver_bool[1] = !deliver_bool[1];
                                  print(deliver_bool);
                                });
                              },
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(1)),
                                  backgroundColor: deliver_bool[1]
                                      ? MaterialStateProperty.all(
                                          const Color.fromARGB(
                                              255, 130, 126, 126))
                                      : MaterialStateProperty.all(Colors.white),
                                  foregroundColor: deliver_bool[1]
                                      ? MaterialStateProperty.all(Colors.white)
                                      : MaterialStateProperty.all(Colors.black),
                                  animationDuration:
                                      const Duration(milliseconds: 1)),
                            )),
                        Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              child: Text(
                                deliver_times[2],
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                setState(() {
                                  deliver_bool[2] = !deliver_bool[2];
                                  print(deliver_bool);
                                });
                              },
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(1)),
                                  backgroundColor: deliver_bool[2]
                                      ? MaterialStateProperty.all(
                                          const Color.fromARGB(
                                              255, 130, 126, 126))
                                      : MaterialStateProperty.all(Colors.white),
                                  foregroundColor: deliver_bool[2]
                                      ? MaterialStateProperty.all(Colors.white)
                                      : MaterialStateProperty.all(Colors.black),
                                  animationDuration:
                                      const Duration(milliseconds: 1)),
                            )),
                        Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              child: Text(
                                deliver_times[3],
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                setState(() {
                                  deliver_bool[3] = !deliver_bool[3];
                                  print(deliver_bool);
                                });
                              },
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(1)),
                                  backgroundColor: deliver_bool[3]
                                      ? MaterialStateProperty.all(
                                          const Color.fromARGB(
                                              255, 130, 126, 126))
                                      : MaterialStateProperty.all(Colors.white),
                                  foregroundColor: deliver_bool[3]
                                      ? MaterialStateProperty.all(Colors.white)
                                      : MaterialStateProperty.all(Colors.black),
                                  animationDuration:
                                      const Duration(milliseconds: 1)),
                            )),
                      ],
                    )),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    initialValue: _time_interval.toString(),
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      if (value != null) {
                        _time_interval = int.parse(value);
                      }
                    },
                    validator: (String? value) {
                      return value != null &&
                              value.isNotEmpty &&
                              int.tryParse(value) != null
                          ? null
                          : "???????????????????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 30,
            margin: const EdgeInsets.fromLTRB(50, 30, 50, 0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    runStatus ? Colors.red : Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () {
                setState(() {
                  startRun();
                });
              },
              child: Text(runStatus ? "???????????? $loopNumber" : "????????????"),
            ),
          ),
        ]));
  }

  void startRun() {
    if (!runStatus && wschannel == null) {
      if (_formKey.currentState != null) {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          print(
              "${_phone}----${_token}----${_match_car_type}----${_screen_car_type}----${_target_address}----${_screen_address}----${_min_distance}----${_max_distance}-----${_min_price}----${_time_interval}----");
          print("????????????????????????");
          // print(deliver_bool);
          List new_list = [];

          print("?????????-------------");

          for (var i = 0; i < deliver_bool.length; i++) {
            if (deliver_bool[i]) {
              new_list.add(deliver_times[i]);
            }
          }
          print("?????????---------------");
          // print(new_list);

          // print(deliver_times);
          if (!globalRunStatus) {
            runStatus = true;
            globalRunStatus = true;
            wschannel = IOWebSocketChannel.connect(MyConfig.wsUri);

            wschannel?.sink.add(json.encode({
              "msg": "first_info",
              "phone": _phone,
              "token": _token,
              "match_car_type": _match_car_type,
              "screen_car_type": _screen_car_type,
              "target_address": _target_address,
              "screen_address": _screen_address,
              "min_distance": _min_distance,
              "max_distance": _max_distance,
              "delivery_time": new_list,
              "min_price": _min_price,
              "time_interval": _time_interval,
            }));

            wschannel?.stream.listen((message) {
              var msg_map = json.decode(message);
              if (msg_map["msg"] == "number") {
                setState(() {
                  loopNumber++;
                });
              } else {
                bus.fire(WebsocketMSG(
                    level: msg_map["level"],
                    msg: msg_map["msg"],
                    time: msg_map["time"]));
              }
            });
            print("ws????????????!!");
          } else {
            print("???????????????????????????");
            Fluttertoast.showToast(
                msg: "?????????????????????...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        }
      }
    } else {
      runStatus = false;
      globalRunStatus = false;
      loopNumber = 0;
      wschannel?.sink.close(wschannelstatus.goingAway);
      wschannel = null;
      print("form1-----------------11");
      print(wschannel);
    }
  }

  void pullPhoneInfo() async {
    var dio = Dio();
    Response res = await dio
        .get(MyConfig.pullPhoneInfoUrl, queryParameters: {"phone": _phone});
    print(res.toString());
    Map<String, dynamic> res_data = json.decode(res.toString());

    _tokenTextEditingController.text = _token = res_data["data"]["token"];
    _match_car_typeTextEditingController.text =
        _match_car_type = res_data["data"]["match_car_type"];
    _screen_car_typeTextEditingController.text =
        _screen_car_type = res_data["data"]["screen_car_type"];
    _target_addressTextEditingController.text =
        _target_address = res_data["data"]["target_address"];
    _screen_addressTextEditingController.text =
        _screen_address = res_data["data"]["screen_address"];
    _min_distance = res_data["data"]["min_distance"];
    _min_distanceTextEditingController.text = _min_distance.toString();
    _max_distance = res_data["data"]["max_distance"];
    _max_distanceTextEditingController.text = _max_distance.toString();
    _min_price = res_data["data"]["min_price"];
    _min_priceTextEditingController.text = _min_price.toString();

    print(_token);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

//form2??????
class FormPage2 extends StatefulWidget {
  const FormPage2({super.key});

  @override
  State<FormPage2> createState() => _FormPage2State();
}

class _FormPage2State extends State<FormPage2>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _tokenTextEditingController =
      TextEditingController(); //Token
  final TextEditingController _match_car_typeTextEditingController =
      TextEditingController(); //????????????
  final TextEditingController _screen_car_typeTextEditingController =
      TextEditingController(); //????????????
  final TextEditingController _target_addressTextEditingController =
      TextEditingController(); //???????????????
  final TextEditingController _screen_addressTextEditingController =
      TextEditingController(); //???????????????
  final TextEditingController _min_distanceTextEditingController =
      TextEditingController(); //????????????
  final TextEditingController _max_distanceTextEditingController =
      TextEditingController(); //????????????
  final TextEditingController _min_priceTextEditingController =
      TextEditingController(); //????????????

  String _phone = ""; //????????????
  String _token = ""; //TokenR
  String _match_car_type = ""; //????????????
  String _screen_car_type = ""; //????????????
  String _target_address = ""; //???????????????
  String _screen_address = ""; //???????????????
  int _min_distance = 0; //????????????
  int _max_distance = 1000; //????????????
  int _min_price = 0; //????????????
  int _time_interval = 1000; //????????????
  List<String> deliver_times = ['????????????', '????????????', '????????????', '????????????'];
  List<bool> deliver_bool = [true, true, true, true];
  int _verifyCode = 0;

  // String runText = "????????????";
  int loopNumber = 0;
  bool runStatus = false;
  IOWebSocketChannel? wschannel;

  // ????????????????????????
  var lastPopTime = DateTime.now();
  var clickInterval = 2;

  // ???????????????????????????????????????
  bool sendCodeButtonStatus = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _min_distanceTextEditingController.text = _min_distance.toString();
    _max_distanceTextEditingController.text = _max_distance.toString();
    _min_priceTextEditingController.text = _min_price.toString();
  }

  @override
  Widget build(BuildContext context) {
    print("FormPage2----build");
    return Form(
        key: _form2Key,
        child: ListView(children: [
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    // autovalidateMode: AutovalidateMode.onUserInteraction,

                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      _phone = value!;
                    },
                    onChanged: (value) => _phone = value,
                    // focusNode: FocusNode(),
                    validator: (String? value) {
                      return value!.trim().isNotEmpty &&
                              value.trim().length == 11
                          ? null
                          : "????????????11???!";
                    },
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      height: 30,
                      width: 20,
                      child: OutlinedButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.fromLTRB(0, 2, 0, 2))),
                          onPressed: () {
                            if (_phone.toString().length == 11) {
                              print("??????11??????,??????????????????http");
                              setState(() {
                                sendCodeStatus();
                              });
                            }
                          },
                          child: Text(!sendCodeButtonStatus ? "???????????????" : "?????????")),
                    )),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "?????????",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    // autovalidateMode: AutovalidateMode.onUserInteraction,

                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onChanged: (value) => _verifyCode = int.parse(value),
                    onSaved: (value) {
                      if (value != null) {
                        _verifyCode = int.parse(value);
                      }
                    },
                    // focusNode: FocusNode(),
                    validator: (String? value) {
                      return value!.trim().isNotEmpty &&
                              value.trim().length == 4 &&
                              int.tryParse(value) != null
                          ? null
                          : "????????????4???!";
                    },
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      height: 30,
                      width: 20,
                      child: ElevatedButton(
                          onPressed: () {
                            if (_verifyCode.toString().length == 4) {
                              print("???????????????4??????,????????????http??????");
                              setState(() {
                                codeLogin();
                              });
                            }
                          },
                          child: const Text("??????")),
                    )),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "Token",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: _tokenTextEditingController,
                    obscureText: true,
                    // readOnly:true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      _token = value!;
                    },
                    validator: (String? value) {
                      return value != null && value.isNotEmpty ? null : "????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: _match_car_typeTextEditingController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      _match_car_type = value!;
                    },
                    validator: (String? value) {
                      return value != null && value.isNotEmpty ? null : "????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: _screen_car_typeTextEditingController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      if (value != null) {
                        _screen_car_type = value;
                      }
                    },
                    // validator: (String? value) {
                    //   return value != null ? null : "????????????";
                    // },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "???????????????",
                      style: TextStyle(fontSize: 12),
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: _target_addressTextEditingController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      _target_address = value!;
                    },
                    validator: (String? value) {
                      return value != null ? null : "????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "???????????????",
                      style: TextStyle(fontSize: 12),
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: _screen_addressTextEditingController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      _screen_address = value!;
                    },
                    validator: (String? value) {
                      return value != null ? null : "????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: _min_distanceTextEditingController,
                    // initialValue: _min_distance.toString(),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      if (value != null) {
                        _min_distance = int.parse(value);
                      }
                    },
                    validator: (String? value) {
                      return value != null &&
                              value.isNotEmpty &&
                              int.tryParse(value) != null
                          ? null
                          : "????????????????????????";
                    },
                  ),
                ),
                const Expanded(
                    flex: 1,
                    child: Text(
                      "--",
                      textAlign: TextAlign.center,
                    )),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: _max_distanceTextEditingController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      if (value != null) {
                        _max_distance = int.parse(value);
                      }
                    },
                    validator: (String? value) {
                      return value != null &&
                              value.isNotEmpty &&
                              int.tryParse(value) != null
                          ? null
                          : "???????????????????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: _min_priceTextEditingController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      if (value != null) {
                        _min_price = int.parse(value);
                      }
                    },
                    validator: (String? value) {
                      return value != null &&
                              value.isNotEmpty &&
                              int.tryParse(value) != null
                          ? null
                          : "???????????????????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                    )),
                Expanded(
                    flex: 8,
                    child:
                        // TextFormField(
                        //   textAlign: TextAlign.center,
                        //   decoration: const InputDecoration(
                        //     enabledBorder: InputBorder.none,
                        //     focusedBorder: InputBorder.none,
                        //     errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                        //   ),
                        //   onSaved: (value) {
                        //     _times = value;
                        //   },
                        //   validator: (String? value) {
                        //     return value != null ? null : "????????????";
                        //   },
                        // ),
                        Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              child: Text(
                                deliver_times[0],
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                setState(() {
                                  deliver_bool[0] = !deliver_bool[0];
                                  print(deliver_bool);
                                });
                              },
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(1)),
                                  backgroundColor: deliver_bool[0]
                                      ? MaterialStateProperty.all(
                                          const Color.fromARGB(
                                              255, 130, 126, 126))
                                      : MaterialStateProperty.all(Colors.white),
                                  foregroundColor: deliver_bool[0]
                                      ? MaterialStateProperty.all(Colors.white)
                                      : MaterialStateProperty.all(Colors.black),
                                  animationDuration:
                                      const Duration(milliseconds: 1)),
                            )),
                        Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              child: Text(
                                deliver_times[1],
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                setState(() {
                                  deliver_bool[1] = !deliver_bool[1];
                                  print(deliver_bool);
                                });
                              },
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(1)),
                                  backgroundColor: deliver_bool[1]
                                      ? MaterialStateProperty.all(
                                          const Color.fromARGB(
                                              255, 130, 126, 126))
                                      : MaterialStateProperty.all(Colors.white),
                                  foregroundColor: deliver_bool[1]
                                      ? MaterialStateProperty.all(Colors.white)
                                      : MaterialStateProperty.all(Colors.black),
                                  animationDuration:
                                      const Duration(milliseconds: 1)),
                            )),
                        Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              child: Text(
                                deliver_times[2],
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                setState(() {
                                  deliver_bool[2] = !deliver_bool[2];
                                  print(deliver_bool);
                                });
                              },
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(1)),
                                  backgroundColor: deliver_bool[2]
                                      ? MaterialStateProperty.all(
                                          const Color.fromARGB(
                                              255, 130, 126, 126))
                                      : MaterialStateProperty.all(Colors.white),
                                  foregroundColor: deliver_bool[2]
                                      ? MaterialStateProperty.all(Colors.white)
                                      : MaterialStateProperty.all(Colors.black),
                                  animationDuration:
                                      const Duration(milliseconds: 1)),
                            )),
                        Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              child: Text(
                                deliver_times[3],
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                setState(() {
                                  deliver_bool[3] = !deliver_bool[3];
                                  print(deliver_bool);
                                });
                              },
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(1)),
                                  backgroundColor: deliver_bool[3]
                                      ? MaterialStateProperty.all(
                                          const Color.fromARGB(
                                              255, 130, 126, 126))
                                      : MaterialStateProperty.all(Colors.white),
                                  foregroundColor: deliver_bool[3]
                                      ? MaterialStateProperty.all(Colors.white)
                                      : MaterialStateProperty.all(Colors.black),
                                  animationDuration:
                                      const Duration(milliseconds: 1)),
                            )),
                      ],
                    )),
              ],
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                    flex: 2,
                    child: Text(
                      "????????????",
                      style: TextStyle(color: Colors.red),
                    )),
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    initialValue: _time_interval.toString(),
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle: TextStyle(fontSize: 7, letterSpacing: 1),
                    ),
                    onSaved: (value) {
                      if (value != null) {
                        _time_interval = int.parse(value);
                      }
                    },
                    validator: (String? value) {
                      return value != null &&
                              value.isNotEmpty &&
                              int.tryParse(value) != null
                          ? null
                          : "???????????????????????????";
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 30,
            margin: const EdgeInsets.fromLTRB(50, 30, 50, 0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.2),
                borderRadius: BorderRadius.circular(15)),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    runStatus ? Colors.red : Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () {
                setState(() {
                  startRun();
                });
              },
              child: Text(runStatus ? "????????????  $loopNumber" : "????????????"),
            ),
          ),
        ]));
  }

  void sendCodeStatus() {
    if (!sendCodeButtonStatus) {
      sendCodeButtonStatus = true;
      sendCode();
      Timer.periodic(const Duration(seconds: 5), (timer) {
        timer.cancel();
        setState(() {
          sendCodeButtonStatus = false;
          print("sendCodeButtonStatus???????????????????????????????????????????????????");
        });
      });
      //TODO
    } else {
      return;
    }
  }

  void startRun() {
    if (!runStatus && wschannel == null) {
      if (_form2Key.currentState != null) {
        if (_form2Key.currentState!.validate()) {
          _form2Key.currentState!.save();

          print(
              "${_phone}----${_token}----${_match_car_type}----${_screen_car_type}----${_target_address}----${_screen_address}----${_min_distance}---------${_min_price}----${_time_interval}----");

          // print(deliver_bool);
          List new_list = [];

          print("form2?????????-------------");

          for (var i = 0; i < deliver_bool.length; i++) {
            if (deliver_bool[i]) {
              new_list.add(deliver_times[i]);
            }
          }
          print("form2?????????---------------");
          print(new_list);

          print(deliver_times);
          if (!globalRunStatus) {
            runStatus = true;
            globalRunStatus = true;
            wschannel = IOWebSocketChannel.connect(MyConfig.wsUri);

            wschannel?.sink.add(json.encode({
              "msg": "first_info",
              "phone": _phone,
              "token": _token,
              "match_car_type": _match_car_type,
              "screen_car_type": _screen_car_type,
              "target_address": _target_address,
              "screen_address": _screen_address,
              "min_distance": _min_distance,
              "max_distance": _max_distance,
              "delivery_time": new_list,
              "min_price": _min_price,
              "time_interval": _time_interval,
            }));

            wschannel?.stream.listen((message) {
              var msg_map = json.decode(message);
              if (msg_map["msg"] == "number") {
                setState(() {
                  loopNumber++;
                });
              } else if (msg_map["msg"] == "????????????,?????????????????????") {
                Fluttertoast.showToast(
                    msg: "????????????",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    webShowClose: true,
                    fontSize: 16.0);
              } else {
                bus.fire(WebsocketMSG(
                    level: msg_map["level"],
                    msg: msg_map["msg"],
                    time: msg_map["time"]));
              }
            });
            print("ws????????????!!");
          } else {
            print("???????????????????????????");
            // Fluttertoast.showToast(
            //     msg: "?????????????????????...",
            //     toastLength: Toast.LENGTH_SHORT,
            //     gravity: ToastGravity.CENTER,
            //     timeInSecForIosWeb: 2,
            //     backgroundColor: Colors.red,
            //     textColor: Colors.white,
            //     fontSize: 16.0);

            Map onMatchOrder = MyConfig.onMatchOrder;
            playAudio();
            sucessfulOrders.insert(0, jsonEncode(onMatchOrder));
            spSet("sucessfulOrders", sucessfulOrders);
            BrnDialogManager.showConfirmDialog(context,
                showIcon: true,
                // iconWidget: Image(image: Image.),
                title: "????????????",
                cancel: '??????',
                confirm: '????????????',
                message:
                    "???????????????${onMatchOrder['vehicle_description']}\n????????????${onMatchOrder['from_location']['city']['name']}${onMatchOrder['from_location']['county']['name']}${onMatchOrder['from_location']['town']['name']}${onMatchOrder['from_location']['address']}\n????????????${onMatchOrder['to_location']['city']['name']}${onMatchOrder['to_location']['county']['name']}${onMatchOrder['to_location']['town']['name']}${onMatchOrder['to_location']['address']}\n?????????${onMatchOrder['price']['price']}\n?????????${onMatchOrder['time']}",
                barrierDismissible: false, onConfirm: () {
              stopAudio();
              homeGet.Get.toNamed("/order/detail",
                  arguments: {"title": "????????????????????????"});
            }, onCancel: () {
              stopAudio();
              Navigator.of(context).pop();
            });
          }
        }
      }
    } else {
      loopNumber = 0;
      runStatus = false;
      globalRunStatus = false;
      wschannel?.sink.close(wschannelstatus.goingAway);
      wschannel = null;
      print("from2-----------------11");
      print(wschannel);
    }
  }

  void sendCode() async {
    var dio = Dio();
    Response res =
        await dio.post(MyConfig.sendCodeUrl, data: {"mobile": _phone});
    print(res.toString());
    Map<String, dynamic> res_data = json.decode(res.toString());
    if (res_data["status"] == 10000) {
      print("????????????");
    } else {
      print("????????????");
    }
  }

  void codeLogin() async {
    var dio = Dio();

    Response res = await dio.post(MyConfig.codeLoginUrl,
        data: {"mobile": _phone, "code": _verifyCode});
    print(res.toString());
    Map<String, dynamic> res_data = json.decode(res.toString());
    if (res_data["status"] == 10000) {
      print("????????????");
      _tokenTextEditingController.text = _token = res_data["token"];
      print(_token);
    } else {
      print("????????????");
    }
  }

  void playAudio() async {
    print(
        "??????????????????---------------------------------------------------------------------------------------------");
    //player.audioCache.prefix = '';
    await player.setReleaseMode(ReleaseMode.loop);
    await player.play(AssetSource('files/aige.mp3'));
  }

  void stopAudio() async {
    print(
        "??????????????????---------------------------------------------------------------------------------------------");
    //player.audioCache.prefix = '';
    await player.stop();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
