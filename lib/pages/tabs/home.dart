import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'package:sshello/setting.dart';
import 'package:sshello/utils/eventBus.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as wschannelstatus;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _nameState();
}

final _formKey = GlobalKey<FormState>();
final _form2Key = GlobalKey<FormState>();
bool runStatus = false;
IOWebSocketChannel? wschannel;

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
                controller: _tabController, //注意：配置controller需要去掉TabBar上面的const
                tabs: const [
                  Tab(
                    child: Text("拉取登录"),
                  ),
                  Tab(
                    child: Text("验证码登录"),
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

// form 表单
class FormPage extends StatefulWidget {
  const FormPage({
    super.key,
  });

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController _tokenTextEditingController =
      TextEditingController(); //Token
  final TextEditingController _match_car_typeTextEditingController =
      TextEditingController(); //匹配车型
  final TextEditingController _screen_car_typeTextEditingController =
      TextEditingController(); //屏蔽车型
  final TextEditingController _target_addressTextEditingController =
      TextEditingController(); //指定目的地
  final TextEditingController _screen_addressTextEditingController =
      TextEditingController(); //屏蔽目的地
  final TextEditingController _min_distanceTextEditingController =
      TextEditingController(); //最小路程
  final TextEditingController _max_distanceTextEditingController =
      TextEditingController(); //最大路程
  final TextEditingController _min_priceTextEditingController =
      TextEditingController(); //最低价格

  String _phone = ""; //手机号码
  String _token = ""; //TokenR
  String _match_car_type = ""; //匹配车型
  String _screen_car_type = ""; //屏蔽车型
  String _target_address = ""; //指定目的地
  String _screen_address = ""; //屏蔽目的地
  int _min_distance = 0; //最小路程
  int _max_distance = 1000; //最大路程
  int _min_price = 0; //最低价格
  int _time_interval = 1000; //时间间隔
  List<String> deliver_times = ['即时用车', '预约今天', '预约明天', '预约后天'];
  List<bool> deliver_bool = [true, true, true, true];

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
    print("FormPage----build");
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
                      "手机号码",
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
                          : "长度应为11位!";
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
                              print("长度11正常,开始拉取执行http");
                              pullPhoneInfo();
                            }
                          },
                          child: const Text("拉取")),
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
                      return value != null && value.isNotEmpty ? null : "不能为空";
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
                      "匹配车型",
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
                      return value != null && value.isNotEmpty ? null : "不能为空";
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
                      "屏蔽车型",
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
                    //   return value != null ? null : "不能为空";
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
                      "指定目的地",
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
                      return value != null ? null : "不能为空";
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
                      "屏蔽目的地",
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
                      return value != null ? null : "不能为空";
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
                      "送货距离",
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
                      return value != null && value.isNotEmpty ? null : "不能为空";
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
                      return value != null && value.isNotEmpty ? null : "不能为空";
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
                      "最低价格",
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
                      return value != null && value.isNotEmpty ? null : "不能为空";
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
                      "送货时间",
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
                        //     return value != null ? null : "不能为空";
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
                      "抢单间隔",
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
                      return value != null && value.isNotEmpty ? null : "不能为空";
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
              child: Text(runStatus ? "终止程序" : "开始运行"),
            ),
          ),
        ]));
  }

  void startRun() {
    if (!runStatus && wschannel == null) {
      if (_formKey.currentState != null) {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          runStatus = true;

          print(
              "${_phone}----${_token}----${_match_car_type}----${_screen_car_type}----${_target_address}----${_screen_address}----${_min_distance}---------${_min_price}----${_time_interval}----");
          print("开始运行！！！！");
          // print(deliver_bool);
          List new_list = [];

          print("添加前-------------");

          for (var i = 0; i < deliver_bool.length; i++) {
            if (deliver_bool[i]) {
              new_list.add(deliver_times[i]);
            }
          }
          print("添加后---------------");
          // print(new_list);

          // print(deliver_times);
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
            bus.fire(
                WebsocketMSG(level: msg_map["level"], msg: msg_map["msg"]));
          });
          print("ws连接成功!!");
        }
      }
    } else {
      runStatus = false;
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
}

//form2表单
class FormPage2 extends StatefulWidget {
  const FormPage2({super.key});

  @override
  State<FormPage2> createState() => _FormPage2State();
}

class _FormPage2State extends State<FormPage2> {
  final TextEditingController _tokenTextEditingController =
      TextEditingController(); //Token
  final TextEditingController _match_car_typeTextEditingController =
      TextEditingController(); //匹配车型
  final TextEditingController _screen_car_typeTextEditingController =
      TextEditingController(); //屏蔽车型
  final TextEditingController _target_addressTextEditingController =
      TextEditingController(); //指定目的地
  final TextEditingController _screen_addressTextEditingController =
      TextEditingController(); //屏蔽目的地
  final TextEditingController _min_distanceTextEditingController =
      TextEditingController(); //最小路程
  final TextEditingController _max_distanceTextEditingController =
      TextEditingController(); //最大路程
  final TextEditingController _min_priceTextEditingController =
      TextEditingController(); //最低价格

  // IOWebSocketChannel? wschannel;

  // bool runStatus = false;
  String _phone = ""; //手机号码
  String _token = ""; //TokenR
  String _match_car_type = ""; //匹配车型
  String _screen_car_type = ""; //屏蔽车型
  String _target_address = ""; //指定目的地
  String _screen_address = ""; //屏蔽目的地
  int _min_distance = 0; //最小路程
  int _max_distance = 1000; //最大路程
  int _min_price = 0; //最低价格
  int _time_interval = 1000; //时间间隔
  List<String> deliver_times = ['即时用车', '预约今天', '预约明天', '预约后天'];
  List<bool> deliver_bool = [true, true, true, true];
  int _verifyCode = 0;

  // String runText = "开始运行";

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
    print("FormPage----build");
    return Form(
        key: _form2Key,
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
                      "手机号码",
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
                          : "长度应为11位!";
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
                              print("长度11正常,开始拉取执行http");
                              setState(() {
                                sendCode();
                              });
                            }
                          },
                          child: const Text("发送验证码")),
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
                      "验证码",
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
                      if (value != null) {
                        _verifyCode = int.parse(value);
                      }
                    },
                    // focusNode: FocusNode(),
                    validator: (String? value) {
                      return value!.trim().isNotEmpty &&
                              value.trim().length == 4
                          ? null
                          : "长度应为4位!";
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
                              print("验证码长度4正常,开始执行http登录");
                              setState(() {
                                codeLogin();
                              });
                            }
                          },
                          child: const Text("登录")),
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
                      return value != null && value.isNotEmpty ? null : "不能为空";
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
                      "匹配车型",
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
                      return value != null && value.isNotEmpty ? null : "不能为空";
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
                      "屏蔽车型",
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
                    //   return value != null ? null : "不能为空";
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
                      "指定目的地",
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
                      return value != null ? null : "不能为空";
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
                      "屏蔽目的地",
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
                      return value != null ? null : "不能为空";
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
                      "送货距离",
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
                      return value != null && value.isNotEmpty ? null : "不能为空";
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
                      return value != null && value.isNotEmpty ? null : "不能为空";
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
                      "最低价格",
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
                      return value != null && value.isNotEmpty ? null : "不能为空";
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
                      "送货时间",
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
                        //     return value != null ? null : "不能为空";
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
                      "抢单间隔",
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
                      return value != null && value.isNotEmpty ? null : "不能为空";
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
              child: Text(runStatus ? "终止程序" : "开始运行"),
            ),
          ),
        ]));
  }

  void startRun() {
    if (!runStatus && wschannel == null) {
      if (_form2Key.currentState != null) {
        if (_form2Key.currentState!.validate()) {
          _form2Key.currentState!.save();

          runStatus = true;
           print("form2开始运行！！！！");
          print("${_phone}----${_token}----${_match_car_type}----${_screen_car_type}----${_target_address}----${_screen_address}----${_min_distance}---------${_min_price}----${_time_interval}----");
          print("form2开始运行！！！！");
          // print(deliver_bool);
          List new_list = [];

          print("form2添加前-------------");

          for (var i = 0; i < deliver_bool.length; i++) {
            if (deliver_bool[i]) {
              new_list.add(deliver_times[i]);
            }
          }
          print("form2添加后---------------");
          // print(new_list);

          // print(deliver_times);
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
            bus.fire(
                WebsocketMSG(level: msg_map["level"], msg: msg_map["msg"]));
          });
          print("ws连接成功!!");
        }
      }
    } else {
      runStatus = false;

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
      print("发送成功");
    } else {
      print("发送失败");
    }
  }

  void codeLogin() async {
    var dio = Dio();

    Response res = await dio.post(MyConfig.codeLoginUrl,
        data: {"mobile": _phone, "code": _verifyCode});
    print(res.toString());
    Map<String, dynamic> res_data = json.decode(res.toString());
    if (res_data["status"] == 10000) {
      print("登录成功");
      _tokenTextEditingController.text = _token = res_data["token"];
    } else {
      print("登录失败");
    }
  }
}
