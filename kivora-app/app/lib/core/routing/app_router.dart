import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/kivora_service.dart';

// Authentication
import '../../features/authentication/screens/welcome_screen.dart';
import '../../features/authentication/screens/sign_in_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/email_verification_screen.dart';

// Member: Home, Notifications & Quick Actions
import '../../features/home/screens/member_home_screen.dart';
import '../../features/home/screens/notifications_screen.dart';
import '../../features/home/screens/quick_actions_screen.dart';

// Member: Attendance
import '../../features/attendance/screens/check_in_screen.dart';
import '../../features/attendance/screens/verification_result_screen.dart';
import '../../features/attendance/screens/biometric_verification_screen.dart';
import '../../features/attendance/screens/gps_verification_screen.dart';
import '../../features/attendance/screens/attendance_history_screen.dart';
import '../../features/attendance/screens/attendance_record_detail_screen.dart';
import '../../features/attendance/screens/attendance_totals_screen.dart';

// Member: Schedule
import '../../features/schedule/screens/schedule_calendar_screen.dart';

// Member: Organization
import '../../features/organization/screens/class_info_screen.dart';
import '../../features/organization/screens/teaching_assignments_screen.dart';

// Member: Branch
import '../../features/branch/screens/branch_selection_screen.dart';
import '../../features/branch/screens/branch_preview_screen.dart';
import '../../features/branch/screens/join_request_status_screen.dart';
import '../../features/branch/screens/branch_info_screen.dart';
import '../../features/branch/screens/branch_transfer_request_screen.dart';
import '../../features/branch/screens/transfer_history_screen.dart';
import '../../features/branch/screens/request_to_join_screen.dart';

// Member: Profile
import '../../features/profile/screens/member_profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/digital_id_screen.dart';
import '../../features/profile/screens/profile_setup_screen.dart';

// Member: Requests
import '../../features/requests/screens/leave_request_screen.dart';
import '../../features/requests/screens/attendance_correction_screen.dart';
import '../../features/requests/screens/requests_history_screen.dart';

// Member: Settings
import '../../features/settings/screens/app_settings_screen.dart';
import '../../features/settings/screens/security_settings_screen.dart';
import '../../features/settings/screens/device_permissions_screen.dart';
import '../../features/settings/screens/help_and_privacy_screen.dart';

// Manager: Auth & Onboarding
import '../../features/manager/screens/manager_sign_in_screen.dart';
import '../../features/manager/screens/manager_verify_email_screen.dart';
import '../../features/manager/screens/manager_branch_gateway_screen.dart';
import '../../features/manager/screens/create_branch_details_screen.dart';
import '../../features/manager/screens/create_branch_admin_screen.dart';
import '../../features/manager/screens/branch_created_success_screen.dart';

// Manager: Main Screens
import '../../features/manager/screens/manager_dashboard_screen.dart';
import '../../features/manager/screens/manager_members_list_screen.dart';
import '../../features/manager/screens/manager_member_detail_screen.dart';
import '../../features/manager/screens/document_review_screen.dart';
import '../../features/manager/screens/membership_approval_screen.dart';
import '../../features/manager/screens/generate_invite_code_screen.dart';
import '../../features/manager/screens/manager_attendance_logs_screen.dart';
import '../../features/manager/screens/early_leave_requests_screen.dart';
import '../../features/manager/screens/send_announcement_screen.dart';
import '../../features/manager/screens/manager_schedule_management_screen.dart';
import '../../features/manager/screens/manager_reports_screen.dart';
import '../../features/manager/screens/manager_branch_settings_screen.dart';
import '../../features/manager/screens/identification_form_settings_screen.dart';
import '../../features/manager/screens/role_permissions_screen.dart';
import '../../features/manager/screens/verification_logs_screen.dart';
import '../../features/manager/screens/manager_audit_history_screen.dart';
import '../../features/manager/screens/branch_messages_screen.dart';
import '../../features/manager/screens/members_overview_screen.dart';
import '../../features/manager/screens/attendance_overview_screen.dart';

// Manager: BM25–BM27
import '../../features/manager/screens/manager_leave_management_screen.dart';
import '../../features/manager/screens/create_edit_role_screen.dart';
import '../../features/manager/screens/manager_branch_transfer_screen.dart';

// Manager: Extra
import '../../features/manager/screens/manager_settings_screen.dart';
import '../../features/manager/screens/manager_extra_screens.dart';



// ─────────────────────────────────────────────────────────────────
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: KivoraService(),
  redirect: (BuildContext context, GoRouterState state) {
    final path = state.uri.path;
    final kivoraService = KivoraService();

    // 0. Handle authentication loading before making routing decisions.
    // Prevents race conditions during startup or page refresh from triggering premature redirects.
    if (kivoraService.isAuthLoading) {
      return null;
    }

    final isAuth = kivoraService.isAuthenticated;

    // Public auth and landing routes
    final isWelcome = path == '/welcome';
    final isSignInOrRegister = path == '/auth/sign-in' ||
        path == '/sign-in' ||
        path == '/auth/register' ||
        path == '/register' ||
        path == '/manager/sign-in';

    final isPublic = isWelcome || isSignInOrRegister;
    final isVerify = path == '/auth/verify-email' || path == '/manager/verify-email';

    // 1. Unauthenticated users cannot access protected routes
    if (!isAuth) {
      if (path == '/') return '/welcome';
      if (isPublic || isVerify) return null;
      return path.startsWith('/manager') ? '/manager/sign-in' : '/welcome';
    }

    // 2. Authenticated users:
    // If email is not verified, require verification
    if (!kivoraService.isEmailVerified && !isVerify) {
      final emailParam = Uri.encodeComponent(kivoraService.currentUserEmail);
      return '/auth/verify-email?email=$emailParam';
    }

    // 3. Welcome route is intentionally accessible even with an existing session.
    // Do not automatically redirect a user away from /welcome merely because they have an active session.
    if (isWelcome) {
      return null;
    }

    // 4. Root path ('/') or sign-in / registration routes for authenticated users:
    // Route users according to their actual account status and active branch assignment.
    if (path == '/' || isSignInOrRegister) {
      if (kivoraService.isManagerOrAdmin) {
        return '/manager/dashboard';
      }
      if (kivoraService.membershipStatus == 'pending' || kivoraService.membershipStatus == 'rejected') {
        return '/branch/status';
      }
      if (kivoraService.currentRole == 'member' &&
          kivoraService.membershipStatus == 'approved' &&
          kivoraService.currentBranchId != null) {
        return '/member/home';
      }
      return '/branch/gateway';
    }

    // 5. Manager routes authorization:
    final isBranchCreation = path.startsWith('/manager/branch/new') || path == '/manager/branch-gateway';
    if (path.startsWith('/manager') && !isVerify && !isBranchCreation) {
      if (!kivoraService.isManagerOrAdmin) {
        return (kivoraService.membershipStatus == 'approved' && kivoraService.currentBranchId != null)
            ? '/member/home'
            : '/branch/gateway';
      }
    }

    // 6. Member routes authorization:
    if (path.startsWith('/member')) {
      if (kivoraService.membershipStatus == 'pending' || kivoraService.membershipStatus == 'rejected') {
        return '/branch/status';
      }
      if ((kivoraService.currentRole == 'guest' ||
              kivoraService.currentBranchId == null ||
              kivoraService.membershipStatus != 'approved') &&
          path != '/member/branch') {
        return '/branch/gateway';
      }
    }

    return null;
  },
  routes: [
    // ── Root / Welcome / Onboarding ─────────────────────────────
    GoRoute(path: '/', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),

    // ── Member Auth ──────────────────────────────────────────────
    GoRoute(path: '/auth/sign-in', builder: (_, __) => const SignInScreen()),
    GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(
      path: '/auth/verify-email',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final email = extra?['email'] as String? ??
            state.uri.queryParameters['email'] ??
            KivoraService().currentUserEmail;
        final isDemo = extra?['isDemo'] as bool? ?? (!AuthService().isLiveBackendConfigured);
        return EmailVerificationScreen(
          email: email.trim().toLowerCase(),
          isDemoMode: isDemo,
        );
      },
    ),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),

    // ── Branch Selection / Join / Onboarding (BO07–BO10, M05–M08) ──
    GoRoute(path: '/branch/gateway', builder: (_, __) => const ManagerBranchGatewayScreen()),
    GoRoute(path: '/branch/discover', builder: (_, __) => const BranchSelectionScreen()),
    GoRoute(
      path: '/branch/preview',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return BranchPreviewScreen(
          branchId: extra?['branchId'] as String? ?? state.uri.queryParameters['branchId'],
          inviteCode: extra?['inviteCode'] as String? ?? state.uri.queryParameters['inviteCode'],
          inviteCodeId: extra?['inviteCodeId'] as String? ?? state.uri.queryParameters['inviteCodeId'],
        );
      },
    ),
    GoRoute(path: '/branch/join', builder: (_, __) => const RequestToJoinScreen()),
    GoRoute(
      path: '/branch/status',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return JoinRequestStatusScreen(
          branchId: extra?['branchId'] as String?,
          branchName: extra?['branchName'] as String?,
          userName: extra?['userName'] as String?,
        );
      },
    ),

    // ── Profile Setup (M06) ──────────────────────────────────────
    GoRoute(
      path: '/profile/setup',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ProfileSetupScreen(
          branchId: extra?['branchId'] as String?,
          branchName: extra?['branchName'] as String?,
          inviteCode: extra?['inviteCode'] as String?,
          inviteCodeId: extra?['inviteCodeId'] as String? ?? state.uri.queryParameters['inviteCodeId'],
        );
      },
    ),

    // ── Member Home (M09) ────────────────────────────────────────
    GoRoute(path: '/member/home', builder: (_, __) => const MemberHomeScreen()),

    // ── Member Attendance (M12–M21) ──────────────────────────────
    GoRoute(path: '/member/attendance/check-in', builder: (_, __) => const CheckInScreen()),
    GoRoute(path: '/member/attendance/biometric', builder: (_, __) => const BiometricVerificationScreen()),
    GoRoute(path: '/member/attendance/gps', builder: (_, __) => const GpsVerificationScreen()),
    GoRoute(
      path: '/member/attendance/result',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return VerificationResultScreen(
          isSuccess: extra['isSuccess'] ?? true,
          status: extra['status'] ?? 'PASSED',
        );
      },
    ),
    GoRoute(path: '/member/attendance/history', builder: (_, __) => const AttendanceHistoryScreen()),
    GoRoute(path: '/member/attendance/records/:id', builder: (_, __) => const AttendanceRecordDetailScreen()),
    GoRoute(path: '/member/attendance/totals', builder: (_, __) => const AttendanceTotalsScreen()),

    // ── Member Schedule (M20) ────────────────────────────────────
    GoRoute(path: '/member/schedule', builder: (_, __) => const ScheduleCalendarScreen()),

    // ── Member Organization (M23–M24) ────────────────────────────
    GoRoute(path: '/member/classes/:id', builder: (_, __) => const ClassInfoScreen()),
    GoRoute(path: '/member/department', builder: (_, __) => const TeachingAssignmentsScreen()),

    // ── Member Branch Info (M25) ─────────────────────────────────
    GoRoute(
      path: '/member/branch',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final branchId = extra?['branchId'] as String? ??
            state.uri.queryParameters['branchId'] ??
            KivoraService().currentBranchId;
        return BranchInfoScreen(branchId: branchId);
      },
    ),
    GoRoute(
      path: '/branch/info',
      redirect: (_, state) {
        final id = state.uri.queryParameters['branchId'];
        return id != null ? '/member/branch?branchId=$id' : '/member/branch';
      },
    ),

    // ── Member Digital ID (M22) ──────────────────────────────────
    GoRoute(path: '/member/digital-id', builder: (_, __) => const DigitalIdScreen()),

    // ── Member Requests (M26–M28) ────────────────────────────────
    GoRoute(path: '/member/requests/leave/new', builder: (_, __) => const LeaveRequestScreen()),
    GoRoute(path: '/member/requests/correction/new', builder: (_, __) => const AttendanceCorrectionScreen()),
    GoRoute(path: '/member/requests', builder: (_, __) => const RequestsHistoryScreen()),

    // ── Member Profile (M29–M30) ─────────────────────────────────
    GoRoute(path: '/member/profile', builder: (_, __) => const MemberProfileScreen()),
    GoRoute(path: '/member/profile/edit', builder: (_, __) => const EditProfileScreen()),

    // ── Member Transfer (M31–M32) ────────────────────────────────
    GoRoute(path: '/member/transfer/new', builder: (_, __) => const BranchTransferRequestScreen()),
    GoRoute(path: '/member/transfer/history', builder: (_, __) => const TransferHistoryScreen()),

    // ── Member Settings (M33–M36) ────────────────────────────────
    GoRoute(path: '/member/settings', builder: (_, __) => const AppSettingsScreen()),
    GoRoute(path: '/member/settings/security', builder: (_, __) => const SecuritySettingsScreen()),
    GoRoute(path: '/member/settings/permissions', builder: (_, __) => const DevicePermissionsScreen()),
    GoRoute(path: '/member/settings/help', builder: (_, __) => const HelpAndPrivacyScreen()),

    // ── Quick Actions & Notifications (M10–M11) ──────────────────
    GoRoute(path: '/member/notifications', builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/member/search', builder: (_, __) => const QuickActionsScreen()),

    // ── Manager Auth & Branch Creation (BM01–BM06 / BO01–BO06) ──
    GoRoute(path: '/manager/sign-in', builder: (_, __) => const ManagerSignInScreen()),
    GoRoute(
      path: '/manager/verify-email',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final rawEmail = extra?['email'] as String? ??
            state.uri.queryParameters['email'] ??
            KivoraService().currentUserEmail;
        final email = rawEmail.trim();
        // Guard: if email cannot be resolved, send back to sign-in.
        // Do NOT substitute a dummy placeholder address.
        if (email.isEmpty) {
          return const ManagerSignInScreen();
        }
        return ManagerVerifyEmailScreen(email: email);
      },
    ),
    GoRoute(
      path: '/manager/branch/new',
      builder: (_, state) => CreateBranchDetailsScreen(initialData: state.extra as Map<String, dynamic>?),
    ),
    GoRoute(
      path: '/manager/branch/new/admin',
      builder: (_, state) => CreateBranchAdminScreen(branchData: state.extra as Map<String, dynamic>?),
    ),
    GoRoute(
      path: '/manager/branch/new/success',
      builder: (_, state) => BranchCreatedSuccessScreen(branchData: state.extra as Map<String, dynamic>?),
    ),

    // ── Manager Dashboard (BM07) ─────────────────────────────────
    GoRoute(path: '/manager/dashboard', builder: (_, __) => const ManagerDashboardScreen()),

    // ── Manager Members (BM08–BM12) ──────────────────────────────
    GoRoute(path: '/manager/members', builder: (_, __) => const ManagerMembersListScreen()),
    GoRoute(path: '/manager/members/overview', builder: (_, __) => const MembersOverviewScreen()),
    GoRoute(path: '/manager/members/:id', builder: (_, __) => const ManagerMemberDetailScreen()),
    GoRoute(path: '/manager/members/:id/documents', builder: (_, __) => const DocumentReviewScreen()),
    GoRoute(path: '/manager/requests/membership', builder: (_, __) => const MembershipApprovalScreen()),
    GoRoute(
      path: '/manager/invites/generate',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final branchId = extra?['branchId'] as String? ?? state.uri.queryParameters['branchId'];
        return GenerateInviteCodeScreen(branchId: branchId);
      },
    ),

    // ── Manager Attendance (BM13–BM14, BM24) ─────────────────────
    GoRoute(path: '/manager/attendance/logs', builder: (_, __) => const ManagerAttendanceLogsScreen()),
    GoRoute(path: '/manager/attendance/overview', builder: (_, __) => const AttendanceOverviewScreen()),
    GoRoute(path: '/manager/requests/early-leave', builder: (_, __) => const EarlyLeaveRequestsScreen()),

    // ── Manager Communication (BM15, BM22) ───────────────────────
    GoRoute(path: '/manager/announcements/new', builder: (_, __) => const SendAnnouncementScreen()),
    GoRoute(path: '/manager/messages', builder: (_, __) => const BranchMessagesScreen()),

    // ── Manager Schedules (BM16) ─────────────────────────────────
    GoRoute(path: '/manager/schedules', builder: (_, __) => const ManagerScheduleManagementScreen()),

    // ── Manager Reports (BM17) ───────────────────────────────────
    GoRoute(path: '/manager/reports', builder: (_, __) => const ManagerReportsScreen()),

    // ── Manager Settings & Roles (BM18–BM19) ─────────────────────
    GoRoute(path: '/manager/settings/branch', builder: (_, __) => const ManagerBranchSettingsScreen()),
    GoRoute(
      path: '/manager/settings/id-form',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return IdentificationFormSettingsScreen(
          branchId: extra['branchId'] as String? ?? KivoraService().currentBranchId,
        );
      },
    ),
    GoRoute(path: '/manager/settings/roles', builder: (_, __) => const RolePermissionsScreen()),

    // ── Manager Logs (BM20–BM21) ─────────────────────────────────
    GoRoute(path: '/manager/logs/verification', builder: (_, __) => const VerificationLogsScreen()),
    GoRoute(path: '/manager/logs/audit', builder: (_, __) => const ManagerAuditHistoryScreen()),

    // ── Manager Leave, Roles & Transfers (BM25–BM27) ─────────────
    GoRoute(path: '/manager/requests/leave', builder: (_, __) => const ManagerLeaveManagementScreen()),
    GoRoute(path: '/manager/roles/edit', builder: (_, __) => const CreateEditRoleScreen()),
    GoRoute(path: '/manager/requests/transfers', builder: (_, __) => const ManagerBranchTransferScreen()),

    // ── Manager Extra ─────────────────────────────────────────────
    GoRoute(path: '/manager/settings', builder: (_, __) => const ManagerSettingsScreen()),
    GoRoute(path: '/manager/support', builder: (_, __) => const ManagerSupportScreen()),
    GoRoute(path: '/manager/privacy', builder: (_, __) => const ManagerPrivacyScreen()),
    GoRoute(path: '/manager/about', builder: (_, __) => const ManagerAboutScreen()),
    GoRoute(path: '/manager/permissions', builder: (_, __) => const ManagerPermissionsScreen()),
  ],
);
