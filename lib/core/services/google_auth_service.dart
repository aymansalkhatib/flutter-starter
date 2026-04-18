import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';

import '../utils/app_logger.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GoogleAuthService
// ─────────────────────────────────────────────────────────────────────────────

/// Manages Google Sign-In authentication for the application.
///
/// Usage:
/// ```dart
/// await GoogleAuthService().initialize();
///
/// final account = await GoogleAuthService().signIn();
/// final auth   = await GoogleAuthService().getServerAuth();
/// await        GoogleAuthService().signOut();
/// ```
class GoogleAuthService {
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();
  static final GoogleAuthService _instance = GoogleAuthService._internal();

  static const List<String> _scopes = ['openid', 'email', 'profile'];

  bool _initialized = false;
  GoogleSignInAccount? _currentUser;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSub;

  bool get isInitialized => _initialized;
  GoogleSignInAccount? get currentUser => _currentUser;

  // ─── Initialization ────────────────────────────────────────────────────────

  /// Initializes Google Sign-In.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  ///
  /// Set [attemptSilentSignIn] to `true` to silently restore the last session
  /// on startup.
  Future<void> initialize({
    required String clientId,
    required String serverClientId,
    String? hostedDomain,
    bool attemptSilentSignIn = false,
  }) async {
    if (_initialized) {
      return;
    }

    await GoogleSignIn.instance.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
      hostedDomain: hostedDomain,
    );

    _authSub = GoogleSignIn.instance.authenticationEvents.listen(
      _onAuthEvent,
      onError: (Object e) {
        AppLogger.info(
          'Auth event error: $e',
          tag: 'GoogleAuthService',
        );
      },
    );

    _initialized = true;
    AppLogger.info('GoogleAuthService initialized', tag: 'GoogleAuthService');

    if (attemptSilentSignIn) {
      await silentSignIn();
    }
  }

  // ─── Sign In ───────────────────────────────────────────────────────────────

  /// Attempts to restore the previous session without user interaction.
  ///
  /// Returns `null` if no previous session exists or if silent auth fails.
  Future<GoogleSignInAccount?> silentSignIn() async {
    _ensureInitialized();
    try {
      final account =
          await GoogleSignIn.instance.attemptLightweightAuthentication();
      return account;
    } catch (e) {
      AppLogger.info(
        'Silent sign-in failed: $e',
        tag: 'GoogleAuthService',
      );
      return null;
    }
  }

  /// Opens the Google sign-in UI and returns the signed-in account.
  ///
  /// Throws [UnsupportedError] if the platform does not support interactive
  /// sign-in.
  Future<GoogleSignInAccount?> signIn() async {
    _ensureInitialized();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError(
        'Interactive sign-in is not supported on this platform.',
      );
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      AppLogger.info(
        'Signed in: ${account.email}',
        tag: 'GoogleAuthService',
      );
      return account;
    } catch (e) {
      AppLogger.error('Sign-in failed', tag: 'GoogleAuthService', error: e);
      rethrow;
    }
  }

  // ─── Sign Out ──────────────────────────────────────────────────────────────

  /// Signs out the current user (clears local session).
  Future<void> signOut() async {
    if (!_initialized) {
      return;
    }
    await GoogleSignIn.instance.signOut();
    AppLogger.info('User signed out', tag: 'GoogleAuthService');
  }

  /// Revokes all granted scopes and signs out (full disconnect).
  Future<void> disconnect() async {
    if (!_initialized) {
      return;
    }
    await GoogleSignIn.instance.disconnect();
    AppLogger.info('User disconnected', tag: 'GoogleAuthService');
  }

  // ─── Server Auth ───────────────────────────────────────────────────────────

  /// Returns the server authorization code required for backend token exchange.
  ///
  /// Must be called after a successful [signIn].
  Future<GoogleSignInServerAuthorization> getServerAuth() async {
    _ensureInitialized();
    if (_currentUser == null) {
      throw StateError('No signed-in user. Call signIn() first.');
    }
    try {
      final auth =
          await _currentUser!.authorizationClient.authorizeServer(_scopes);
      if (auth == null) {
        throw StateError('Server authorization returned null.');
      }
      return auth;
    } catch (e) {
      AppLogger.info(
        'Failed to get server auth: $e',
        tag: 'GoogleAuthService',
      );
      rethrow;
    }
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  /// Cancels the auth event listener and resets the service so [initialize]
  /// can be called again.
  Future<void> dispose() async {
    await _authSub?.cancel();
    _authSub = null;
    _currentUser = null;
    _initialized = false;
  }

  // ─── Internal ──────────────────────────────────────────────────────────────

  void _onAuthEvent(GoogleSignInAuthenticationEvent event) {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      _currentUser = event.user;
      AppLogger.info(
        'Auth event: signed in as ${event.user.email}',
        tag: 'GoogleAuthService',
      );
    } else if (event is GoogleSignInAuthenticationEventSignOut) {
      _currentUser = null;
      AppLogger.info('Auth event: signed out', tag: 'GoogleAuthService');
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'GoogleAuthService not initialized. Call initialize() first.',
      );
    }
  }
}
