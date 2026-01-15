// lib/features/auth/screens/terms_agreement_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/styles/app_text_styles.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/widgets/neumorphic_container.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Terms Agreement Screen - 이용약관 및 개인정보 처리방침 동의 화면
/// ═══════════════════════════════════════════════════════════════════════════
///
/// 로그인 전 필수 약관 동의를 받는 화면
/// - 서비스 이용약관 (필수)
/// - 개인정보 처리방침 (필수)
/// - 마케팅 정보 수신 동의 (선택)
///
/// 사용법:
///   TermsAgreementScreen(
///     onAgree: () {
///       // 동의 완료 후 처리
///     },
///   )
/// ═══════════════════════════════════════════════════════════════════════════

class TermsAgreementScreen extends StatefulWidget {
  final VoidCallback onAgree;
  final VoidCallback? onCancel;

  const TermsAgreementScreen({Key? key, required this.onAgree, this.onCancel})
    : super(key: key);

  @override
  State<TermsAgreementScreen> createState() => _TermsAgreementScreenState();
}

class _TermsAgreementScreenState extends State<TermsAgreementScreen> {
  // 약관 동의 상태
  bool _agreeAll = false;
  bool _agreeTerms = false; // 서비스 이용약관 (필수)
  bool _agreePrivacy = false; // 개인정보 처리방침 (필수)
  bool _agreeMarketing = false; // 마케팅 정보 수신 (선택)

  /// 모든 필수 약관 동의 여부
  bool get _canProceed => _agreeTerms && _agreePrivacy;

  @override
  void initState() {
    super.initState();
    AppLogger.d(
      'TermsAgreementScreen initialized',
      tag: 'TermsAgreementScreen',
    );
  }

  /// 전체 동의 토글
  void _toggleAgreeAll(bool? value) {
    setState(() {
      _agreeAll = value ?? false;
      _agreeTerms = _agreeAll;
      _agreePrivacy = _agreeAll;
      _agreeMarketing = _agreeAll;
    });
    AppLogger.d('All terms toggled: $_agreeAll', tag: 'TermsAgreementScreen');
  }

  /// 개별 약관 토글
  void _toggleTerms(bool? value) {
    setState(() {
      _agreeTerms = value ?? false;
      _updateAgreeAll();
    });
  }

  void _togglePrivacy(bool? value) {
    setState(() {
      _agreePrivacy = value ?? false;
      _updateAgreeAll();
    });
  }

  void _toggleMarketing(bool? value) {
    setState(() {
      _agreeMarketing = value ?? false;
      _updateAgreeAll();
    });
  }

  /// 전체 동의 상태 업데이트
  void _updateAgreeAll() {
    _agreeAll = _agreeTerms && _agreePrivacy && _agreeMarketing;
  }

  /// 약관 상세 보기
  void _showTermsDetail(String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TermsDetailSheet(title: title, content: content),
    );
  }

  /// 동의하고 계속하기
  void _handleAgree() {
    if (!_canProceed) return;

    AppLogger.i(
      'Terms agreed - terms: $_agreeTerms, privacy: $_agreePrivacy, marketing: $_agreeMarketing',
      tag: 'TermsAgreementScreen',
    );

    widget.onAgree();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          '약관 동의',
          style: AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 안내 문구
                    _buildHeader(),
                    const SizedBox(height: AppSizes.spaceXL),

                    // 전체 동의
                    _buildAgreeAllCard(),
                    const SizedBox(height: AppSizes.spaceL),

                    // 개별 약관
                    _buildTermsCard(),
                  ],
                ),
              ),
            ),

            // 동의 버튼
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  /// 헤더 빌드
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Franklin Flow를\n시작하기 전에',
          style: AppTextStyles.heading2.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        Text(
          '서비스 이용을 위해 아래 약관에 동의해 주세요.',
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// 전체 동의 카드
  Widget _buildAgreeAllCard() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Row(
        children: [
          _buildCheckbox(_agreeAll, _toggleAgreeAll, isMain: true),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Text(
              '전체 동의',
              style: AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// 약관 목록 카드
  Widget _buildTermsCard() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: [
          // 서비스 이용약관 (필수)
          _buildTermsItem(
            title: '서비스 이용약관',
            isRequired: true,
            isChecked: _agreeTerms,
            onChanged: _toggleTerms,
            onDetailTap: () =>
                _showTermsDetail('서비스 이용약관', _termsOfServiceContent),
          ),
          _buildDivider(),

          // 개인정보 처리방침 (필수)
          _buildTermsItem(
            title: '개인정보 처리방침',
            isRequired: true,
            isChecked: _agreePrivacy,
            onChanged: _togglePrivacy,
            onDetailTap: () =>
                _showTermsDetail('개인정보 처리방침', _privacyPolicyContent),
          ),
          _buildDivider(),

          // 마케팅 정보 수신 (선택)
          _buildTermsItem(
            title: '마케팅 정보 수신 동의',
            isRequired: false,
            isChecked: _agreeMarketing,
            onChanged: _toggleMarketing,
            onDetailTap: () =>
                _showTermsDetail('마케팅 정보 수신 동의', _marketingConsentContent),
          ),
        ],
      ),
    );
  }

  /// 약관 항목
  Widget _buildTermsItem({
    required String title,
    required bool isRequired,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
    required VoidCallback onDetailTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: Row(
        children: [
          _buildCheckbox(isChecked, onChanged),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Row(
              children: [
                Text(
                  isRequired ? '[필수] ' : '[선택] ',
                  style: AppTextStyles.bodyS.copyWith(
                    color: isRequired
                        ? AppColors.accentRed
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(child: Text(title, style: AppTextStyles.bodyM)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDetailTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 체크박스
  Widget _buildCheckbox(
    bool value,
    ValueChanged<bool?> onChanged, {
    bool isMain = false,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: isMain ? 28 : 24,
        height: isMain ? 28 : 24,
        decoration: BoxDecoration(
          color: value ? AppColors.accentBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(isMain ? 8 : 6),
          border: Border.all(
            color: value
                ? AppColors.accentBlue
                : AppColors.textTertiary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: value
            ? Icon(Icons.check, color: Colors.white, size: isMain ? 18 : 16)
            : null,
      ),
    );
  }

  /// 구분선
  Widget _buildDivider() {
    return Divider(color: AppColors.textTertiary.withOpacity(0.1), height: 1);
  }

  /// 하단 버튼
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withOpacity(0.1),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: _canProceed ? _handleAgree : null,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: _canProceed
                ? AppColors.accentBlue
                : AppColors.textTertiary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            boxShadow: _canProceed
                ? [
                    BoxShadow(
                      color: AppColors.accentBlue.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '동의하고 계속하기',
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 약관 상세 보기 시트
/// ═══════════════════════════════════════════════════════════════════════════

class _TermsDetailSheet extends StatelessWidget {
  final String title;
  final String content;

  const _TermsDetailSheet({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 핸들 바
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 헤더
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.heading4.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            Divider(color: AppColors.textTertiary.withOpacity(0.1), height: 1),

            // 내용
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Text(
                  content,
                  style: AppTextStyles.bodyM.copyWith(
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 약관 내용 (실제 서비스에서는 서버에서 가져오거나 별도 파일로 관리)
// ═══════════════════════════════════════════════════════════════════════════

const String _termsOfServiceContent = '''
Franklin Flow 서비스 이용약관

제1조 (목적)
본 약관은 Franklin Flow(이하 "서비스")의 이용조건 및 절차, 이용자와 서비스 제공자의 권리, 의무, 책임사항 등 기본적인 사항을 규정함을 목적으로 합니다.

제2조 (용어의 정의)
1. "서비스"란 Franklin Flow가 제공하는 시간 관리 및 생산성 향상 관련 모바일 애플리케이션 서비스를 말합니다.
2. "이용자"란 본 약관에 따라 서비스를 이용하는 회원 및 비회원을 말합니다.
3. "회원"이란 서비스에 개인정보를 제공하여 회원등록을 한 자로서, 서비스의 정보를 지속적으로 제공받으며, 서비스를 계속적으로 이용할 수 있는 자를 말합니다.

제3조 (약관의 효력 및 변경)
1. 본 약관은 서비스 화면에 게시하거나 기타의 방법으로 이용자에게 공지함으로써 효력이 발생합니다.
2. 서비스는 합리적인 사유가 발생할 경우 관련 법령에 위배되지 않는 범위에서 본 약관을 변경할 수 있으며, 약관이 변경된 경우에는 지체없이 이를 공지합니다.

제4조 (서비스의 제공 및 변경)
1. 서비스는 다음과 같은 기능을 제공합니다:
   - 일일 태스크 관리 및 추적
   - 아침/저녁 루틴 알림
   - 집중 세션 타이머
   - 목표 설정 및 진행률 추적
   - 통계 및 분석 기능
2. 서비스는 상당한 이유가 있는 경우 운영상, 기술상의 필요에 따라 제공하고 있는 서비스를 변경할 수 있습니다.

제5조 (서비스의 중단)
1. 서비스는 시스템 정기점검, 증설 및 교체, 통신 장애 등의 이유로 서비스의 제공을 일시적으로 중단할 수 있습니다.
2. 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스의 제공을 제한하거나 중단할 수 있습니다.

제6조 (이용자의 의무)
1. 이용자는 다음 행위를 하여서는 안 됩니다:
   - 신청 또는 변경 시 허위 내용 기재
   - 타인의 정보 도용
   - 서비스에 게시된 정보의 무단 변경
   - 서비스가 정한 정보 이외의 정보(컴퓨터 프로그램 등) 송신 또는 게시
   - 서비스 및 기타 제3자의 저작권 등 지적재산권 침해
   - 서비스 및 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위

제7조 (책임의 제한)
1. 서비스는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 관한 책임이 면제됩니다.
2. 서비스는 이용자의 귀책사유로 인한 서비스 이용의 장애에 대하여 책임을 지지 않습니다.

제8조 (분쟁해결)
1. 서비스와 이용자 간에 발생한 분쟁에 관한 소송은 대한민국 법을 적용합니다.

부칙
본 약관은 2025년 1월 1일부터 시행됩니다.
''';

const String _privacyPolicyContent = '''
Franklin Flow 개인정보 처리방침

1. 개인정보의 수집 및 이용 목적
Franklin Flow는 다음의 목적을 위하여 개인정보를 처리합니다:
- 회원 가입 및 관리
- 서비스 제공 및 운영
- 서비스 개선 및 신규 서비스 개발
- 고객 문의 대응

2. 수집하는 개인정보 항목
- 소셜 로그인 시: 이메일, 이름, 프로필 이미지 (소셜 서비스 제공 정보)
- 서비스 이용 시: 태스크 정보, 목표 정보, 집중 세션 기록, 앱 사용 통계

3. 개인정보의 보유 및 이용 기간
- 회원 탈퇴 시까지 보유
- 관계 법령에 따른 보존 필요가 있는 경우 해당 기간 동안 보존

4. 개인정보의 제3자 제공
Franklin Flow는 이용자의 개인정보를 원칙적으로 제3자에게 제공하지 않습니다. 다만, 다음의 경우에는 예외로 합니다:
- 이용자가 사전에 동의한 경우
- 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우

5. 개인정보의 파기
개인정보 보유기간이 경과하거나 처리목적이 달성된 경우, 지체없이 해당 개인정보를 파기합니다.

6. 개인정보 보호책임자
개인정보 보호에 관한 문의사항은 앱 내 설정 > 문의하기를 통해 연락해 주시기 바랍니다.

7. 개인정보 처리방침의 변경
본 개인정보 처리방침은 법령, 정책 또는 보안기술의 변경에 따라 내용이 추가, 삭제 및 수정될 수 있습니다. 변경 시에는 시행일자 최소 7일 전부터 앱 내 공지사항을 통해 고지합니다.

8. 개인정보의 안전성 확보 조치
Franklin Flow는 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다:
- 개인정보의 암호화
- 해킹 등에 대비한 기술적 대책
- 개인정보에 대한 접근 제한

시행일: 2025년 1월 1일
''';

const String _marketingConsentContent = '''
마케팅 정보 수신 동의

Franklin Flow에서 제공하는 다양한 혜택과 정보를 받아보실 수 있습니다.

1. 수신 정보
- 새로운 기능 및 업데이트 안내
- 생산성 향상 팁 및 콘텐츠
- 이벤트 및 프로모션 정보
- 설문조사 참여 요청

2. 수신 방법
- 푸시 알림
- 이메일

3. 수신 동의 철회
설정 메뉴에서 언제든지 마케팅 정보 수신 동의를 철회하실 수 있습니다.

※ 마케팅 정보 수신에 동의하지 않으셔도 서비스 이용에는 제한이 없습니다.
※ 서비스 관련 중요 공지사항은 마케팅 수신 동의 여부와 관계없이 발송됩니다.
''';
