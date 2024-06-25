import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../core/components/components.dart';
import '../../../core/constants/colors.dart';

class MenuButton extends StatefulWidget {
  final String label;
  final String? iconPath;
  final bool? isCheckIn;
  final bool? isDaftar;
  final bool isDaftarCheckIn;
  final VoidCallback onPressed;

  const MenuButton({
    super.key,
    required this.label,
    this.iconPath,
    this.isCheckIn,
    this.isDaftar,
    required this.isDaftarCheckIn,
    required this.onPressed,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.0),
          // border: Border.all(
          //   color: AppColors.stroke,
          // ),
          color: widget.isDaftarCheckIn == true
              ? widget.isDaftar == true
                  ? AppColors.primary.withOpacity(0.4)
                  : AppColors.white
              : widget.isCheckIn == true
                  ? AppColors.primary.withOpacity(.4)
                  : AppColors.white,
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.isDaftarCheckIn
                    ? SvgPicture.asset(
                        widget.iconPath!,
                        width: 40.0,
                        height: 40.0,
                      )
                    : Icon(
                        Icons.fact_check_outlined,
                        size: 35,
                        color: widget.isCheckIn == true
                            ? AppColors.primary
                            : AppColors.black,
                      ),
                const SpaceHeight(4.0),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: widget.isDaftarCheckIn == true
                        ? widget.isDaftar == true
                            ? AppColors.primary
                            : AppColors.black
                        : widget.isCheckIn == true
                            ? AppColors.primary
                            : AppColors.black,
                  ),
                ),
              ],
            ),
 
          ],
        ),
      ),
    );
  }
}
