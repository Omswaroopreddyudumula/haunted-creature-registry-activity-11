import 'package:flutter/material.dart';

import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _dateController = TextEditingController();
  DateTime? _birthDate;
  String? _selectedCreatureType;
  bool _obscurePassword = true;
  bool _submitting = false;
  static const creatures = [
    'Ghost',
    'Bat',
    'Black Cat',
    'Pumpkin Spirit',
    'Witch',
  ];

  static const _category = 'password_help';
  static const _tips = <String>[
    'Use a long password that you do not use for another account.',
    'A few unrelated words can make a password easier to remember.',
    'Avoid using your name or birthday in your password.',
  ];
  int _nextTip = 0;
  bool _loadingTip = false;
  String? _tip;

  @override
  void dispose() {
    _dateController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_submitting) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    final creature = _selectedCreatureType!;
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SuccessScreen(userName: name, creatureType: creature),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2008),
      firstDate: DateTime(1920),
      lastDate: DateUtils.dateOnly(DateTime.now()),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _birthDate = picked;
      _dateController.text = '${picked.month}/${picked.day}/${picked.year}';
    });
  }

  Future<void> _getTip() async {
    if (_loadingTip) return;
    setState(() => _loadingTip = true);
    // This delay only simulates work; no network service is called.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _tip = _tips[_nextTip];
      _nextTip = (_nextTip + 1) % _tips.length;
      _loadingTip = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Enchanted Signup Lab')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AbsorbPointer(
              absorbing: _submitting,
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.cookie, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      'Sign the midnight guest book.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose a creature to share your haunted snack break.',
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('name'),
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter your full name.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Please enter your email address.';
                        }
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(email)) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('password'),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _signUp(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          key: const Key('visibility'),
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a password.';
                        }
                        if (value.length < 6) {
                          return 'Use at least six characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: const Key('creature'),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Creature Type',
                        prefixIcon: Icon(Icons.pets),
                      ),
                      items: creatures
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCreatureType = value),
                      validator: (value) =>
                          value == null ? 'Choose your creature type.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('birth-date'),
                      controller: _dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Birth Date',
                        prefixIcon: Icon(Icons.cake),
                      ),
                      validator: (_) =>
                          _birthDate == null ? 'Pick your birth date' : null,
                      onTap: _pickBirthDate,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const Key('register'),
                      onPressed: _submitting ? null : _signUp,
                      child: _submitting
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Brewing your invitation…'),
                              ],
                            )
                          : const Text('Register Creature'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Demo only. No account is created and credentials are not saved.',
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Local signup tip simulation',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Category: $_category • Stored tips; no network request.',
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _loadingTip ? null : _getTip,
                      child: Text(
                        _loadingTip ? 'Loading tip…' : 'Get a signup tip',
                      ),
                    ),
                    if (_loadingTip)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (_tip != null)
                      Semantics(
                        liveRegion: true,
                        child: Text(_tip!, key: const Key('signup-tip')),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
