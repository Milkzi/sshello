import 'package:flutter/material.dart';

import 'package:sshello/pages/route/routes.dart';
import 'package:get/get.dart';
import './tabs/home.dart';
import 'tabs/log.dart';
import './tabs/person.dart';
import 'package:sshello/utils/eventBus.dart';

class MyAPP extends StatefulWidget {
  const MyAPP({super.key});

  @override
  State<MyAPP> createState() => _MyAPPState();
}

class _MyAPPState extends State<MyAPP> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: "/",
      getPages: MyRoute.routes,
    );
  }
}

// ----------------------------------------------------------------------
class MyScaffold extends StatefulWidget {
  const MyScaffold({super.key});

  @override
  State<MyScaffold> createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  //生命周期函数:当组件初始化的时候就会触发
  int _currentIndex = 0;
  // GlobalKey _listLogPageGlobalKey = GlobalKey();
  List<Widget> _tagPages = [];
  // late PageController _pageController;
  @override
  void initState() {
    // TODO: implement initState
    _tagPages = [const HomePage(), const ListLogPage(), const PersonPage()];
    // _tagPages = [const HomePage(), const ListLogPage()];

    super.initState();
    // _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: const Icon(Icons.menu_book),
        backgroundColor: Colors.blueGrey,
        title: const Text("Hello"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz))
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(
                    flex: 1,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                              "https://www.itying.com/images/flutter/3.png"),
                        ),
                      ),
                      child: Text("头部"),
                    ))
              ],
            ),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.menu),
              ),
              title: ElevatedButton(
                  onPressed: () {
                    bus.fire(ClearLogMSG(msg: "ClearLog"));
                  },
                  child: const Text("清除日志")),
            ),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.menu),
              ),
              title: ElevatedButton(
                  onPressed: () {}, child: const Text("清除已屏蔽订单")),
            ),
          ],
        ),
      ),
      body:
          // PageView(
          //   controller: _pageController,
          //   children: _tagPages,
          //   onPageChanged: (index) => _currentIndex = index,
          // ),
          IndexedStack(
        index: _currentIndex,
        children: _tagPages,
      ), //_tagPages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            print(index);
             _currentIndex = index;

            // _pageController.jumpToPage(_currentIndex);
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "日志"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "个人"),
        ],
      ),
    );
  }
}
