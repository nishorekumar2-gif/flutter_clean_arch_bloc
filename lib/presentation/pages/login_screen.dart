import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_arch/presentation/routes/app_router.dart';
import 'package:flutter_clean_arch/presentation/viewmodels/login_view_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController(text: "emilys");
  final passwordController = TextEditingController(text: "emilyspass");

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginCall() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter required fields')));
      return;
    }

    context.read<LoginBloc>().add(
      LoginSubmitted(username: username, password: password),
    );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<LoginBloc, LoginState>(
    listenWhen: (previous, next) =>
        (previous.isLoggedIn != true && next.isLoggedIn) ||
        (next.error != null && next.error != previous.error),
    listener: (context, next) async {
      if (next.isLoggedIn) {
        final sharedPreferences = await SharedPreferences.getInstance();
        print("Shared Preferences set : ${next.user!.accessToken}");
        sharedPreferences.setString(
          "access_token",
          next.user!.accessToken ?? '',
        );
        sharedPreferences.setInt("user_id", next.user!.id!);

        final storage = FlutterSecureStorage();
        await storage.write(key: 'access_token', value: next.user!.accessToken);
        final secureData = await storage.read(key: 'access_token');
        print("SecureData: $secureData");

        await storage.write(key: 'user_name', value: next.user!.username);
        final secureDataUserName = await storage.read(key: 'user_name');
        print("SecureData Username: $secureDataUserName");

        AppRouterScope.of(context).goTo('/dashboard');
      }

      if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    },
    builder: (context, state) => LayoutBuilder(
      builder: (context, constraint) {
        return (constraint.maxWidth < 600)
            ? Scaffold(
                body: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 5.0,
                    children: [
                      Image.asset(
                        "assets/images/logo.png",
                        alignment: AlignmentGeometry.center,
                        width: 100,
                        height: 100,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          textAlign: TextAlign.start,
                          "Username",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextField(
                        controller: usernameController,
                        /*onChanged: (val) {
                  print("Text Val: $val");
                },*/
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          textAlign: TextAlign.start,
                          "Password",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        /*onChanged: (val) {
                  print("Text Val: $val");
                },*/
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.verified_user),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.red, width: 3),
                        ),
                        onPressed: state.isLoading == true ? null : loginCall,
                        child: Text(
                          "Login",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Scaffold(
                body: Center(
                  child: Theme.of(context).platform == TargetPlatform.android
                      ? ElevatedButton(
                          onPressed: () {},
                          child: Text("It won't support for Tablet"),
                        )
                      : Theme.of(context).platform == TargetPlatform.iOS
                      ? CupertinoButton(
                          child: Text("It won't support for Tablet"),
                          onPressed: () {},
                        )
                      : CupertinoButton(
                          child: Text("It won't support for Tablet"),
                          onPressed: () {},
                        ),
                ),
              );
      },
    ),
  );
}

void navigationCall() {}
