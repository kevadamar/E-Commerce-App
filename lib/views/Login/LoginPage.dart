import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:globalshop/MenuUser.dart';
import 'package:globalshop/models/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginPageState extends State<LoginPage> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  var username, password;
  final _key = new GlobalKey<FormState>();
  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  var _autoValidate = false;

  check() {
    // final form = _key.currentState;
    
    login();
    // if (form.validate()) {
    // } else {
    //   _autoValidate = true;
    // }
  }

  login() async {
    try {
      print("nulls");
      print(username);
      print(password);
      final response = await http.post(BaseURL.apiLogin,
          body: {"username": username, "password": password});
      final data = jsonDecode(response.body);
      int code = data['code'];
      String pesan = data['message'];

      // from api
      String usernameApi, namaApi;
      int useridApi, userLevel;

      data['data'].forEach((api) {
        usernameApi = api['username'];
        namaApi = api['nama'];
        useridApi = api['userid'];
        userLevel = api['level'];
      });

      if (code == 200) {
        setState(() {
          _loginStatus = LoginStatus.signIn;
          savePref(code, usernameApi, namaApi, useridApi, userLevel);
        });
        print(pesan);
      } else {
        print(pesan);
      }
    } catch (e) {
      print("error : ");
      print(e);
    }
  }

  savePref(int code, String usernameApi, String namaApi, int useridApi,
      int userLevel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("code", code);
      preferences.setString("username", usernameApi);
      preferences.setString("nama", namaApi);
      preferences.setInt("userid", useridApi);
      preferences.setInt("level", userLevel);
      preferences.commit();
    });
  }

  var code, level;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      code = preferences.getInt("code");
      level = preferences.getInt("level");

      if (code == 200) {
        _loginStatus = LoginStatus.signIn;
      } else {
        _loginStatus = LoginStatus.notSignIn;
      }
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      code = preferences.setInt("code", null);
      level = preferences.setInt("level", null);
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          body: Form(
            key: _key,
            autovalidate: _autoValidate,
            child: ListView(
              padding: EdgeInsets.only(top: 90.0, left: 20.0, right: 20.0),
              children: <Widget>[
                Image.asset("assets/img/logo.jpg", height: 60, width: 60),
                Text(
                  "GlobalShop V0.1",
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.2,
                ),
                TextFormField(
                  validator: (e) {
                    if (e.isEmpty) {
                      return "Username Harus Diisi";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (e) => username = e,
                  decoration: InputDecoration(labelText: "Username"),
                ),
                TextFormField(
                  obscureText: _secureText,
                  validator: (e) {
                    if (e.isEmpty) {
                      return "Password Harus Diisi";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (e) => password = e,
                  decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(_secureText
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          showHide();
                        },
                      )),
                ),
                SizedBox(
                  height: 20.0,
                ),
                MaterialButton(
                  padding: EdgeInsets.all(25.0),
                  color: Colors.deepOrange,
                  onPressed: () {
                    if (_key.currentState.validate()) {
                      _key.currentState.save();
                      check();
                    } else {
                      _autoValidate = true;
                    }
                  },
                  child: Text("Login",style: TextStyle(color: Colors.white),),
                )
              ],
            ),
          ),
        );
        break;
      case LoginStatus.signIn:
        return MenuUser(signOut);
        break;
    }
  }
}
