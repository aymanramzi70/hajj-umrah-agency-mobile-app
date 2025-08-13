// lib/screens/profile/customer_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hajj_umrah_mobile_app/providers/auth_notifier.dart'; // استيراد AuthNotifier
import 'package:hajj_umrah_mobile_app/models/customer.dart'; // استيراد Customer Model
import 'package:intl/intl.dart'; // لتنسيق التواريخ

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers for text fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _nationalIdController;
  late TextEditingController _passportNumberController;
  late TextEditingController _addressController;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    final authNotifier = context.read<AuthNotifier>();
    _firstNameController = TextEditingController(text: authNotifier.customerProfile?.firstName);
    _lastNameController = TextEditingController(text: authNotifier.customerProfile?.lastName);
    _emailController = TextEditingController(text: authNotifier.customerProfile?.email);
    _phoneNumberController = TextEditingController(text: authNotifier.customerProfile?.phoneNumber);
    _nationalIdController = TextEditingController(text: authNotifier.customerProfile?.nationalId);
    _passportNumberController = TextEditingController(text: authNotifier.customerProfile?.passportNumber);
    _addressController = TextEditingController(text: authNotifier.customerProfile?.address);
    _selectedGender = authNotifier.customerProfile?.gender;
    _selectedDateOfBirth = authNotifier.customerProfile?.dateOfBirth;

    // Fetch profile if it's null (e.g., direct access or first time after login)
    if (authNotifier.customerProfile == null) {
      _fetchProfile();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _nationalIdController.dispose();
    _passportNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authNotifier = context.read<AuthNotifier>();
    final String? error = await authNotifier.fetchCustomerProfile();
    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
    } else {
      // Update controllers after fetching data
      _firstNameController.text = authNotifier.customerProfile?.firstName ?? '';
      _lastNameController.text = authNotifier.customerProfile?.lastName ?? '';
      _emailController.text = authNotifier.customerProfile?.email ?? '';
      _phoneNumberController.text = authNotifier.customerProfile?.phoneNumber ?? '';
      _nationalIdController.text = authNotifier.customerProfile?.nationalId ?? '';
      _passportNumberController.text = authNotifier.customerProfile?.passportNumber ?? '';
      _addressController.text = authNotifier.customerProfile?.address ?? '';
      _selectedGender = authNotifier.customerProfile?.gender;
      _selectedDateOfBirth = authNotifier.customerProfile?.dateOfBirth;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authNotifier = context.read<AuthNotifier>();
      final Map<String, dynamic> customerData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'phone_number': _phoneNumberController.text,
        'national_id': _nationalIdController.text.isEmpty ? null : _nationalIdController.text,
        'passport_number': _passportNumberController.text.isEmpty ? null : _passportNumberController.text,
        'date_of_birth': _selectedDateOfBirth?.toIso8601String().split('T')[0], // Format to YYYY-MM-DD
        'gender': _selectedGender,
        'address': _addressController.text.isEmpty ? null : _addressController.text,
      };

      final String? error = await authNotifier.updateCustomerProfile(customerData);

      if (error == null) {
        setState(() {
          _isEditing = false; // الخروج من وضع التعديل
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح!')),
        );
      } else {
        setState(() {
          _errorMessage = error;
        });
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to rebuild when customerProfile changes
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        final customer = authNotifier.customerProfile;

        if (_isLoading || customer == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('الملف الشخصي', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('الملف الشخصي', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue,
            actions: [
              if (!_isEditing) // عرض زر التعديل فقط عندما لا يكون في وضع التعديل
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
              if (_isEditing) // عرض زر الحفظ فقط في وضع التعديل
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.white),
                  onPressed: _isLoading ? null : _updateProfile,
                ),
              if (_isEditing) // عرض زر الإلغاء في وضع التعديل
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      // إعادة تعيين قيم المتحكمات إلى البيانات الأصلية
                      _firstNameController.text = customer.firstName;
                      _lastNameController.text = customer.lastName;
                      _emailController.text = customer.email ?? '';
                      _phoneNumberController.text = customer.phoneNumber;
                      _nationalIdController.text = customer.nationalId ?? '';
                      _passportNumberController.text = customer.passportNumber ?? '';
                      _addressController.text = customer.address ?? '';
                      _selectedGender = customer.gender;
                      _selectedDateOfBirth = customer.dateOfBirth;
                      _errorMessage = null; // مسح رسائل الخطأ
                    });
                  },
                ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    _buildTextField(
                        controller: _firstNameController,
                        label: 'الاسم الأول',
                        icon: Icons.person,
                        enabled: _isEditing),
                    _buildTextField(
                        controller: _lastNameController,
                        label: 'اسم العائلة',
                        icon: Icons.person_outline,
                        enabled: _isEditing),
                    _buildTextField(
                        controller: _emailController,
                        label: 'البريد الإلكتروني',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        enabled: _isEditing),
                    _buildTextField(
                        controller: _phoneNumberController,
                        label: 'رقم الهاتف',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        enabled: _isEditing),
                    _buildTextField(
                        controller: _nationalIdController,
                        label: 'رقم الهوية الوطنية',
                        icon: Icons.credit_card,
                        enabled: _isEditing),
                    _buildTextField(
                        controller: _passportNumberController,
                        label: 'رقم الجواز',
                        icon: Icons.badge,
                        enabled: _isEditing),
                    _buildDatePickerField(context),
                    _buildGenderDropdown(),
                    _buildTextField(
                        controller: _addressController,
                        label: 'العنوان',
                        icon: Icons.home,
                        maxLines: 3,
                        enabled: _isEditing),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey[200],
        ),
        keyboardType: keyboardType,
        enabled: enabled,
        maxLines: maxLines,
        validator: (value) {
          if (label.contains('الاسم') && (value == null || value.isEmpty)) {
            return 'الرجاء إدخال $label';
          }
          if (label.contains('البريد الإلكتروني') && value != null && value.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'الرجاء إدخال بريد إلكتروني صالح';
          }
          if (label.contains('رقم الهاتف') && (value == null || value.isEmpty)) {
            return 'الرجاء إدخال رقم الهاتف';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: _isEditing ? () => _selectDate(context) : null,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'تاريخ الميلاد',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.calendar_today),
            filled: !_isEditing,
            fillColor: _isEditing ? null : Colors.grey[200],
          ),
          child: Text(
            _selectedDateOfBirth == null
                ? 'اختر تاريخ الميلاد'
                : DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!),
            style: TextStyle(
              color: _selectedDateOfBirth == null ? Colors.grey[700] : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'الجنس',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.person_pin),
          filled: !_isEditing,
          fillColor: _isEditing ? null : Colors.grey[200],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedGender,
            hint: const Text('اختر الجنس'),
            isExpanded: true,
            onChanged: _isEditing ? (String? newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            } : null,
            items: <String>['male', 'female']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value == 'male' ? 'ذكر' : 'أنثى'),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}