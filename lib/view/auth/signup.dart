import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/textfield.dart';
import 'package:translator_app/view/auth/login.dart';
import 'package:translator_app/viewmodel/auth_viewmodel.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController usernamecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    // MediaQuery for responsive design
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    // Calculate responsive sizes
    final buttonWidth = screenWidth * 0.8;
    final buttonHeight = screenHeight * 0.06;
    final textSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      '''Register
          to New Account''',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  CustomTextField(
                    label: 'UserName',
                    hintText: 'Enter your username',
                    controller: usernamecontroller,
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Email TextField
                  CustomTextField(
                    label: 'Email',
                    hintText: 'Enter your email address',
                    controller: emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Password TextField
                  CustomTextField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: passwordcontroller,
                    obscureText: !authVm.isSignupPasswordVisible,
                    prefixIcon: Icons.lock,
                    suffixIcon: authVm.isSignupPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    onSuffixTap: () {
                      authVm.toggleSignupPasswordVisibility();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: screenHeight * 0.002),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                        );
                      },
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          fontSize: textSize,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: authVm.isLoading
                        ? null
                        : () async {
                            final success = await authVm.signup(
                              username: usernamecontroller.text,
                              email: emailcontroller.text,
                              password: passwordcontroller.text,
                            );

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.error,
                                  content: Text(
                                    authVm.errorMessage ??
                                        'Please enter Username, email and password ',
                                  ),
                                ),
                              );
                            }
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                      ),
                      child: authVm.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.textWhite,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "SignUp",
                              style: TextStyle(
                                fontSize: textSize * 1.2,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textWhite,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    usernamecontroller.dispose();
    super.dispose();
  }
}
