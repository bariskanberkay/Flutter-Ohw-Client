import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/ohw_response.dart';
import '../notifier/ohw_notifier.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TreeController _treeController = TreeController(allNodesExpanded: false);

  OhwNotifier ohwNotifier = mainContext.watch();

  OhwResponse ohwResponse = OhwResponse();

  Widget content = SizedBox();

  late Timer timer;

  bool startStop = false;

  @override
  void initState() {
    super.initState();
  }

  void start() async {
    final prefs = await SharedPreferences.getInstance();

    int? getIntervalStorage = await prefs.getInt('ohw_monitor_interval');

    timer = Timer.periodic(Duration(seconds: getIntervalStorage ?? ohwNotifier.timeInterval), (Timer t) => buildTree());
    setState(() {
      startStop = true;
    });
  }

  void stop() {
    timer.cancel();

    setState(() {
      startStop = false;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void buildTree() async {
    final prefs = await SharedPreferences.getInstance();

    String? getBaseUrlStorage = prefs.getString('ohw_monitor_base_url');

    try {
      var response = await Dio().get(getBaseUrlStorage ?? ohwNotifier.baseUrl);

      ohwResponse = OhwResponse.fromJson(response.data);

      content = TreeView(
        nodes: toTreeNodes(ohwResponse),
        treeController: _treeController,
        indent: 10,
      );

      setState(() {});
    } on DioError catch (e) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Flexible(child: Text(e.message.toString())),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );

      timer.cancel();

      setState(() {
        startStop = false;
      });
    }
  }

  Widget getIcon(String imageData) {
    if (imageData == "images_icon/computer.png") {
      return Icon(Icons.computer);
    }
    if (imageData == "images_icon/mainboard.png") {
      return Icon(Icons.dashboard);
    }
    if (imageData == "images_icon/cpu.png") {
      return Icon(Icons.center_focus_weak_rounded);
    }
    if (imageData == "images_icon/ram.png") {
      return Icon(Icons.memory);
    }
    if (imageData == "images_icon/ati.png") {
      return Icon(Icons.graphic_eq);
    }
    if (imageData == "images_icon/hdd.png") {
      return Icon(Icons.sd_card);
    }
    if (imageData == "images_icon/transparent.png") {
      return Icon(Icons.signal_cellular_connected_no_internet_0_bar);
    }

    return SizedBox();
  }

  List<TreeNode> toTreeNodes(OhwResponse ohwResponse) {
    if ((ohwResponse.children?.length ?? 0) > 0) {
      return ohwResponse.children!.map((e) {
        return TreeNode(
            content: Expanded(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    color: (e.value ?? "") != "" ? Colors.transparent : Colors.grey.shade600,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        if ((e.text ?? "") != "")
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if ((e.imageUrl ?? "") != "")
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: getIcon(e.imageUrl ?? ""),
                                ),
                              Expanded(
                                  child: Text(
                                    e.text ?? "",
                                    style: (e.value ?? "") != "" ? Theme.of(context).textTheme.titleMedium : Theme.of(context).textTheme.titleSmall,
                                    textAlign: TextAlign.center,
                                  )),
                            ],
                          ),
                        if ((e.value ?? "") != "")
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text("Current : "),
                              Text(e.value ?? ""),
                            ],
                          ),
                        if ((e.min ?? "") != "")
                          Row(
                            children: [
                              Text("Minimum : "),
                              Text(e.min ?? ""),
                            ],
                          ),
                        if ((e.max ?? "") != "")
                          Row(
                            children: [
                              Text("Maximum : "),
                              Text(e.max ?? ""),
                            ],
                          ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            children: toTreeNodes(e));
      }).toList();
    } else {
      return ohwResponse.children!.map((e) {
        return TreeNode();
      }).toList();
    }
  }

  Future<void> _displaySettingsPopup(BuildContext buildContext) async {
    final prefs = await SharedPreferences.getInstance();

    String baseUrlCurrent = ohwNotifier.baseUrl;
    String? getBaseUrlStorage = await prefs.getString('ohw_monitor_base_url');

    int intervalCurrent = ohwNotifier.timeInterval;
    int? getIntervalStorage = await prefs.getInt('ohw_monitor_interval');

    return showDialog(
        context: buildContext,
        builder: (context) {
          OhwNotifier ohwNotifier = context.watch();

          return AlertDialog(
            title: Text('Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: getBaseUrlStorage ?? ohwNotifier.baseUrl),
                  onChanged: (value) {
                    setState(() {
                      baseUrlCurrent = value;
                    });
                  },
                  decoration: InputDecoration(hintText: "Base Url"),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: (getIntervalStorage ?? ohwNotifier.timeInterval).toString()),
                  onChanged: (value) {
                    setState(() {
                      intervalCurrent = int.parse(value);
                    });
                  },
                  decoration: InputDecoration(hintText: "Time Interval (Second)"),
                )
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  ohwNotifier.baseUrl = baseUrlCurrent;
                  ohwNotifier.timeInterval = intervalCurrent;
                  await prefs.setString('ohw_monitor_base_url', baseUrlCurrent);
                  await prefs.setInt('ohw_monitor_interval', intervalCurrent);
                  Navigator.pop(context);
                },
                child: Text("Save"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OHW Client"),
        actions: [
          IconButton(
              onPressed: () {
                if (startStop) {
                  stop();
                } else {
                  start();
                }
              },
              icon: Icon(startStop ? Icons.stop : Icons.play_arrow)),
          IconButton(
              onPressed: () {
                _displaySettingsPopup(context);
              },
              icon: Icon(Icons.settings)),
        ],
      ),
      body: startStop
          ? SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: content,
                ),
              ],
            ),
          ],
        ),
      )
          : Center(
        child: Text("App Stopped"),
      ),
    );
  }
}
