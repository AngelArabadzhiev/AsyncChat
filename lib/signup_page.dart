import 'package:asyncchat/utils/brand_colors.dart';
import 'package:asyncchat/utils/spaces.dart';
import 'package:asyncchat/widgets/login_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const List<Widget> options = <Widget>[Text('Login'), Text('Sign up')];

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<SignupPage> {
  final TextEditingController controllerUsername = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<bool> _selectedOptions = <bool>[true, false];
  bool vertical = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, top: 60),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Sign up",
                style: TextStyle(
                  color: BrandColors.headingColor,
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
                "Hello, create your account here",
                style: TextStyle(
                  color: BrandColors.inactiveColor,
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
          verticalSpacing(80),
          Form(
            key: _formKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email',
                      style: GoogleFonts.inter(
                        color: BrandColors.textColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  verticalSpacing(10),
                  LoginField(
                    icon: Icon(Icons.mail),
                    controller: controllerUsername,
                    type: "email@example.com",
                    obscureTextEnabled: false,
                  ),
                  verticalSpacing(15),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(color: BrandColors.textColor),
                    ),
                  ),
                  verticalSpacing(10),
                  LoginField(
                    icon: Icon(Icons.key),
                    secondIcon: Icon(Icons.remove_red_eye),
                    controller: controllerPassword,
                    type: "*********",
                    obscureTextEnabled: true,
                  ),
                  verticalSpacing(15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(color: BrandColors.textColor),
                    ),
                  ),
                  verticalSpacing(15),
                ],
              ),
            ),
          ),
          verticalSpacing(20),
          Container(
            height: MediaQuery.of(context).size.height * 0.056,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: ElevatedButton(
              onPressed: () {
                //await loginUser(context,controllerUsername,controllerPassword,_formKey,);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shadowColor: BrandColors.buttonColor,
                  foregroundColor: BrandColors.buttonColor
              ),
              child: Text(
                'Sign up',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}