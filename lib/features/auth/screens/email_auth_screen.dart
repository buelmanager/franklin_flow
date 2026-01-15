// lib/features/auth/screens/email_auth_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/styles/app_text_styles.dart';
import '../../../core/utils/app_logger.dart';
import '../services/auth_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Email Auth Screen - 이메일 로그인/회원가입 화면
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Firebase 이메일 인증 화면
/// - 이메일 로그인
/// - 이메일 회원가입
/// - 비밀번호 재설정
///
/// 사용법:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => EmailAuthScreen(onSuccess: () { ... }),
///   ));
/// ═══════════════════════════════════════════════════════════════════════════

class EmailAuthScreen extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const EmailAuthScreen({Key? key, required this.onSuccess}) : super(key: key);

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isSignUp = false; // false: 로그인, true: 회원가입
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    AppLogger.i('EmailAuthScreen initialized', tag: 'EmailAuthScreen');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// 로그인/회원가입 전환
  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
    });
  }

  /// 이메일 유효성 검사
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  /// 비밀번호 유효성 검사
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다';
    }
    return null;
  }

  /// 비밀번호 확인 유효성 검사
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    if (value != _passwordController.text) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  /// 이름 유효성 검사
  String? _validateName(String? value) {
    if (_isSignUp && (value == null || value.isEmpty)) {
      return '이름을 입력해주세요';
    }
    return null;
  }

  /// 로그인 처리
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.i('Starting Email Sign In', tag: 'EmailAuthScreen');

      final authService = AuthService();
      final result = await authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result.success && result.user != null) {
        AppLogger.i(
          'Email Sign In successful: ${result.user!.name}',
          tag: 'EmailAuthScreen',
        );

        // 상태 업데이트
        ref.read(currentUserProvider.notifier).state = result.user;
        ref.read(authStateProvider.notifier).state = AuthState.authenticated;

        // 콜백 호출
        widget.onSuccess();
      } else {
        AppLogger.w(
          'Email Sign In failed: ${result.errorCode}',
          tag: 'EmailAuthScreen',
        );
        setState(() {
          _errorMessage = result.errorMessage;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Email Sign In error',
        tag: 'EmailAuthScreen',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _errorMessage = '로그인 중 오류가 발생했습니다';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 회원가입 처리
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.i('Starting Email Sign Up', tag: 'EmailAuthScreen');

      final authService = AuthService();
      final result = await authService.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _nameController.text,
      );

      if (result.success && result.user != null) {
        AppLogger.i(
          'Email Sign Up successful: ${result.user!.name}',
          tag: 'EmailAuthScreen',
        );

        // 상태 업데이트
        ref.read(currentUserProvider.notifier).state = result.user;
        ref.read(authStateProvider.notifier).state = AuthState.authenticated;

        // 콜백 호출
        widget.onSuccess();
      } else {
        AppLogger.w(
          'Email Sign Up failed: ${result.errorCode}',
          tag: 'EmailAuthScreen',
        );
        setState(() {
          _errorMessage = result.errorMessage;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Email Sign Up error',
        tag: 'EmailAuthScreen',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _errorMessage = '회원가입 중 오류가 발생했습니다';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 비밀번호 재설정
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = '이메일을 입력해주세요';
      });
      return;
    }

    if (_validateEmail(email) != null) {
      setState(() {
        _errorMessage = '올바른 이메일 형식이 아닙니다';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.i('Sending password reset email', tag: 'EmailAuthScreen');

      final authService = AuthService();
      final result = await authService.sendPasswordResetEmail(email);

      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('비밀번호 재설정 이메일을 발송했습니다'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result.errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '비밀번호 재설정 이메일 발송에 실패했습니다';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isSignUp ? '회원가입' : '이메일 로그인',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.spaceL),

                // 에러 메시지
                if (_errorMessage != null) ...[
                  _buildErrorMessage(),
                  const SizedBox(height: AppSizes.spaceL),
                ],

                // 이름 필드 (회원가입 시에만)
                if (_isSignUp) ...[
                  _buildNameField(),
                  const SizedBox(height: AppSizes.spaceM),
                ],

                // 이메일 필드
                _buildEmailField(),
                const SizedBox(height: AppSizes.spaceM),

                // 비밀번호 필드
                _buildPasswordField(),
                const SizedBox(height: AppSizes.spaceM),

                // 비밀번호 확인 필드 (회원가입 시에만)
                if (_isSignUp) ...[
                  _buildConfirmPasswordField(),
                  const SizedBox(height: AppSizes.spaceM),
                ],

                // 비밀번호 찾기 (로그인 시에만)
                if (!_isSignUp) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _handleForgotPassword,
                      child: Text(
                        '비밀번호를 잊으셨나요?',
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.accentBlue,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSizes.spaceL),

                // 로그인/회원가입 버튼
                _buildSubmitButton(),

                const SizedBox(height: AppSizes.spaceL),

                // 모드 전환 버튼
                _buildToggleModeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 에러 메시지
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSizes.spaceS),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTextStyles.bodyS.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// 이름 필드
  Widget _buildNameField() {
    return _buildTextField(
      controller: _nameController,
      label: '이름',
      hint: '이름을 입력하세요',
      prefixIcon: Icons.person_outline,
      validator: _validateName,
      textInputAction: TextInputAction.next,
    );
  }

  /// 이메일 필드
  Widget _buildEmailField() {
    return _buildTextField(
      controller: _emailController,
      label: '이메일',
      hint: 'example@email.com',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
      textInputAction: TextInputAction.next,
    );
  }

  /// 비밀번호 필드
  Widget _buildPasswordField() {
    return _buildTextField(
      controller: _passwordController,
      label: '비밀번호',
      hint: '6자 이상 입력',
      prefixIcon: Icons.lock_outline,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textTertiary,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      validator: _validatePassword,
      textInputAction: _isSignUp ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: _isSignUp ? null : (_) => _handleSignIn(),
    );
  }

  /// 비밀번호 확인 필드
  Widget _buildConfirmPasswordField() {
    return _buildTextField(
      controller: _confirmPasswordController,
      label: '비밀번호 확인',
      hint: '비밀번호를 다시 입력',
      prefixIcon: Icons.lock_outline,
      obscureText: _obscureConfirmPassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textTertiary,
        ),
        onPressed: () {
          setState(() {
            _obscureConfirmPassword = !_obscureConfirmPassword;
          });
        },
      ),
      validator: _validateConfirmPassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSignUp(),
    );
  }

  /// 공통 텍스트 필드 빌더
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelM.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.spaceXS),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyM.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: Icon(prefixIcon, color: AppColors.textTertiary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: AppColors.shadowDark.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(color: AppColors.accentBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingM,
            ),
          ),
        ),
      ],
    );
  }

  /// 제출 버튼
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : (_isSignUp ? _handleSignUp : _handleSignIn),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.accentBlue,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _isSignUp ? '회원가입' : '로그인',
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  /// 모드 전환 버튼
  Widget _buildToggleModeButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? '이미 계정이 있으신가요?' : '계정이 없으신가요?',
          style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: _isLoading ? null : _toggleMode,
          child: Text(
            _isSignUp ? '로그인' : '회원가입',
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.accentBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
