import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/view/components/textfield.dart';
import 'package:translator_app/view/auth/login.dart';
import 'package:translator_app/view/homepage.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final horizontalPadding = screenWidth * 0.06;

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: screenHeight * 0.025,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    Text(
                      'Join to save history and sync across devices',
                      style: GoogleFonts.outfit(
                        fontSize: screenWidth * 0.035,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.035),

                    // Username TextField
                    CustomTextField(
                      label: 'Username',
                      hintText: 'Enter your name',
                      controller: usernamecontroller,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your username';
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
                      prefixIcon: Icons.email_outlined,
                      showClearButton: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Password TextField
                    CustomTextField(
                      label: 'Password',
                      hintText: 'Create a secure password',
                      controller: passwordcontroller,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
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

                    SizedBox(height: screenHeight * 0.012),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                          );
                        },
                        child: Text(
                          "Already have an account? Sign In",
                          style: GoogleFonts.outfit(
                            fontSize: screenWidth * 0.034,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.035),

                    // Sign up button
                    CustomButton(
                      text: 'Create Account',
                      variant: ButtonVariant.filled,
                      height: screenHeight * 0.062,
                      fontSize: screenWidth * 0.042,
                      isLoading: authVm.isLoading,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        final success = await authVm.signup(
                          username: usernamecontroller.text.trim(),
                          email: emailcontroller.text.trim(),
                          password: passwordcontroller.text,
                        );

                        if (!context.mounted) return;

                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Homepage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.error,
                              content: Text(
                                authVm.errorMessage ??
                                    'Please fill in all fields correctly',
                                style: GoogleFonts.outfit(color: Colors.white),
                              ),
                            ),
                          );
                        }
                      },
                    ),

                    SizedBox(height: screenHeight * 0.018),

                    // Continue as Guest Button
                    CustomButton(
                      text: 'Skip & Continue as Guest',
                      variant: ButtonVariant.outlined,
                      height: screenHeight * 0.062,
                      fontSize: screenWidth * 0.04,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Homepage(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
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
