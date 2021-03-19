import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sight/ip_address.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  String myPath;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    final path = await IPAddress.getPath();
    if (!mounted) {
      return;
    }
    setState(() {
      myPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(myPath);
    if (myPath != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/vui', (Route<dynamic> route) => false,
            arguments: myPath);
      });
    }
    return Scaffold(
      backgroundColor: Colors.red,
    );
  }
}
