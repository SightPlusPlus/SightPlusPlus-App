import 'package:flutter/material.dart';

import 'loading.dart';
import 'routes.dart';

/*The software is an early proof of
concept for development purposes
and should not be used as-is in a
live environment without further
redevelopment and/or testing. No
warranty is given and no real data or
personally identifiable data should be
stored. Usage and its liabilities are your
own.*/

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Loading(),
      initialRoute: '/loading',
    onGenerateRoute: Routing.generateRoute,
    ));
