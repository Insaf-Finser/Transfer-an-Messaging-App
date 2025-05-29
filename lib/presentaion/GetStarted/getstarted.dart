import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transfer/presentaion/GetStarted/verifyotp.dart';
import 'package:transfer/services/auth/auth.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _translateAnimation;

  String selectedCountryCode = '+1';
  final TextEditingController phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  // Expanded list of 50 countries with flags and codes
  final List<Map<String, String>> countries = [
    {'name': 'United States', 'code': '+1', 'flag': '🇺🇸'},
    {'name': 'United Kingdom', 'code': '+44', 'flag': '🇬🇧'},
    {'name': 'India', 'code': '+91', 'flag': '🇮🇳'},
    {'name': 'Canada', 'code': '+1', 'flag': '🇨🇦'},
    {'name': 'Australia', 'code': '+61', 'flag': '🇦🇺'},
    {'name': 'Germany', 'code': '+49', 'flag': '🇩🇪'},
    {'name': 'France', 'code': '+33', 'flag': '🇫🇷'},
    {'name': 'Japan', 'code': '+81', 'flag': '🇯🇵'},
    {'name': 'China', 'code': '+86', 'flag': '🇨🇳'},
    {'name': 'Brazil', 'code': '+55', 'flag': '🇧🇷'},
    {'name': 'Italy', 'code': '+39', 'flag': '🇮🇹'},
    {'name': 'Spain', 'code': '+34', 'flag': '🇪🇸'},
    {'name': 'Russia', 'code': '+7', 'flag': '🇷🇺'},
    {'name': 'South Korea', 'code': '+82', 'flag': '🇰🇷'},
    {'name': 'Mexico', 'code': '+52', 'flag': '🇲🇽'},
    {'name': 'Indonesia', 'code': '+62', 'flag': '🇮🇩'},
    {'name': 'Netherlands', 'code': '+31', 'flag': '🇳🇱'},
    {'name': 'Turkey', 'code': '+90', 'flag': '🇹🇷'},
    {'name': 'Saudi Arabia', 'code': '+966', 'flag': '🇸🇦'},
    {'name': 'Switzerland', 'code': '+41', 'flag': '🇨🇭'},
    {'name': 'Argentina', 'code': '+54', 'flag': '🇦🇷'},
    {'name': 'Sweden', 'code': '+46', 'flag': '🇸🇪'},
    {'name': 'Nigeria', 'code': '+234', 'flag': '🇳🇬'},
    {'name': 'Poland', 'code': '+48', 'flag': '🇵🇱'},
    {'name': 'Belgium', 'code': '+32', 'flag': '🇧🇪'},
    {'name': 'Thailand', 'code': '+66', 'flag': '🇹🇭'},
    {'name': 'Austria', 'code': '+43', 'flag': '🇦🇹'},
    {'name': 'Norway', 'code': '+47', 'flag': '🇳🇴'},
    {'name': 'United Arab Emirates', 'code': '+971', 'flag': '🇦🇪'},
    {'name': 'Israel', 'code': '+972', 'flag': '🇮🇱'},
    {'name': 'Singapore', 'code': '+65', 'flag': '🇸🇬'},
    {'name': 'Malaysia', 'code': '+60', 'flag': '🇲🇾'},
    {'name': 'South Africa', 'code': '+27', 'flag': '🇿🇦'},
    {'name': 'Denmark', 'code': '+45', 'flag': '🇩🇰'},
    {'name': 'Philippines', 'code': '+63', 'flag': '🇵🇭'},
    {'name': 'Hong Kong', 'code': '+852', 'flag': '🇭🇰'},
    {'name': 'Egypt', 'code': '+20', 'flag': '🇪🇬'},
    {'name': 'Greece', 'code': '+30', 'flag': '🇬🇷'},
    {'name': 'Ireland', 'code': '+353', 'flag': '🇮🇪'},
    {'name': 'Portugal', 'code': '+351', 'flag': '🇵🇹'},
    {'name': 'Finland', 'code': '+358', 'flag': '🇫🇮'},
    {'name': 'Vietnam', 'code': '+84', 'flag': '🇻🇳'},
    {'name': 'Pakistan', 'code': '+92', 'flag': '🇵🇰'},
    {'name': 'Czech Republic', 'code': '+420', 'flag': '🇨🇿'},
    {'name': 'Romania', 'code': '+40', 'flag': '🇷🇴'},
    {'name': 'New Zealand', 'code': '+64', 'flag': '🇳🇿'},
    {'name': 'Bangladesh', 'code': '+880', 'flag': '🇧🇩'},
    {'name': 'Chile', 'code': '+56', 'flag': '🇨🇱'},
    {'name': 'Colombia', 'code': '+57', 'flag': '🇨🇴'},
    {'name': 'Peru', 'code': '+51', 'flag': '🇵🇪'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );
    _translateAnimation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  String _getHintText() {
    final country = countries.firstWhere(
      (c) => c['code'] == selectedCountryCode,
      orElse: () => countries.first,
    );
    
    switch (country['name']) {
      case 'India':
        return '12345 67890';
      case 'United Kingdom':
        return '07123 456789';
      case 'United States':
      case 'Canada':
        return '123-456-7890';
      case 'Australia':
        return '0412 345 678';
      case 'Germany':
      case 'France':
        return '0123 456789';
      case 'Japan':
        return '090-1234-5678';
      case 'China':
        return '131 2345 6789';
      default:
        return 'Phone number';
    }
  }

  int _getMaxLength() {
    final country = countries.firstWhere(
      (c) => c['code'] == selectedCountryCode,
      orElse: () => countries.first,
    );
    
    switch (country['name']) {
      case 'India':
        return 11; // 10 digits + 1 space
      case 'United Kingdom':
        return 12; // 11 digits + 1 space
      case 'United States':
      case 'Canada':
        return 12; // 10 digits + 2 dashes
      case 'Japan':
        return 13; // 11 digits + 2 dashes
      default:
        return 15;
    }
  }

  String _formatPhoneNumber(String digits) {
    final country = countries.firstWhere(
      (c) => c['code'] == selectedCountryCode,
      orElse: () => countries.first,
    );
    
    switch (country['name']) {
      case 'India':
        if (digits.length > 5) {
          return '${digits.substring(0, 5)} ${digits.substring(5)}';
        }
        break;
      case 'United Kingdom':
        if (digits.length > 5) {
          return '${digits.substring(0, 5)} ${digits.substring(5)}';
        }
        break;
      case 'United States':
      case 'Canada':
        if (digits.length > 6) {
          return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
        } else if (digits.length > 3) {
          return '${digits.substring(0, 3)}-${digits.substring(3)}';
        }
        break;
      case 'Japan':
        if (digits.length > 7) {
          return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
        } else if (digits.length > 3) {
          return '${digits.substring(0, 3)}-${digits.substring(3)}';
        }
        break;
    }
    return digits;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _translateAnimation.value),
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your phone number to continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _phoneFocusNode.hasFocus 
                                ? Colors.black 
                                : Colors.grey[300]!,
                            width: _phoneFocusNode.hasFocus ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // Country Code Dropdown
                            GestureDetector(
                              onTap: () {
                                _showCountryCodePicker();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      countries.firstWhere(
                                        (c) => c['code'] == selectedCountryCode,
                                      )['flag']!,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      selectedCountryCode,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_drop_down,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Phone Number Input
                            Expanded(
                              child: TextField(
                                controller: phoneController,
                                focusNode: _phoneFocusNode,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: _getHintText(),
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9\s-]'),
                                  ),
                                  LengthLimitingTextInputFormatter(_getMaxLength()),
                                  TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                      String digits = newValue.text.replaceAll(
                                        RegExp(r'\D'),
                                        '',
                                      );
                                      String formatted = _formatPhoneNumber(digits);
                                      return TextEditingValue(
                                        text: formatted,
                                        selection: TextSelection.collapsed(
                                          offset: formatted.length,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 150),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            String phoneNumber = phoneController.text.trim();
                            if (phoneNumber.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter your phone number.'),
                                ),
                              );
                              return;
                            }
                            // Here you would typically send the phone number to your backend
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sending code to $selectedCountryCode$phoneNumber'),
                              ),
                            );
                            // call the sendOTP method from your AuthServices
                            final result = await AuthService().sendOTP('$selectedCountryCode$phoneNumber');
                            if (result.success && result.verificationId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerifyOtpPage(
                                    verificationId: result.verificationId!,
                                    phoneNumber: phoneNumber,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result.error ?? 'Failed to send OTP')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      
                      
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Country',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search country...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        // Implement search functionality if needed
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final country = countries[index];
                    return ListTile(
                      leading: Text(
                        country['flag']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        country['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        country['code']!,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedCountryCode = country['code']!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}