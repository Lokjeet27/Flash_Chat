import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String id = "loginScreen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  bool spinSpinner = false;
  final _auth = auth.FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: spinSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
                decoration:
                    kTextFieldInputDecoration.copyWith(hintText: 'email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  //Do something with the user input.
                  password = value;
                },
                decoration:
                    kTextFieldInputDecoration.copyWith(hintText: 'password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                  title: 'login',
                  colour: Colors.lightBlueAccent,
                  onPressed: () async {
                    setState(() {
                      spinSpinner = true;
                    });
                    try {
                      final exitingUser =
                          await _auth.signInWithEmailAndPassword(
                              email: email, password: password);
                      if (exitingUser != null) {
                        print(email);
                        Navigator.pushNamed(context, ChatScreen.id);
                      }
                      setState(() {
                        spinSpinner = false;
                      });
                    } catch (e) {
                      print(e);
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
