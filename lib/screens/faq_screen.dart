import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/models.dart';
import '../models/faq_item.dart';
import '../models/feedback_item.dart';
import '../services/services.dart';
import '../utils/utils.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _feedbackFormKey = GlobalKey<FormState>();
  
  // Feedback form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  FeedbackType _selectedType = FeedbackType.general;
  bool _isSubmitting = false;
  
  // FAQ state
  String _selectedCategory = 'Semua';
  final Map<String, bool> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final currentUser = AuthService.getCurrentUser();
    if (currentUser != null) {
      _nameController.text = currentUser.displayName;
      _emailController.text = currentUser.email;
    }
  }

  Future<void> _submitFeedback() async {
    if (_feedbackFormKey.currentState?.validate() != true) return;

    setState(() => _isSubmitting = true);

    try {
      final currentUser = AuthService.getCurrentUser();
      final feedbackId = sha256
          .convert(utf8.encode('${DateTime.now().millisecondsSinceEpoch}'))
          .toString()
          .substring(0, 16);

      final feedback = FeedbackItem(
        id: feedbackId,
        userId: currentUser?.id ?? 'anonymous',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        type: _selectedType,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        createdAt: DateTime.now(),
      );

      // In a real app, this would be sent to a server
      // For now, we'll just simulate saving locally
      await _saveFeedbackLocally(feedback);
      
      _showSuccess('Terima kasih! Feedback Anda telah terkirim dan akan segera ditinjau oleh tim kami.');
      _clearForm();

    } catch (e) {
      _showError('Gagal mengirim feedback: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _saveFeedbackLocally(FeedbackItem feedback) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real implementation, this would save to a feedback box
    // For now, we'll just print it
    print('Feedback saved: ${feedback.toJson()}');
  }

  void _clearForm() {
    _subjectController.clear();
    _messageController.clear();
    setState(() {
      _selectedType = FeedbackType.general;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text(
          'FAQ & Masukan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.darkCard,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(
              icon: Icon(Icons.help_outline),
              text: 'FAQ',
            ),
            Tab(
              icon: Icon(Icons.feedback_outlined),
              text: 'Kirim Masukan',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildFeedbackTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    final categories = ['Semua', ...FAQData.categories];
    final filteredItems = _selectedCategory == 'Semua'
        ? FAQData.items
        : FAQData.getByCategory(_selectedCategory);

    return Column(
      children: [
        // Category Filter
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == _selectedCategory;
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: AppTheme.darkCard,
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.3),
                  ),
                ),
              );
            },
          ),
        ),
        
        // FAQ List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final key = '${item.category}_$index';
              final isExpanded = _expandedItems[key] ?? false;
              
              return Card(
                color: AppTheme.darkCard,
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  key: Key(key),
                  title: Text(
                    item.question,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    item.category,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.primaryColor,
                  ),
                  iconColor: AppTheme.primaryColor,
                  collapsedIconColor: AppTheme.primaryColor,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expandedItems[key] = expanded;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        item.answer,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _feedbackFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              color: AppTheme.darkCard,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.feedback,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Kirim Masukan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bantu kami meningkatkan Joytify dengan memberikan masukan, melaporkan bug, atau mengusulkan fitur baru.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Feedback Type
            Text(
              'Jenis Masukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: AppTheme.darkCard,
              child: Column(
                children: FeedbackType.values.map((type) {
                  return RadioListTile<FeedbackType>(
                    title: Text(
                      type.displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      type.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    value: type,
                    groupValue: _selectedType,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            _buildTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              icon: Icons.person_outline,
              validator: (value) {
                if (value?.isEmpty == true) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty == true) {
                  return 'Email tidak boleh kosong';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _subjectController,
              label: 'Subjek',
              icon: Icons.subject,
              validator: (value) {
                if (value?.isEmpty == true) {
                  return 'Subjek tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _messageController,
              label: 'Pesan',
              icon: Icons.message_outlined,
              maxLines: 5,
              validator: (value) {
                if (value?.isEmpty == true) {
                  return 'Pesan tidak boleh kosong';
                }
                if (value!.length < 10) {
                  return 'Pesan minimal 10 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Kirim Masukan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Privacy Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Informasi yang Anda berikan akan dijaga kerahasiaannya sesuai Kebijakan Privasi kami.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryColor),
            filled: true,
            fillColor: AppTheme.darkCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }
}
