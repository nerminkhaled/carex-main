import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../bloc/patient_home_bloc.dart';
import '../../bloc/patient_home_state.dart';

class WeeklyStreakCard extends StatelessWidget {
  const WeeklyStreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientHomeBloc, PatientHomeState>(
      builder: (context, state) {
        final pct = (state.weeklyAdherencePercent * 100).round();
        final missed = state.missedThisWeek;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/homescreen/Flash.png',
                          width: 14,
                          height: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Weekly Streak',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (missed > 0)
                      Row(
                        children: [
                          Icon(Icons.favorite_rounded,
                              size: 13, color: AppColors.pinkRed),
                          const SizedBox(width: 4),
                          Text(
                            '$missed missed this week',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            'Perfect week!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {}, // TODO: navigate to reports
                      child: Row(
                        children: [
                          const Text(
                            'View weekly report',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.teal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 13, color: AppColors.teal),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/homescreen/pill.png',
                width: 80,
                height: 80,
                
                colorBlendMode: BlendMode.modulate,
              ),
            ],
          ),
        );
      },
    );
  }
}
