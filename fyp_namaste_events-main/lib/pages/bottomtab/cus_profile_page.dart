import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roopkatha/UI/pages/customer/bottomtab/favourite.dart';
import '../../service/auth_service.dart';
import '../../welcome_page.dart';
import '../customer_shared_preferences.dart';
import '../login_page.dart';
import '../profile/editProfile.dart';
import '../profile/change_password_page.dart';
import 'bottomtab.dart';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({Key? key}) : super(key: key);

  @override
  State<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _customerName = '';
  String _customerPhone = '';
  String _profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchCustomerData();
  }

  Future<void> _fetchCustomerData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _customerName = await CustomerSharedPreferences.getCustomerName() ?? '';
      _customerPhone = await CustomerSharedPreferences.getCustomerNumber() ?? '';
      _profilePictureUrl = await CustomerSharedPreferences.getProfilePictureUrl() ?? '';

      print('Fetched customer name: $_customerName');
      print('Fetched customer phone: $_customerPhone');
      print('Fetched profile image URL: $_profilePictureUrl');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load customer data')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _authService.logoutCustomer();

    setState(() {
      _isLoading = false;
    });

    if (response.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout successful!')),
      );
      await CustomerSharedPreferences.clearCustomerPreferences();
      Get.offAll(() => const WelcomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey[300], // Bottom border
            ),
            const SizedBox(height: 16), // Spacing after border
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 65,
                backgroundImage: _profilePictureUrl.startsWith('http')
                    ? NetworkImage(_profilePictureUrl)
                    : AssetImage(_profilePictureUrl) as ImageProvider,
              ),
              Positioned(
                bottom: 8,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const EditProfilePage());
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF23242C),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _customerName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF23242C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _customerPhone,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8D8D8D),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: [
                _buildProfileOption(
                  Icons.person_outline,
                  'Edit Profile',
                  () {
                    Get.to(() => const EditProfilePage());
                  },
                ),
                _divider(),
                _buildProfileOption(
                  Icons.favorite_border,
                  'Favourite',
                  () {
                    Get.to(() => const Favourite());
                  },
                ),
                _divider(),
                _buildProfileOption(
                  Icons.lock_outline,
                  'Change password',
                  () {
                    Get.to(() => const ChangePasswordPage());
                  },
                ),
                _divider(),
                _buildProfileOption(
                  Icons.logout,
                  'Log Out',
                  () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => Container(
                        margin: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Logout",
                              style: TextStyle(
                                color: Color(0xFFFF6FCA),
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 1,
                              color: Color(0xFFE5E5E5),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              "Are you sure you want to log out?",
                              style: TextStyle(
                                color: Color(0xFF8D8D8D),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFF2F2F2),
                                      shape: StadiumBorder(),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Color(0xFFFF6FCA),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFF6FCA),
                                      shape: StadiumBorder(),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _logout();
                                    },
                                    child: const Text(
                                      "Yes, Logout",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CusBottomTabs(currentIndex: 4),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Color(0xFFE5E5EA),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF8D8D8D)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF23242C),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFD1D1D6)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
