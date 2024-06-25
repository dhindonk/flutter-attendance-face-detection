import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/presentation/auth/bloc/login/login_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/core.dart';
import '../../home/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  bool isShowPassword = false;
  bool isFormValid = false;
  FocusNode emailLoginFocusNode = FocusNode();
  FocusNode passwordLoginFocusNode = FocusNode();
   
  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime timeBackPressed = DateTime.now();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        final difference = DateTime.now().difference(timeBackPressed);
        final isExitWarning = difference >= Duration(seconds: 2);
        timeBackPressed = DateTime.now();

        if (isExitWarning) {
          final message = 'Press back again to exit';
          Fluttertoast.showToast(
            msg: message,
            fontSize: 12,
            textColor: AppColors.white,
            backgroundColor: AppColors.primary,
          );
          return;
        } else {
          Fluttertoast.cancel();
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: ListView(
            children: [
              const SpaceHeight(30),
              Image.asset(
                Assets.images.logo.path,
                height: 150,
              ),
              const SpaceHeight(100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Login Page',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color.fromARGB(255, 59, 59, 59),
                    ),
                  ),
                ],
              ),
              const SpaceHeight(30),
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        // SpaceHeight(5),
                        TextFormField(
                          controller: emailController,
                          focusNode: emailLoginFocusNode,
                          // decoration: customDecoration(
                          //   prefixIcon: Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: SvgPicture.asset(
                          //       Assets.icons.email.path,
                          //       height: 20,
                          //       width: 20,
                          //     ),
                          //   ),
                          //   hintText: 'Email',
                          // ),
                          onTapOutside: (event) {
                            emailLoginFocusNode.unfocus();
                          },
                          keyboardType: TextInputType.emailAddress,
                          onFieldSubmitted: (_) {
                            if (formKey.currentState!.validate()) {
                              return;
                            } else {
                              passwordLoginFocusNode.requestFocus();
                            }
                          },
                          validator: (value) {
                            if (value!.length == 0) {
                              return "Email harus diisi!!";
                            }
                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                .hasMatch(value)) {
                              return ("Email wajib pakai @****");
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SpaceHeight(25),
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        // SpaceHeight(5),
                        TextFormField(
                          controller: passwordController,
                          focusNode: passwordLoginFocusNode,
                          obscureText: !isShowPassword,
                          onChanged: (value) {
                            if (value.length > 6) {
                              isFormValid = true;
                              setState(() {});
                            } else {
                              isFormValid = false;
                              setState(() {});
                            }
                          },
                          // decoration: customDecoration(
                          //   prefixIcon: Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: SvgPicture.asset(
                          //       Assets.icons.password.path,
                          //       height: 20,
                          //       width: 20,
                          //     ),
                          //   ),
                          //   suffixIcon: IconButton(
                          //     icon: Icon(
                          //       isShowPassword
                          //           ? Icons.visibility_off
                          //           : Icons.visibility,
                          //       color: AppColors.grey,
                          //     ),
                          //     onPressed: () {
                          //       setState(() {
                          //         isShowPassword = !isShowPassword;
                          //       });
                          //     },
                          //   ),
                          //   hintText: 'Password',
                          // ),
                          onTapOutside: (event) {
                            passwordLoginFocusNode.unfocus();
                          },
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            RegExp regex = new RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return "Password harus diisi!!";
                            }
                            if (!regex.hasMatch(value)) {
                              return ("Password minimal 6 karakter");
                            } else {
                              return null;
                            }
                          },
                          onFieldSubmitted: (_) {
                            if (formKey.currentState!.validate()) {
                              context.read<LoginBloc>().add(
                                    LoginEvent.login(
                                      emailController.text,
                                      passwordController.text,
                                    ),
                                  );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              SpaceHeight(100),
              Column(
                children: [
                  BlocListener<LoginBloc, LoginState>(
                    listener: (context, state) {
                      state.maybeWhen(
                        orElse: () {},
                        success: (data) {
                          AuthLocalDatasource().saveAuthData(data);
                          context.pushReplacement(const HomePage());
                        },
                        error: (message) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: AppColors.red,
                            ),
                          );
                        },
                      );
                    },
                    child: BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        return state.maybeWhen(
                          orElse: () {
                            return Button.filled(
                              onPressed: isFormValid
                                  ? () {
                                      if (formKey.currentState!.validate()) {
                                        context.read<LoginBloc>().add(
                                              LoginEvent.login(
                                                emailController.text,
                                                passwordController.text,
                                              ),
                                            );
                                      }
                                    }
                                  : () {},
                              label: 'Sign In',
                              color: isFormValid
                                  ? AppColors.primary
                                  : AppColors.grey,
                            );
                          },
                          loading: () {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  //
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // return Scaffold(
  //   body: SingleChildScrollView(
  //     child: Padding(
  //       padding: const EdgeInsets.all(20.0),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const SpaceHeight(50),
  //           Image.asset(
  //             Assets.images.logo.path,
  //             width: MediaQuery.of(context).size.width,
  //             height: 100,
  //           ),
  //           const SpaceHeight(107),
  //           CustomTextField(
  //             controller: emailController,
  //             label: 'Email Address',
  //             showLabel: false,
  //             prefixIcon: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: SvgPicture.asset(
  //                 Assets.icons.email.path,
  //                 height: 20,
  //                 width: 20,
  //               ),
  //             ),
  //           ),
  //           const SpaceHeight(20),
  //           CustomTextField(
  //             controller: passwordController,
  //             label: 'Password',
  //             showLabel: false,
  //             obscureText: !isShowPassword,
  //             prefixIcon: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: SvgPicture.asset(
  //                 Assets.icons.password.path,
  //                 height: 20,
  //                 width: 20,
  //               ),
  //             ),
  //             suffixIcon: IconButton(
  //               icon: Icon(
  //                 isShowPassword ? Icons.visibility_off : Icons.visibility,
  //                 color: AppColors.grey,
  //               ),
  //               onPressed: () {
  //                 setState(() {
  //                   isShowPassword = !isShowPassword;
  //                 });
  //               },
  //             ),
  //           ),
  //           const SpaceHeight(104),
  //           BlocListener<LoginBloc, LoginState>(
  //             listener: (context, state) {
  //               state.maybeWhen(
  //                 orElse: () {},
  //                 success: (data) {
  //                   AuthLocalDatasource().saveAuthData(data);
  //                   context.pushReplacement(const MainPage());
  //                 },
  //                 error: (message) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text(message),
  //                       backgroundColor: AppColors.red,
  //                     ),
  //                   );
  //                 },
  //               );
  //             },
  //             child: BlocBuilder<LoginBloc, LoginState>(
  //                 builder: (context, state) {
  //               return state.maybeWhen(
  //                 orElse: () {
  //                   return Button.filled(
  //                     onPressed: () {
  //                       // context.pushReplacement(const MainPage());
  //                       context.read<LoginBloc>().add(
  //                             LoginEvent.login(
  //                               emailController.text,
  //                               passwordController.text,
  //                             ),
  //                           );
  //                     },
  //                     label: 'Sign In',
  //                   );
  //                 },
  //                 loading: () {
  //                   return const Center(
  //                     child: CircularProgressIndicator(),
  //                   );
  //                 },
  //               );
  //             }),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ),
  // );
  // }
}
