import 'package:birthday_connector/providers/auth_provider.dart';
import 'package:birthday_connector/screens/guest_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredPasswordRepeated = '';
  var _enteredUsername = '';
  DateTime? _selectedBirthDate;

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();
    FocusScope.of(context).unfocus();

    final authNotifier = ref.read(authProvider.notifier);
    if (_isLogin) {
      await authNotifier.signIn(
        email: _enteredEmail,
        password: _enteredPassword,
      );
    } else {
      await authNotifier.signUp(
        email: _enteredEmail,
        password: _enteredPassword,
        username: _enteredUsername,
        birthDate: _selectedBirthDate!,
      );
    }
  }

  void _toggleAuthMode() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLogin = !_isLogin;
      _form.currentState?.reset();
      _selectedBirthDate = null;
      _enteredEmail = '';
      _enteredPassword = '';
      _enteredPasswordRepeated = '';
      _enteredUsername = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            next.errorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    final authState = ref.watch(authProvider);
    final isAuthenticating = authState.isAuthenticating;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/balloons.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            onSaved: (value) => _enteredEmail = value!,
                          ),
                          if (!_isLogin) const SizedBox(height: 16),
                          if (!_isLogin)
                            TextFormField(
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Username must be at least 4 characters';
                                }
                                return null;
                              },
                              onSaved: (value) => _enteredUsername = value!,
                            ),
                          if (!_isLogin) const SizedBox(height: 16),
                          if (!_isLogin)
                            FormField<DateTime>(
                              initialValue: _selectedBirthDate,
                              builder: (fieldState) {
                                return InkWell(
                                  onTap: () async {
                                    final selected = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(2000),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );

                                    if (selected != null) {
                                      fieldState.didChange(selected);
                                      setState(() {
                                        _selectedBirthDate = selected;
                                      });
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Birth Date',
                                      errorText: fieldState.errorText,
                                      prefixIcon:
                                          const Icon(Icons.cake_outlined),
                                      suffixIcon: Icon(
                                        Icons.calendar_today,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      border: const OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      fieldState.value != null
                                          ? "${fieldState.value!.day.toString().padLeft(2, '0')}.${fieldState.value!.month.toString().padLeft(2, '0')}.${fieldState.value!.year}"
                                          : "",
                                      style: TextStyle(
                                        color: fieldState.value != null
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              validator: (value) {
                                if (value == null) {
                                  return "Please select your birth date";
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 8) {
                                return 'Password must be at least 8 characters long';
                              }
                              return null;
                            },
                            onChanged: (value) => _enteredPassword = value,
                            onSaved: (value) => _enteredPassword = value!,
                          ),
                          if (!_isLogin) const SizedBox(height: 16),
                          if (!_isLogin)
                            TextFormField(
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Repeat Password',
                                prefixIcon: Icon(Icons.lock_outline),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value != _enteredPassword) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 24),
                          if (isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!isAuthenticating)
                            FilledButton(
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: Text(
                                _isLogin ? 'Login' : 'Sign Up',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (!isAuthenticating)
                            TextButton(
                              onPressed: _toggleAuthMode,
                              child: Text(
                                _isLogin
                                    ? 'Create an account'
                                    : 'I already have an account',
                              ),
                            ),
                          if (!isAuthenticating && _isLogin) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const GuestHomeScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              icon: const Icon(Icons.person_outline),
                              label: const Text(
                                'Continue as Guest',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
