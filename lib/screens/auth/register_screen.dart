import 'dart:ui';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // New "Cyber-Orchid" Palette
  static const Color violet = Color(0xFFA855F7);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color obsidianBg = Color(0xFF0B0E14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
      body: Stack(
        children: [
          // Background Gradient Orbs for depth
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlurCircle(250, violet.withOpacity(0.15)),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: _buildBlurCircle(200, cyan.withOpacity(0.1)),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    width: 450,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        const Text(
                          "NEW IDENTIFICATION",
                          style: TextStyle(
                            color: cyan,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Create Registry",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 35),

                        // Inputs
                        _input("Full Legal Name", Icons.person_add_alt_1_outlined),
                        const SizedBox(height: 20),
                        _input("Network Email", Icons.alternate_email_rounded),
                        const SizedBox(height: 20),
                        _input("Security Access Key", Icons.vpn_key_outlined, obscure: true),
                        
                        const SizedBox(height: 40),

                        // Action Button
                        _button("INITIALIZE ACCESS", () {
                           Navigator.pushReplacementNamed(context, AppRoutes.home);
                        }),
                        
                        const SizedBox(height: 25),
                        
                        // Footer
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: const TextSpan(
                              text: "Already indexed? ",
                              style: TextStyle(color: Colors.white38, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: "Return to Login",
                                  style: TextStyle(
                                    color: violet,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _input(String label, IconData icon, {bool obscure = false}) {
    return TextFormField(
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        floatingLabelStyle: const TextStyle(color: cyan, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: violet, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.01),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: violet, width: 1.5),
        ),
      ),
    );
  }

  Widget _button(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: violet.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: violet,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }
}
