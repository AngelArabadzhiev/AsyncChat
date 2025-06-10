import 'dart:convert';
import 'package:asyncchat/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

const List<Widget> options = <Widget>[Text('Login'), Text('Sign up')];

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController controllerUsername = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<bool> _selectedOptions = <bool>[true, false];
  bool vertical = false;


  String? userToken;


  Future<void> registerUser(BuildContext context, String username, String password) async {
    final response = await http.post(
      Uri.parse('http://37.63.57.37:3000/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${response.body}')),
      );
    }
  }


  Future<void> loginUser(BuildContext context, String username, String password) async {
    final response = await http.post(
      Uri.parse('http://37.63.57.37:3000/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userToken = data['token'];
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  ChatPage(username: username, password: password,)),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Prevent overflow when keyboard appears
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, top: 60),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    _selectedOptions[0] ? "Login" : "Sign up",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, top: 5),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    _selectedOptions[0]
                        ? "Welcome back, login to continue"
                        : "Hello, create your account here",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 50),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: ToggleButtons(
                    direction: vertical ? Axis.vertical : Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < _selectedOptions.length; i++) {
                          _selectedOptions[i] = i == index;
                        }
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    selectedBorderColor: Colors.transparent,
                    selectedColor: Colors.black,
                    fillColor: Colors.white,
                    color: Colors.black,
                    borderColor: Colors.transparent,
                    constraints: BoxConstraints(
                      minHeight: 40.0,
                      minWidth: (MediaQuery.of(context).size.width * 0.86) / 2,
                    ),
                    isSelected: _selectedOptions,
                    children: options,
                  ),
                ),
              ),
              SizedBox(height: 80),
              Form(
                key: _formKey,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Username',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: controllerUsername,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field cannot be empty';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Username',
                        ),
                      ),
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: controllerPassword,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field cannot be empty';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Password',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 0.056,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedOptions[0]) {
                        loginUser(context, controllerUsername.text, controllerPassword.text);
                      } else {
                        registerUser(context, controllerUsername.text, controllerPassword.text);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text(
                    _selectedOptions[0] ? 'Login' : 'Sign up',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
