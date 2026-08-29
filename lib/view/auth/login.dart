import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/apptheme/app_theme.dart';
import 'package:translator_app/view/components/custom_button.dart';
import 'package:translator_app/view/components/textfield.dart';
import 'package:translator_app/view/auth/signup.dart';
import 'package:translator_app/view/homepage.dart';
import 'package:translator_app/viewmodel/auth_viewmodel.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    final logoSize = screenWidth * 0.4;
    final horizontalPadding = screenWidth * 0.06;

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.03),

                  // Logo Image
                  Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth * 0.075),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/app_logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.025),

                  Text(
                    'Welcome Back',
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Text(
                    'Sign in to access your translation history',
                    style: GoogleFonts.outfit(
                      fontSize: screenWidth * 0.035,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

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
                    hintText: 'Enter your password',
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

                  // Sign up link
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Signup(),
                          ),
                        );
                      },
                      child: Text(
                        "Don't have an account? Sign up",
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth * 0.034,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Professional Login Button (Filled with white text)
                  CustomButton(
                    text: 'Sign In',
                    variant: ButtonVariant.filled,
                    height: screenHeight * 0.062,
                    fontSize: screenWidth * 0.042,
                    isLoading: authVm.isLoading,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final success = await authVm.login(
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
                                  'Please enter valid email and password',
                              style: GoogleFonts.outfit(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  SizedBox(height: screenHeight * 0.018),

                  // Continue as Guest Button (Outlined with theme colors)
                  CustomButton(
                    text: 'Continue as Guest',
                    variant: ButtonVariant.outlined,
                    height: screenHeight * 0.062,
                    fontSize: screenWidth * 0.04,
                    leadingIcon: Icons.person_outline_rounded,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Homepage(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: screenHeight * 0.03),
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
    super.dispose();
  }
}
