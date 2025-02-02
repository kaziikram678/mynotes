import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider._isInitialized, false);
    });

    test('Cannot logout if not initialized', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Should be able to inistialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should not be null after initilization', () {
      expect(provider.currentUser, null);
    });

    test('Should be initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(const Duration(seconds: 2)));

    // test('Create user should delegate login', () async {
    //   final badEmailUser = await provider.createUser(
    //     email: "nickjam@gmail.com",
    //     password: 'anypass',
    //   );

    //   expect(
    //     badEmailUser,
    //     throwsA(const TypeMatcher<UserNotFoundAuthException>()),
    //   );

    //   final badPassUser = await provider.createUser(
    //     email: "nick@gmail.com",
    //     password: '12345',
    //   );

    //   expect(
    //     badPassUser,
    //     throwsA(const TypeMatcher<InvalidcredentialAuthException>()),
    //   );

    //   final user = await provider.createUser(
    //     email: "nick",
    //     password: '123',
    //   );

    //   expect(provider.currentUser, user);

    //   expect(user.isEmailVerified, false);
    // });

    test('Logged in user should be able to get verified', () async {
      await provider.initialize();

      final user = await provider.createUser(
        email: "nick",
        password: "123",
      );

      expect(provider.currentUser, isNotNull);

      await provider.sendEmailVerification();

      expect(provider.currentUser!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await provider.initialize(); // Ensure provider is initialized

      final user = await provider.createUser(
        email: "nick",
        password: "123",
      );

      expect(provider.currentUser, isNotNull); // Ensure a user exists

      await provider.logOut(); // Log out

      expect(provider.currentUser, isNull); // User should be null after logout

      final loggedInUser = await provider.logIn(
        email: "nick",
        password: "123",
      );

      expect(provider.currentUser, isNotNull); // Ensure user is logged in again
      expect(provider.currentUser, loggedInUser);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }
  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

 @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw InvalidcredentialAuthException();
    var user = AuthUser(
      //id: 'my_id',
      isEmailVerified: false,
      //email: 'foo@bar.com',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    var newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
