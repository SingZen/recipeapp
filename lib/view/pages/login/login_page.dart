import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/auth_viewmodel.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            bool success = await authVM.signIn();
            if (!success) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Login failed')));
            }
          },
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}
