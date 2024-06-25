import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_absensi_app/core/helper/radius_calculate.dart';
import 'package:flutter_absensi_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/get_company/get_company_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/bloc/is_checkedin/is_checkedin_bloc.dart';
import 'package:flutter_absensi_app/presentation/home/pages/attendance_checkin_page.dart';
import 'package:flutter_absensi_app/presentation/home/pages/register_face_attendance_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
// import 'package:safe_device/safe_device.dart';

import '../../../core/core.dart';
import '../../auth/bloc/logout/logout_bloc.dart';
import '../../auth/pages/login_page.dart';
import '../widgets/menu_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? faceEmbedding;

  @override
  void initState() {
    _initializeFaceEmbedding();

    context.read<IsCheckedinBloc>().add(const IsCheckedinEvent.isCheckedIn());
    context.read<GetCompanyBloc>().add(const GetCompanyEvent.getCompany());

    super.initState();
    getCurrentPosition();
  }

  double? latitude;
  double? longitude;

  Future<void> getCurrentPosition() async {
    try {
      Location location = Location();

      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
      latitude = locationData.latitude;
      longitude = locationData.longitude;

      setState(() {});
    } on PlatformException catch (e) {
      if (e.code == 'IO_ERROR') {
        debugPrint(
            'A network error occurred trying to lookup the supplied coordinates: ${e.message}');
      } else {
        debugPrint('Failed to lookup coordinates: ${e.message}');
      }
    } catch (e) {
      debugPrint('An unknown error occurred: $e');
    }
  }

  Future<void> _initializeFaceEmbedding() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      setState(() {
        faceEmbedding = authData?.user?.faceEmbedding;
      });
    } catch (e) {
      print('Error fetching auth data: $e');
      setState(() {
        faceEmbedding = null;
      });
    }
  }

  String truncateWithEllipsis(String text, int maxWords) {
    List<String> words = text.split(' ');
    if (words.length <= maxWords) {
      return text;
    }
    return words.take(maxWords).join(' ') + '...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BlocConsumer<LogoutBloc, LogoutState>(
          listener: (context, state) {
            state.maybeMap(
              orElse: () {},
              success: (_) async {
                await AuthLocalDatasource().removeAuthData();
                context.pushReplacement(const LoginPage());
              },
              error: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value.error),
                    backgroundColor: AppColors.red,
                  ),
                );
              },
            );
          },
          builder: (context, state) {
            return state.maybeWhen(
              orElse: () {
                return IconButton(
                  onPressed: () {
                    context.read<LogoutBloc>().add(const LogoutEvent.logout());
                  },
                  icon: Icon(Icons.exit_to_app_rounded),
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
        title: Expanded(
          child: FutureBuilder(
            future: AuthLocalDatasource().getAuthData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text(
                  'Loading...',
                  style: TextStyle(
                    color: AppColors.black,
                  ),
                );
              } else {
                final user = snapshot.data?.user;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      truncateWithEllipsis(user!.name!, 3) ?? 'Dipa',
                      style: const TextStyle(
                        fontSize: 30.0,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.only(
            top: 40,
            left: 35,
            right: 35,
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: [
              faceEmbedding != null
                  ? Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.green.withOpacity(0.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'WAJAH SUDAH TERDAFTAR',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.red.withOpacity(0.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'BELUM DAFTAR WAJAH!!!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
              const SpaceHeight(150.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Fitur',
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SpaceHeight(20),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GridView(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // Daftar
                            BlocBuilder<GetCompanyBloc, GetCompanyState>(
                              builder: (context, state) {
                                return BlocConsumer<IsCheckedinBloc,
                                    IsCheckedinState>(
                                  listener: (context, state) {
                                    //
                                  },
                                  builder: (context, state) {
                                    return faceEmbedding != null
                                        ? MenuButton(
                                            label: 'Daftar',
                                            iconPath: Assets
                                                .icons.attendanceActive.path,
                                            isDaftar: true,
                                            isDaftarCheckIn: true,
                                            onPressed: () async {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Anda sudah daftar woy'),
                                                  backgroundColor:
                                                      AppColors.red,
                                                ),
                                              );
                                            },
                                          )
                                        : MenuButton(
                                            label: 'Daftar',
                                            iconPath:
                                                Assets.icons.attendance.path,
                                            isDaftarCheckIn: true,
                                            onPressed: () async {
                                              try {
                                                final authData =
                                                    await AuthLocalDatasource()
                                                        .getAuthData();
                                                final faceEmbedding = authData
                                                    ?.user?.faceEmbedding;

                                                if (faceEmbedding == null) {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const RegisterFaceAttendencePage(),
                                                    ),
                                                  );
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.5),
                                                    builder: (context) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  final position =
                                                      await Geolocator
                                                          .getCurrentPosition();
                                                  if (position.isMocked) {
                                                    context.pop();
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      barrierColor: Colors.black
                                                          .withOpacity(0.8),
                                                      builder: (BuildContext
                                                          context) {
                                                        return Center(
                                                          child: AlertDialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  Assets
                                                                      .icons
                                                                      .warning
                                                                      .path,
                                                                  width: 150,
                                                                ),
                                                                SpaceHeight(10),
                                                                const Text(
                                                                  'HAYOHH PAKAI FAKE GPS YA!!!',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: AppColors
                                                                        .primary,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                    return;
                                                  } else {
                                                    // final companyState = context
                                                    //     .read<GetCompanyBloc>()
                                                    //     .state;
                                                    // final latitudePoint =
                                                    //     companyState.maybeWhen(
                                                    //   orElse: () => 0.0,
                                                    //   success: (data) =>
                                                    //       double.parse(
                                                    //           data.latitude!),
                                                    // );
                                                    // final longitudePoint =
                                                    //     companyState.maybeWhen(
                                                    //   orElse: () => 0.0,
                                                    //   success: (data) =>
                                                    //       double.parse(
                                                    //           data.longitude!),
                                                    // );
                                                    // final radiusPoint =
                                                    //     companyState.maybeWhen(
                                                    //   orElse: () => 0.0,
                                                    //   success: (data) =>
                                                    //       double.parse(
                                                    //           data.radiusKm!),
                                                    // );

                                                    // final distanceKm =
                                                    //     RadiusCalculate
                                                    //         .calculateDistance(
                                                    //   position.latitude,
                                                    //   position.longitude,
                                                    //   latitudePoint,
                                                    //   longitudePoint,
                                                    // );

                                                    // if (distanceKm >
                                                    //     radiusPoint) {
                                                    //   ScaffoldMessenger.of(
                                                    //           context)
                                                    //       .showSnackBar(
                                                    //     SnackBar(
                                                    //       content: const Text(
                                                    //           'Anda berada di luar jangkauan absensi'),
                                                    //       backgroundColor:
                                                    //           AppColors.red,
                                                    //     ),
                                                    //   );
                                                    //   context.pop();
                                                    // } else {
                                                    // Mendapatkan status check-in
                                                    final isCheckedinState =
                                                        context
                                                            .read<
                                                                IsCheckedinBloc>()
                                                            .state;
                                                    final isCheckout =
                                                        isCheckedinState
                                                            .maybeWhen(
                                                      orElse: () => false,
                                                      success: (data) =>
                                                          data.isCheckedout,
                                                    );
                                                    final isCheckIn =
                                                        isCheckedinState
                                                            .maybeWhen(
                                                      orElse: () => false,
                                                      success: (data) =>
                                                          data.isCheckedin,
                                                    );

                                                    if (!isCheckIn &&
                                                        !isCheckout) {
                                                      // Belum check-in dan belum check-out
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const AttendanceCheckinPage(),
                                                        ),
                                                      );
                                                    } else if (isCheckIn &&
                                                        isCheckout) {
                                                      // Sudah check-in dan sudah check-out
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                              'Anda sudah checkInOut!!'),
                                                          backgroundColor:
                                                              AppColors.red,
                                                        ),
                                                      );
                                                      context.pop();
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: const Text(
                                                              'Ga usah ngadi2!!'),
                                                          backgroundColor:
                                                              AppColors.red,
                                                        ),
                                                      );
                                                      context.pop();
                                                    }
                                                    // }
                                                  }
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error:'),
                                                    backgroundColor:
                                                        AppColors.red,
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                  },
                                );
                              },
                            ),
                            // Masuk
                            BlocBuilder<GetCompanyBloc, GetCompanyState>(
                              builder: (context, state) {
                                // final latitudePoint = state.maybeWhen(
                                //   orElse: () => 0.0,
                                //   success: (data) =>
                                //       double.parse(data.latitude!),
                                // );
                                // final longitudePoint = state.maybeWhen(
                                //   orElse: () => 0.0,
                                //   success: (data) =>
                                //       double.parse(data.longitude!),
                                // );

                                // final radiusPoint = state.maybeWhen(
                                //   orElse: () => 0.0,
                                //   success: (data) =>
                                //       double.parse(data.radiusKm!),
                                // );
                                return BlocConsumer<IsCheckedinBloc,
                                    IsCheckedinState>(
                                  listener: (context, state) {
                                    //
                                  },
                                  builder: (context, state) {
                                    final isCheckin = state.maybeWhen(
                                      orElse: () => false,
                                      success: (data) => data.isCheckedin,
                                    );
                                    return isCheckin == true
                                        ? MenuButton(
                                            label: 'Datang',
                                            iconPath: isCheckin
                                                ? Assets.icons.menu.datang.path
                                                : Assets
                                                    .icons.menu.datangGrey.path,
                                            isCheckIn: isCheckin,
                                            isDaftarCheckIn: false,
                                            onPressed: () async {
                                              if (isCheckin) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Anda sudah checkin'),
                                                    backgroundColor:
                                                        AppColors.red,
                                                  ),
                                                );
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  barrierColor: Colors.black
                                                      .withOpacity(0.5),
                                                  builder: (context) {
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: AppColors.white,
                                                      ),
                                                    );
                                                  },
                                                );
                                                // cek lokasi palsu
                                                final position =
                                                    await Geolocator
                                                        .getCurrentPosition();

                                                if (position.isMocked) {
                                                  context.pop();
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: true,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.8),
                                                    builder:
                                                        (BuildContext context) {
                                                      return Center(
                                                        child: AlertDialog(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SvgPicture.asset(
                                                                Assets
                                                                    .icons
                                                                    .warning
                                                                    .path,
                                                                width: 150,
                                                              ),
                                                              SpaceHeight(10),
                                                              const Text(
                                                                'HAYOHH PAKAI FAKE GPS YA!!!',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  color: AppColors
                                                                      .primary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  return;
                                                } else {
                                                  Navigator.of(context).pop();
                                                  context.push(
                                                    const AttendanceCheckinPage(),
                                                  );
                                                }
                                              }
                                            },
                                          )
                                        : MenuButton(
                                            label: 'Datang',
                                            iconPath: isCheckin
                                                ? Assets.icons.menu.datang.path
                                                : Assets
                                                    .icons.menu.datangGrey.path,
                                            isCheckIn: isCheckin,
                                            isDaftarCheckIn: false,
                                            onPressed: () async {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Anda belum daftar wajah',
                                                  ),
                                                  backgroundColor:
                                                      AppColors.red,
                                                ),
                                              );
                                            },
                                          );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SpaceHeight(100.0),
            ],
          ),
        ),
      ),
    );
  }
}
