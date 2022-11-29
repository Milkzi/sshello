import 'dart:convert';
import 'dart:math';

import "2.dart";
import "3.dart";

void main() {
  // print(DateTime.now().toString().substring(11, 23));
  // print(1.toString());
  // print(b2 == b3);
  var mylist = [1, 2, 3];
//   mylist.add(4);
//   print(mylist);
//   mylist.insert(0, 0);
//   print(mylist);
  // print(mylist.asMap().entries);
  // for (var element in mylist) {
  //   print(element);
  // }

  List<String> deliver_times = ['即时用车', '预约今天', '预约明天', '预约后天'];
  List<bool> deliver_bool = [true, true, true, false];

  var new_list = json.decode(json.encode(deliver_times));
  print(new_list);
  deliver_bool.asMap().forEach((key, value) {
    if (!value) {
      new_list.removeAt(key);
    }
  });

  print(deliver_times);
  print(new_list);
}
