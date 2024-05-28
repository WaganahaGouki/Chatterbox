import 'package:chatterbox/auth/auth_service.dart';
import 'package:flutter/material.dart';
import '../../components/my_button.dart';
import '../../components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final void Function()? onTap;

  RegisterPage({super.key, this.onTap});

  void register(BuildContext context) {
    final _auth = AuthService();

    if(_passwordController.text == _confirmPasswordController.text) {
      try {
        _auth.signUp(_emailController.text, _passwordController.text);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    }
    else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords don't match!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 25),

            //welcome
            Text(
              "Welcome to Chatterbox!",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16
              ),
            ),

            const SizedBox(height: 50),

            //username
            MyTextfield(hintText: 'Username', obscureText: false, controller: _usernameController,),

            const SizedBox(height: 10),

            //email
            MyTextfield(hintText: 'Email', obscureText: false, controller: _emailController,),

            const SizedBox(height: 10),

            //password
            MyTextfield(hintText: 'Password', obscureText: true, controller: _passwordController,),

            const SizedBox(height: 10),

            //confirm password
            MyTextfield(hintText: 'Confirm password', obscureText: true, controller: _confirmPasswordController,),

            const SizedBox(height: 30),

            //login button
            MyButton(
              buttonText: "Register",
              onTap: () => register(context),
            ),

            const SizedBox(height: 10),

            //go to register button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Login here",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}