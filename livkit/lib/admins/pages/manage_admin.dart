import '../widgets/menu_app_controller.dart';
import '../widgets/responsive.dart';
import 'admins_dashboard.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../widgets/side_menu.dart';
import '../widgets/constants.dart';
import '../widgets/components/tables.dart';
import '../widgets/components/charts.dart';

class AdminsManageAdminsMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,

              child: FirstManageAdminPage(), 
              
            ),
          ],
        ),
      ),
    );
  }
}






class FirstManageAdminPage extends StatelessWidget {
 const FirstManageAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [


            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [

                      ManageAdminPage(),

                      SizedBox(height: defaultPadding),
                      const AdminsTable(),
                      
                      SizedBox(height: defaultPadding),

                    ],
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



class ManageAdminPage extends StatefulWidget {
  const ManageAdminPage({super.key});

  @override
  State<ManageAdminPage> createState() => _ManageAdminPageState();
}

class _ManageAdminPageState extends State<ManageAdminPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedRole = "Main Admin";

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _createAdmin() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Admin account created successfully")),
    );

    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();

    setState(() => _selectedRole = "Main Admin");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Admin Account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _buildLabel("Full Name"),
            _buildTextField(
              controller: _nameController,
              hint: "Enter full name",
              validator: (value) =>
                  value!.isEmpty ? "Name is required" : null,
            ),

            const SizedBox(height: 16),

            _buildLabel("Email Address"),
            _buildTextField(
              controller: _emailController,
              hint: "Enter email address",
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value!.isEmpty ? "Email is required" : null,
            ),

            const SizedBox(height: 16),

            _buildLabel("Password"),
            _buildTextField(
              controller: _passwordController,
              hint: "Enter password",
              obscureText: true,
              validator: (value) =>
                  value!.length < 6 ? "Minimum 6 characters" : null,
            ),

            const SizedBox(height: 16),

            _buildLabel("Confirm Password"),
            _buildTextField(
              controller: _confirmPasswordController,
              hint: "Confirm password",
              obscureText: true,
              validator: (value) => value != _passwordController.text
                  ? "Passwords do not match"
                  : null,
            ),

            const SizedBox(height: 20),

            _buildLabel("Admin Role"),
            _roleDropdown(),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _createAdmin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Create Admin Account",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFF1E1E2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _roleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E1E2C),
          items: const [
            DropdownMenuItem(
              value: "Main Admin",
              child: Text("Main Admin (Full Access)"),
            ),
            DropdownMenuItem(
              value: "Limited Admin",
              child: Text("Limited Admin (Restricted Access)"),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedRole = value!;
            });
          },
        ),
      ),
    );
  }
}
