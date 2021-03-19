import 'package:flutter/material.dart';

import 'loading.dart';
import 'routes.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Loading(),
      initialRoute: '/loading',
    onGenerateRoute: Routing.generateRoute,
    ));
