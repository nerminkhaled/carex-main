import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_widgets.dart';

class SignupPage extends StatelessWidget {
  //statelass widget for signup page
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      //injecting the AuthBloc into the widget tree so that _PatientSignupView can access it
      create: (_) => AuthBloc(
        repository: SupabaseAuthRepository(),
      ), //creating an instance of AuthBloc with SupabaseAuthRepository
      child:
          const _PatientSignupView(), //the actual signup form view child of the BlocProvider
    );
  }
}

class _PatientSignupView extends StatefulWidget {
  //stateful widget for the signup form to manage form state and user input
  const _PatientSignupView();

  @override
  State<_PatientSignupView> createState() => _PatientSignupViewState(); //creating the mutable state for the signup form
}

class _PatientSignupViewState extends State<_PatientSignupView> {
  //state class that holds the form controllers, validation logic, and UI for the signup page
  final _nameController = TextEditingController();
  final _emailController =
      TextEditingController(); //texteditting controllers to capture user input for name, email, password, phone, date of birth, and medical conditions
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _conditionsController = TextEditingController();

  bool _obscurePassword = true;
  String _gender = 'male';

  static const _teal = Color(0xFF1ABFB0);
  static const _tealDark = Color(0xFF0EA89B);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _conditionsController.dispose();
    super
        .dispose(); //super.dispose() to clean up the controllers when the widget is removed from the tree to prevent memory leaks
  }

  Future<void> _pickDate() async {
    //function to show a custom date picker bottom sheet and update the date of birth field when a date is selected
    final picked = await showModalBottomSheet<DateTime>(
      //modelbottomsheet is a popup that appears from bottom
      //showing a modal bottom sheet that returns a DateTime when a date is selected
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          const _CalendarSheet(), //the content of the bottom sheet is the _CalendarSheet widget defined below
    );
    if (picked != null) {
      //if a date was picked, update the _dobController text with the selected date formatted as MM/DD/YYYY
      _dobController.text =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    //build method that constructs the UI of the signup page and listens for authentication state changes to show success or error messages and navigate accordingly
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        //listening for changes in the AuthBloc state to react to authentication events such as successful signup, email confirmation required, or failure
        print('UI STATE: $state');

        if (state is AuthSuccess) {
          ScaffoldMessenger.of(
            //showing a snackbar message on successful signup and navigating to the home page
            context,
          ).showSnackBar(const SnackBar(content: Text('Signup successful')));
          context.go('/home');
        } else if (state is AuthEmailConfirmationRequired) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/login');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: _teal,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeroSection(context),
              Expanded(child: _buildFormCard(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height *
          0.25, //responsive height for the hero section
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C9D91), _teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip
            .none, //allowing the image to overflow outside the container bounds for a more dynamic design
        children: [
          Positioned(
            right: -8,
            top: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/login and signup/3D Asset Clay Extra 3 2.png',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 20,
            top: 16,
            child: GestureDetector(
              onTap: () => context.go('/signup'),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 17,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 28,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your health journey starts here',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        //allowing the form to be scrollable when the keyboard is open or on smaller screens
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthInputField(
              controller: _nameController,
              hintText: 'Full name',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            AuthInputField(
              controller: _emailController,
              hintText: 'Email address',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            AuthInputField(
              controller: _passwordController,
              hintText: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black38,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 14),
            AuthInputField(
              controller: _phoneController,
              hintText: 'Phone number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: AuthInputField(
                  controller: _dobController,
                  hintText: 'Date of birth (MM/DD/YYYY)',
                  prefixIcon: Icons.calendar_today_outlined,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gender',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _GenderButton(
                  label: 'Male',
                  selected: _gender == 'male',
                  onTap: () => setState(() => _gender = 'male'),
                ),
                const SizedBox(width: 12),
                _GenderButton(
                  label: 'Female',
                  selected: _gender == 'female',
                  onTap: () => setState(() => _gender = 'female'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AuthInputField(
              controller: _conditionsController,
              hintText: 'Medical conditions (optional)',
              prefixIcon: Icons.medical_information_outlined,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 28),
            _buildSubmitButton(context),
            const SizedBox(height: 16),
            _buildLoginLink(context),
          ],
        ),
      ),
    );
  }

  String? _validate() {
    //if any validation fails, return an error message string; otherwise return null if all inputs are valid
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneController.text.trim();
    final dob = _dobController.text;

    if (name.isEmpty) return 'Please enter your full name';
    if (email.isEmpty) return 'Please enter your email address';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    if (password.isEmpty) return 'Please enter a password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (phone.isEmpty) return 'Please enter your phone number';
    if (dob.isEmpty) return 'Please select your date of birth';
    return null;
  }

  Widget _buildSubmitButton(BuildContext context) {
    //building the submit button that triggers form validation and dispatches the SignupSubmitted event to the AuthBloc when pressed, showing a loading indicator while the signup process is ongoing
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  final error = _validate();
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  context.read<AuthBloc>().add(
                    //start the signup process by dispatching the SignupSubmitted event with the form data to the AuthBloc
                    SignupSubmitted(
                      name: _nameController.text.trim(),
                      email: _emailController.text.trim(),
                      password: _passwordController.text,
                      phone: _phoneController.text.trim(),
                      role: 'patient',
                      dateOfBirth: _dobController.text,
                      gender: _gender,
                      medicalConditions:
                          _conditionsController.text.trim().isEmpty
                          ? null
                          : _conditionsController.text.trim(),
                    ),
                  );
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isLoading
                  ? null
                  : const LinearGradient(
                      colors: [_tealDark, _teal],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: isLoading ? Colors.black12 : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: _teal.withValues(alpha: 0.38),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: _teal,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      // centering the login link text and making it tappable to navigate to the login page for users who already have an account
      child: GestureDetector(
        onTap: () => context.go('/login'),
        child: RichText(
          //using RichText to create a text link that navigates to the login page when tapped
          text: const TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(color: Colors.black45, fontSize: 13.5),
            children: [
              TextSpan(
                text: 'Login',
                style: TextStyle(color: _teal, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Calendar date-picker bottom sheet ───────────────────────────────────────

class _CalendarSheet extends StatefulWidget {
  //create stateful widget for the custom calendar date-picker that appears as a bottom sheet when selecting the date of birth field in the signup form
  const _CalendarSheet();

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState(); //take state for managing the displayed month, selected date, and calendar logic for rendering the days and handling user interaction within the calendar sheet
}

class _CalendarSheetState extends State<_CalendarSheet> {
  static const _teal = Color(0xFF1ABFB0);

  DateTime _displayed = DateTime(2000, 1);
  DateTime? _selected;

  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  void _prevMonth() => setState(() {
    //updating the state to show the previous month in the calendar when the left arrow button is pressed, ensuring that the month does not go before January 1900
    _displayed = DateTime(
      _displayed.year,
      _displayed.month - 1,
    ); //same yaer perv month
  });

  void _nextMonth() {
    final next = DateTime(_displayed.year, _displayed.month + 1);
    if (!next.isAfter(DateTime.now())) setState(() => _displayed = next);
  }

  List<DateTime?> _buildDays() {
    final first = DateTime(_displayed.year, _displayed.month, 1);
    // Monday = 1 … Sunday = 7; offset so Monday is column 0
    final startOffset = first.weekday - 1;
    final daysInMonth = DateTime(_displayed.year, _displayed.month + 1, 0).day;
    return [
      ...List.filled(startOffset, null),
      //move list of days to correct starting column based on the weekday of the first day of the month by adding null values for the empty cells before the first day
      for (int d = 1; d <= daysInMonth; d++)
        DateTime(_displayed.year, _displayed.month, d),
    ];
  }

  bool _isFuture(DateTime d) => d.isAfter(
    DateTime.now(),
  ); //helper function to determine if a given date is in the future, used to disable selection of future dates in the calendar

  @override
  Widget build(BuildContext context) {
    final days = _buildDays();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 4),
            child: Row(
              children: [
                const Text(
                  'Select date',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(
                    context,
                  ), //close the bottom sheet when the close icon is pressed
                  icon: const Icon(
                    Icons.close, //close icon to dismiss the calendar sheet
                    size: 20,
                    color: Colors.black45,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: const Icon(Icons.chevron_left, color: Colors.black54),
                ),
                Text(
                  '${_months[_displayed.month - 1]} ${_displayed.year}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: Icon(
                    Icons.chevron_right,
                    color:
                        DateTime(
                          _displayed.year,
                          _displayed.month + 1,
                        ).isAfter(DateTime.now())
                        ? Colors.black26
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Weekday headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _weekdays
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 6),
          // Calendar grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 0,
                childAspectRatio: 1,
              ),
              itemCount: days.length,
              itemBuilder: (_, i) {
                final day = days[i];
                if (day == null) return const SizedBox();

                final isSelected =
                    _selected != null &&
                    day.year == _selected!.year &&
                    day.month == _selected!.month &&
                    day.day == _selected!.day;
                final isToday =
                    day.year == DateTime.now().year &&
                    day.month == DateTime.now().month &&
                    day.day == DateTime.now().day;
                final disabled = _isFuture(day);

                return GestureDetector(
                  onTap: disabled
                      ? null
                      : () => setState(() => _selected = day),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? _teal : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(color: _teal, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : disabled
                              ? Colors.black26
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => Navigator.pop(context, _selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  disabledBackgroundColor: _teal.withValues(alpha: 0.4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Date',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gender button ────────────────────────────────────────────────────────────

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1ABFB0) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1ABFB0), width: 1.5),
          boxShadow: selected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF1ABFB0),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
