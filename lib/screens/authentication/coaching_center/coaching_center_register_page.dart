// screens/authentication/coaching_center/coaching_center_register_page.dart
import 'package:brainboosters_app/ui/navigation/auth_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/basic_info_form.dart';
import 'widgets/contact_info_form.dart';
import 'widgets/facility_info_form.dart';
import 'widgets/academic_info_form.dart';
import 'widgets/additional_info_form.dart';

class CoachingCenterRegisterPage extends StatefulWidget {
  const CoachingCenterRegisterPage({super.key});

  @override
  State<CoachingCenterRegisterPage> createState() =>
      _CoachingCenterRegisterPageState();
}

class _CoachingCenterRegisterPageState
    extends State<CoachingCenterRegisterPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form keys for validation
  final List<GlobalKey<FormState>> _formKeys = List.generate(
    5,
    (index) => GlobalKey<FormState>(),
  );

  // Form data storage with initial values
  final Map<String, Map<String, dynamic>> _formData = {
    'basic': <String, dynamic>{},
    'contact': <String, dynamic>{},
    'facilities': <String, dynamic>{},
    'academic': <String, dynamic>{},
    'additional': <String, dynamic>{},
  };

  // Step titles
  final List<String> _stepTitles = [
    'Basic Information',
    'Contact Details',
    'Facilities & Features',
    'Academic Information',
    'Additional Details',
  ];

  void _nextStep() {
    // Validate current step before proceeding
    if (_validateCurrentStep()) {
      if (_currentStep < _stepTitles.length - 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    // Validate required fields for each step
    switch (_currentStep) {
      case 0: // Basic Info
        final basicData = Map<String, dynamic>.from(_formData['basic'] ?? {});
        if (basicData['centerName']?.isEmpty ?? true) {
          _showError('Center name is required');
          return false;
        }
        if (basicData['contactPerson']?.isEmpty ?? true) {
          _showError('Contact person name is required');
          return false;
        }
        if (basicData['email']?.isEmpty ?? true) {
          _showError('Email is required');
          return false;
        }
        if (!RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(basicData['email'] ?? '')) {
          _showError('Please enter a valid email');
          return false;
        }
        if (basicData['password']?.isEmpty ?? true) {
          _showError('Password is required');
          return false;
        }
        if ((basicData['password']?.length ?? 0) < 6) {
          _showError('Password must be at least 6 characters');
          return false;
        }
        break;
      case 1: // Contact Info
        final contactData = Map<String, dynamic>.from(
          _formData['contact'] ?? {},
        );
        if (contactData['phone']?.isEmpty ?? true) {
          _showError('Phone number is required');
          return false;
        }
        if (contactData['address']?.isEmpty ?? true) {
          _showError('Address is required');
          return false;
        }
        if (contactData['city']?.isEmpty ?? true) {
          _showError('City is required');
          return false;
        }
        if (contactData['state']?.isEmpty ?? true) {
          _showError('State is required');
          return false;
        }
        if (contactData['pincode']?.isEmpty ?? true) {
          _showError('Pincode is required');
          return false;
        }
        break;
      case 2: // Facilities - no required fields
        break;
      case 3: // Academic Info
        final academicData = Map<String, dynamic>.from(
          _formData['academic'] ?? {},
        );
        if (academicData['category']?.isEmpty ?? true) {
          _showError('Please select a primary category');
          return false;
        }
        break;
      case 4: // Additional Info - no required fields
        break;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _updateFormData(String section, Map<String, dynamic> data) {
    setState(() {
      _formData[section] = Map<String, dynamic>.from(data);
    });
  }

Future<void> _submitRegistration() async {
  setState(() => _isLoading = true);
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  try {
    // Safely cast the form data to proper types
    final basicData = Map<String, dynamic>.from(_formData['basic'] ?? {});
    final contactData = Map<String, dynamic>.from(_formData['contact'] ?? {});
    final facilitiesData = Map<String, dynamic>.from(_formData['facilities'] ?? {});
    final academicData = Map<String, dynamic>.from(_formData['academic'] ?? {});
    final additionalData = Map<String, dynamic>.from(_formData['additional'] ?? {});

    // Generate unique identifiers
    final centerSlug = (basicData['centerName'] ?? '')
        .toString()
        .toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
    final centerId = 'CC${DateTime.now().millisecondsSinceEpoch}';

    // Step 1: Create auth user (this will send email confirmation automatically)
    final authResponse = await Supabase.instance.client.auth.signUp(
      email: basicData['email'] ?? '',
      password: basicData['password'] ?? '',
      data: {
        'full_name': basicData['contactPerson'] ?? '',
        'user_type': 'coaching_center',
      },
      // Add redirect URL for email confirmation
      emailRedirectTo: 'https://your-app-url.com/auth/callback',
    );

    if (authResponse.user == null) {
      throw Exception('Failed to create user account');
    }

    // Step 2: Create user profile (inactive until email verified)
    await Supabase.instance.client.from('user_profiles').insert({
      'id': authResponse.user!.id,
      'email': basicData['email'] ?? '',
      'name': basicData['contactPerson'] ?? '',
      'phone': contactData['phone'] ?? '',
      'user_type': 'coaching_center',
      'is_active': false, // Will be activated after email verification
      'is_verified': false, // Will be set to true after email verification
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Step 3: Create coaching center record
    final registrationData = {
      'id': authResponse.user!.id,
      'center_id': centerId,
      'slug': centerSlug,
      'center_name': basicData['centerName'] ?? '',
      'description': additionalData['description'] ?? '',
      'address': contactData['address'] ?? '',
      'city': contactData['city'] ?? '',
      'state': contactData['state'] ?? '',
      'pincode': contactData['pincode'] ?? '',
      'contact_person': basicData['contactPerson'] ?? '',
      'contact_designation': basicData['designation'] ?? '',
      'contact_email': basicData['email'] ?? '',
      'contact_phone': contactData['phone'] ?? '',
      'website_url': contactData['website'] ?? '',
      'establishment_year': basicData['establishmentYear'] ?? DateTime.now().year,
      'registration_number': additionalData['registrationNumber'] ?? '',
      'license_number': additionalData['licenseNumber'] ?? '',
      'gst_number': additionalData['gstNumber'] ?? '',
      'pan_number': additionalData['panNumber'] ?? '',
      'founders_name': basicData['foundersName'] ?? '',
      'facilities': List<String>.from(facilitiesData['facilities'] ?? []),
      'specializations': List<String>.from(academicData['specializations'] ?? []),
      'teaching_modes': List<String>.from(academicData['teachingModes'] ?? ['offline']),
      'languages': List<String>.from(academicData['languages'] ?? ['English']),
      'teaching_methods': List<String>.from(academicData['teachingMethods'] ?? []),
      'category': academicData['category'] ?? '',
      'exams_prepared': List<String>.from(academicData['examsOffered'] ?? []),
      'batch_timings': List<String>.from(academicData['batchTimings'] ?? []),
      'has_online_classes': facilitiesData['hasOnlineClasses'] ?? false,
      'has_offline_classes': facilitiesData['hasOfflineClasses'] ?? true,
      'has_hybrid_classes': facilitiesData['hasHybridClasses'] ?? false,
      'has_library': facilitiesData['hasLibrary'] ?? false,
      'has_lab_facility': facilitiesData['hasLabFacility'] ?? false,
      'has_hostel_facility': facilitiesData['hasHostelFacility'] ?? false,
      'has_cafeteria': facilitiesData['hasCafeteria'] ?? false,
      'has_transport_facility': facilitiesData['hasTransportFacility'] ?? false,
      'admission_process': academicData['admissionProcess'] ?? '',
      'fees': academicData['averageFees'] ?? 0,
      'is_verified': false, // Not verified until admin approves
      'verification_status': 'email_pending', // Waiting for email verification first
      'metadata': {
        'registration_type': 'self_verification',
        'submitted_at': DateTime.now().toIso8601String(),
        'registration_source': 'mobile_app',
      },
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Insert into coaching_centers table
    await Supabase.instance.client
        .from('coaching_centers')
        .insert(registrationData);

    // Step 4: Create analytics record
    await Supabase.instance.client.from('coaching_center_analytics').insert({
      'coaching_center_id': authResponse.user!.id,
      'total_enquiries': 0,
      'admissions_this_month': 0,
      'active_students': 0,
      'average_attendance': 0.0,
      'successful_placements': 0,
      'student_satisfaction_score': 0.0,
      'monthly_enrollments': {},
      'subject_wise_performance': {},
      'website_visits': 0,
      'brochure_downloads': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Sign out the user since they need to verify email first
    await Supabase.instance.client.auth.signOut();

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Registration successful! Please check your email and click the verification link to activate your account.',
        ),
        duration: Duration(seconds: 8),
        backgroundColor: Colors.green,
      ),
    );

    if (!mounted) return;
    context.go(AuthRoutes.authSelection);
  } catch (e) {
    print('Registration error: $e');
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text('Registration failed: ${e.toString()}')),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00B894)),
          onPressed: () => context.go(AuthRoutes.authSelection),
        ),
        title: const Text(
          'Register Coaching Center',
          style: TextStyle(
            color: Color(0xFF00B894),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: List.generate(_stepTitles.length, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: index < _stepTitles.length - 1 ? 8 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? const Color(0xFF00B894)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  'Step ${_currentStep + 1} of ${_stepTitles.length}: ${_stepTitles[_currentStep]}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00B894),
                  ),
                ),
              ],
            ),
          ),

          // Form Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                BasicInfoForm(
                  formKey: _formKeys[0],
                  initialData: Map<String, dynamic>.from(
                    _formData['basic'] ?? {},
                  ),
                  onDataChanged: (data) => _updateFormData('basic', data),
                ),
                ContactInfoForm(
                  formKey: _formKeys[1],
                  initialData: Map<String, dynamic>.from(
                    _formData['contact'] ?? {},
                  ),
                  onDataChanged: (data) => _updateFormData('contact', data),
                ),
                FacilityInfoForm(
                  formKey: _formKeys[2],
                  initialData: Map<String, dynamic>.from(
                    _formData['facilities'] ?? {},
                  ),
                  onDataChanged: (data) => _updateFormData('facilities', data),
                ),
                AcademicInfoForm(
                  formKey: _formKeys[3],
                  initialData: Map<String, dynamic>.from(
                    _formData['academic'] ?? {},
                  ),
                  onDataChanged: (data) => _updateFormData('academic', data),
                ),
                AdditionalInfoForm(
                  formKey: _formKeys[4],
                  initialData: Map<String, dynamic>.from(
                    _formData['additional'] ?? {},
                  ),
                  onDataChanged: (data) => _updateFormData('additional', data),
                ),
              ],
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00B894),
                        side: const BorderSide(color: Color(0xFF00B894)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _currentStep < _stepTitles.length - 1
                        ? _nextStep
                        : _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _currentStep < _stepTitles.length - 1
                                ? 'Next'
                                : 'Submit Registration',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
