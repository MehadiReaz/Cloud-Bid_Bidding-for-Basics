import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ecommerce_app/ui/auth/login_screen.dart';
import 'package:ecommerce_app/utils/utils.dart';

import '../../firebase_services/google_auth.dart';
import '../../widgets/round_button.dart';
import '../posts/homescreen/products.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void signUp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      _auth
          .createUserWithEmailAndPassword(
              email: emailController.text.toString(),
              password: passwordController.text.toString())
          .then((value) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ProductListScreen()));
        setState(() {
          isLoading = false;
        });
      }).onError((error, stackTrace) {
        setState(() {
          isLoading = false;
        });
        Utils().toastMessgae(error.toString());
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text('SignUp')),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'E-mail',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Email cannot be blank';
                        }
                        // else if (value.contains('@') ||
                        //     !value.contains('.com')) {
                        //   return 'Invalid Email';
                        //
                        return null;
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                      keyboardType: TextInputType.text,
                      controller: passwordController,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Password cannot be blank';
                        }
                        return null;
                      }),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            RoundButton(
                title: 'Signup',
                isLoading: isLoading,
                onTap: () {
                  signUp();
                }),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an Account?"),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    },
                    child: const Text('Login'))
              ],
            ),
            RoundButton(
                title: 'Signup with Google',
                onTap: () {
                  GoogleAuth().signinWithGoogle();
                })
          ],
        ),
      ),
    );
  }
}
