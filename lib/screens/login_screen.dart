import 'package:flutter/material.dart';
import 'package:flutterauth/provider/internet_provider.dart';
import 'package:flutterauth/provider/sign_in_provider.dart';
import 'package:flutterauth/screens/home_screen.dart';
import 'package:flutterauth/screens/phoneauth_screen.dart';
import 'package:flutterauth/utils/next_screen.dart';
import 'package:flutterauth/utils/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../utils/config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController phoneController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 40, right: 40, top: 90, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image(
                      image: AssetImage(Config.app_icon),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Flutter Firebase Authentication",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Learn Authentication With Provider",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundedLoadingButton(
                    controller: googleController,
                    successColor: Colors.red,
                    width: MediaQuery.of(context).size.width * 0.80,
                    elevation: 0,
                    borderRadius: 25,
                    onPressed: () {
                      handleGoogleSignIn();
                    },
                    color: Colors.red,
                    child: Wrap(
                      children: const [
                        Icon(
                          FontAwesomeIcons.google,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 15),
                        Text(
                          "Sign in with Google",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  RoundedLoadingButton(
                    controller: facebookController,
                    successColor: Colors.blue,
                    width: MediaQuery.of(context).size.width * 0.80,
                    elevation: 0,
                    borderRadius: 25,
                    onPressed: () {
                      handleFacebookAuth();
                    },
                    color: Colors.blue,
                    child: Wrap(
                      children: const [
                        Icon(
                          FontAwesomeIcons.facebook,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 15),
                        Text(
                          "Sign in with Facebook",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  RoundedLoadingButton(
                    controller: phoneController,
                    successColor: Colors.black,
                    width: MediaQuery.of(context).size.width * 0.80,
                    elevation: 0,
                    borderRadius: 25,
                    onPressed: () {
                      nextScreenReplace(context, const PhoneAuthScreen());
                      phoneController.reset();
                    },
                    color: Colors.black,
                    child: Wrap(
                      children: const [
                        Icon(
                          FontAwesomeIcons.phone,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 15),
                        Text(
                          "Sign in with Phone Number",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackBar(context, "Check your Internet connection", Colors.red);
      googleController.reset();
    } else {
      await sp.signInWithGoogle().then((value) {
        if (sp.hasError == true) {
          openSnackBar(context, sp.errorCode.toString(), Colors.red);
          googleController.reset();
        } else {
          //check user exists or not
          sp.checkUserExists().then(
            (value) async {
              if (value == true) {
                await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                    .saveDataToSharedPreferences()
                    .then((value) => sp.setSignIn().then((value) {
                          googleController.success();
                          handleAfterSignIn();
                        })));
              } else {
                sp.saveDataToFireStore().then(
                      (value) => sp.saveDataToSharedPreferences().then(
                            (value) => sp.setSignIn().then(
                              (value) {
                                googleController.success();
                                handleAfterSignIn();
                              },
                            ),
                          ),
                    );
              }
            },
          );
        }
      });
    }
  }

  Future handleFacebookAuth() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackBar(context, "Check your Internet connection", Colors.red);
      facebookController.reset();
    } else {
      await sp.signInWithFacebook().then((value) {
        if (sp.hasError == true) {
          openSnackBar(context, sp.errorCode.toString(), Colors.red);
          facebookController.reset();
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                facebookController.success();
                handleAfterSignIn();
              })));
            } else {
              // user does not exist
              sp.saveDataToFireStore().then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                facebookController.success();
                handleAfterSignIn();
              })));
            }
          });
        }
      });
    }
  }

  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, const HomeScreen());
    });
  }
}
