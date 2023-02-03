import 'package:flutter/material.dart';
import 'package:flutter_kyc_demo/routes/router_list.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    navigatorObservers: [routeObserver],
    routes: Routes.getAll(),
  ));
}
