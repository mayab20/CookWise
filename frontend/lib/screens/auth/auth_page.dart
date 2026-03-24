import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/screens/user/user_viewmodel.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/widgets/floating_shapes_painter.dart';


class AuthPage extends StatefulWidget {

  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Signup extra state
  DateTime? selectedBirthdate;
  String selectedSex = "";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _floatingShapesBackground(),
          Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color.fromARGB(200, 255, 255, 255),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(207, 168, 168, 168),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLogin ? _loginForm() : _signupForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingShapesBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: FloatingShapesPainter(),
      ),
    );
  }

  Widget _loginForm() {
    return Column(
      key: const ValueKey("login"),
      mainAxisSize: MainAxisSize.min,
      children: [
        _title("Sign In"),
        const SizedBox(height: 30),

        _input(emailController, "Email"),
        _input(passwordController, "Password", isPassword: true),

        const SizedBox(height: 20),

        _actionButton("Sign In", _handleLogin),

        const SizedBox(height: 16),

        _switchText(
          "Don't have an account?",
          "Sign Up",
          () => setState(() => isLogin = false),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _snack("Please fill email and password");
      return;
    }

    final userVM = context.read<UserViewModel>();
    final success = await userVM.login(email, password);

    if (success && mounted) {
      Navigator.pushReplacementNamed(
        context,
        userVM.isAdmin ? '/admin' : '/home',
      );
    } else {
      _snack(userVM.errorMessage ?? "Login failed");
    }
  }



  Widget _signupForm() {
    return Column(
      key: const ValueKey("signup"),
      mainAxisSize: MainAxisSize.min,
      children: [
        _title("Sign Up"),
        const SizedBox(height: 30),

        _input(nameController, "Name"),
        _input(emailController, "Email"),
        _input(passwordController, "Password", isPassword: true),
        _input(confirmPasswordController, "Confirm Password", isPassword: true),

        const SizedBox(height: 10),
        _birthdatePicker(),
        const SizedBox(height: 10),
        _sexPicker(),

        const SizedBox(height: 20),

        _actionButton("Sign Up", _handleSignup),

        const SizedBox(height: 16),

        _switchText(
          "Already have an account?",
          "Sign In",
          () => setState(() => isLogin = true),
        ),
      ],
    );
  }

  Future<void> _handleSignup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _snack("Please fill all required fields");
      return;
    }

    if (password != confirmPassword) {
      _snack("Passwords do not match");
      return;
    }

    if (selectedBirthdate == null || selectedSex.isEmpty) {
      _snack("Please complete your profile");
      return;
    }

    final user = User.register(
      name: name,
      email: email,
      password: password,
      birthdate: selectedBirthdate!,
      sex: selectedSex,
    );

    final userVM = context.read<UserViewModel>();

    final success = await userVM.register(user);


    if (success && mounted) {
      Navigator.pushReplacementNamed(
        context,
        userVM.isAdmin ? '/admin' : '/home',
      );
    } else {
      _snack(userVM.errorMessage ?? "Signup failed");
    }
  }



  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Color.fromARGB(255, 0, 0, 0),
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color.fromARGB(179, 140, 140, 141)),
          filled: true,
          fillColor: Colors.white24,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.black,
              width: 2.0,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
    );
  }

  Widget _birthdatePicker() {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: now.subtract(const Duration(days: 365 * 18)),
          firstDate: DateTime(1900),
          lastDate: now,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.grey,        
                  primary: AppColors.secondaryColor,          // Selected dates
                  secondary: AppColors.mainColor,        // buttons
                  surface: AppColors.background,          // Background
                  onPrimary: Colors.white,                
                  onSecondary: AppColors.offWhite,       // Text on buttons
                  onSurface: AppColors.mainColor,         // Text on background
                ),
              ), 
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => selectedBirthdate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2.0),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: Color.fromARGB(179, 0, 0, 0),
            ),
            const SizedBox(width: 10),
            Text(
              selectedBirthdate == null
                  ? "Select Birthdate"
                  : "${selectedBirthdate!.day}/${selectedBirthdate!.month}/${selectedBirthdate!.year}",
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sexPicker() {
    return DropdownButtonFormField<String>(
      initialValue: selectedSex.isEmpty ? null : selectedSex,
      dropdownColor: const Color.fromARGB(255, 254, 254, 254),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.black,
            width: 2.0,
            style: BorderStyle.solid,
          ),
        ),
      ),
      hint: const Text(
        "Select Gender",
        style: TextStyle(color: Color.fromARGB(187, 0, 0, 0)),
      ),
      style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      items: const [
        DropdownMenuItem(value: "Male", child: Text("Male")),
        DropdownMenuItem(value: "Female", child: Text("Female")),
      ],
      onChanged: (value) {
        setState(() => selectedSex = value ?? "");
      },
    );
  }

  Widget _actionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _switchText(String text, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: const TextStyle(color: Color.fromARGB(179, 0, 0, 0))),
        const SizedBox(width: 6),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: const TextStyle(
                color: AppColors.mainColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
