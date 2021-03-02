import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:text_composition/text_composition.dart';

import 'first_chapter.dart';


///
/// 调试时修改162行查看详细的布局输出和绘图方式
/// `tc.getPageWidget(tc.pages[index], true, true/false),`
///
main(List<String> args) {
  runApp(MaterialApp(home: Setting()));
}

class Setting extends StatefulWidget {
  Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  var size = TextEditingController(text: '16'),
      height = TextEditingController(text: '1.55'),
      paragraph = TextEditingController(text: '10'),
      shouldJustifyHeight = true,
      start = DateTime.now(),
      end = DateTime.now();
  TextComposition? tc;
  @override
  Widget build(BuildContext context) {
    final pwidth = window.physicalSize.width;
    final pheight = window.physicalSize.height;
    final ratio = window.devicePixelRatio;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(30),
        children: [
          Text("width / ratio: $pwidth / $ratio = ${pwidth / ratio}"),
          Text("height / ratio: $pheight / $ratio = ${pheight / ratio}"),
          OutlinedButton(
            child: Text("重新获取屏幕大小"),
            onPressed: () => setState(() {}),
          ),
          TextField(
            decoration: InputDecoration(labelText: "字号 size"),
            controller: size,
            keyboardType: TextInputType.number,
          ),
          TextField(
            decoration: InputDecoration(labelText: "行高 height"),
            controller: height,
            keyboardType: TextInputType.number,
          ),
          TextField(
            decoration: InputDecoration(labelText: "段高 paragraph"),
            controller: paragraph,
            keyboardType: TextInputType.number,
          ),
          SwitchListTile(
            title: Text("是否底栏对齐"),
            subtitle: Text("shouldJustifyHeight"),
            value: shouldJustifyHeight,
            onChanged: (bool value) => setState(() {
              shouldJustifyHeight = !shouldJustifyHeight;
            }),
          ),
          Text("排版开始 $start"),
          Text("排版结束 $end"),
          OutlinedButton(
            child: Text("开始或重新排版"),
            onPressed: () {
              start = DateTime.now();
              tc = TextComposition(
                paragraphs: first_chapter,
                style: TextStyle(
                  fontFamily: "jiali",
                  fontSize: double.tryParse(size.text),
                  height: double.tryParse(height.text),
                ),
                paragraph: int.tryParse(paragraph.text) ?? 10,
                boxWidth: pwidth / ratio - 20,
                boxHeight: pheight / ratio - 20,
                shouldJustifyHeight: shouldJustifyHeight,
                linkPattern: "<img",
                linkText: (s) =>
                    RegExp('src=".*/([^/]+)"').firstMatch(s)?.group(1) ?? "链接",
                linkStyle: TextStyle(
                    color: Colors.cyan, fontStyle: FontStyle.italic, fontFamily: "jiali"),
                onLinkTap: (s) => Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => Scaffold(
                          appBar: AppBar(),
                          body: Image.network(
                              s.substring(s.indexOf("src=\"") + 5, s.lastIndexOf("\""))),
                        ))),
              );
              end = DateTime.now();
              setState(() {});
            },
          ),
          OutlinedButton(
            child: Text("预览"),
            onPressed: () {
              if (tc == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('先排版才能预览'),
                ));
              } else {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (BuildContext context) => Page(tc: tc!)))
                    .then((value) =>
                        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values));
              }
            },
          ),
        ],
      ),
    );
  }
}

class Page extends StatelessWidget {
  final TextComposition tc;
  const Page({required this.tc, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final style = TextStyle(color: Colors.white);
    return Scaffold(
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tc.pageCount,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: tc.boxHeight + 20,
            color: Colors.deepPurple,
            width: tc.boxWidth + 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                    children: List.generate(
                  tc.boxHeight ~/ 10 + 2,
                  (index) => Container(
                    height: 10,
                    width: 20,
                    color: index % 2 == 0 ?null : Colors.cyan ,
                    child: Text(
                      index % 2 == 0 ? "" : ((index + 1) * 10).toString() ,
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.white, fontSize: 8),
                    ),
                  ),
                )),
                Column(
                  children: [
                    tc.getPageWidget(tc.pages[index], false, false),
                    Container(
                      height: 20,
                      width: tc.boxWidth,
                      color: Colors.teal,
                      child: Text("页数 ${index + 1} / ${tc.pageCount}", style: style),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
