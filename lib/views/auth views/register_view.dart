import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialog/error_dialog.dart';



class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(title: const Text("Register")),
        body: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: true,
              autocorrect: true,
              keyboardType: TextInputType.emailAddress,
              decoration:
                  const InputDecoration(hintText: "Please Enter Your Email"),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
              decoration:
                  const InputDecoration(hintText: "Please Enter Your Password"),
            ),
            TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {

                    await AuthService.firebase().createUser(email: email, password: password);
                    
                    await AuthService.firebase().sendEmailVerification();
                    
                    await showErrorDialog(context, "Verify Your Email", "We have sent verification email.");

                    Navigator.pushNamed(context, emailVerifyRoute);   

                  } on WeakPasswordAuthException{
                    await showErrorDialog(context, "Weak Password", "The password provided is too weak.");
                  } on EmailAlreadyInUseAuthException{
                    await showErrorDialog(context, "Email Already in Use", "The account already exists for that email.");
                  } on InvalidEmailAuthException{
                    await showErrorDialog(context, "Invalid Email Address", "Please Enter Correct Email Address it's Invalid");
                  } on GenericAuthException{
                    await showErrorDialog(context, "Something Went Wrong", "Error: Failed to register.");
                  }
                  
                  //  on FirebaseAuthException catch (e) {
                  //   devtools.log(e.toString());
                  //   if (e.code == 'weak-password') {
                  //     devtools.log('The password provided is too weak.');
                  //     await showErrorDialog(context, "Weak Password", "The password provided is too weak.");
                  //   } else if (e.code == 'email-already-in-use') {
                  //     devtools.log('The account already exists for that email.');
                  //     await showErrorDialog(context, "Email Already in Use", "The account already exists for that email.");
                  //   } else if (e.code == "invalid-email") {
                  //     devtools.log("Invalid Email Address");
                  //     await showErrorDialog(context, "Invalid Email Address", "Please Enter Correct Email Address it's Invalid");
                  //   } else{
                  //     devtools.log(e.toString());
                  //     await showErrorDialog(context, "Something Went Wrong", "Error ${e.toString()}");
                  //   }
                  // } catch (e) {
                  //   devtools.log(e.toString());
                  //   await showErrorDialog(context, "Something Went Wrong", "Error ${e.toString()}");
                  // }
                },
                child: const Text("Sign Up")),
            // TextButton(
            //     onPressed: () {
            //       Navigator.pushNamedAndRemoveUntil(context, "/login/", (route) => false);                 
            //     },
            //     child: const Text("Login Again")),
          ],
        ),
      ),
    );
  }
}
