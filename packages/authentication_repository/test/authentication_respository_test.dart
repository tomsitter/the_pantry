import 'package:authentication_repository/authentication_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:cache/cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

const _mockFirebaseUserUid = 'mock-uid';
const _mockFirebaseUserEmail = 'mock-email';

mixin LegacyEquality {
  @override
  bool operator ==(dynamic other) => false;

  @override
  int get hashCode => 0;
}

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock
    with LegacyEquality
    implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockCacheClient extends Mock implements CacheClient {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class FakeAuthCredential extends Fake implements firebase_auth.AuthCredential {}

class FakeAuthProvider extends Fake implements AuthProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': const <String, String>{},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      final arguments = call.arguments as Map<String, dynamic>;
      return <String, dynamic>{
        'name': arguments['appName'],
        'options': arguments['options'],
        'pluginConstants': const <String, String>{},
      };
    }

    return null;
  });

  TestWidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  const email = 'test@gmail.com';
  const password = 't0ps3cret42';
  const user = User(
    id: _mockFirebaseUserUid,
    email: _mockFirebaseUserEmail,
    isEmailVerified: false,
  );

  final firebaseUser = MockFirebaseUser();
  when(() => firebaseUser.uid).thenReturn(_mockFirebaseUserUid);
  when(() => firebaseUser.email).thenReturn(_mockFirebaseUserEmail);
  when(() => firebaseUser.emailVerified).thenReturn(false);

  group('Authentication Repository', () {
    late CacheClient cache;
    late firebase_auth.FirebaseAuth firebaseAuth;
    late GoogleSignIn googleSignIn;
    late AuthenticationRepository authRepository;

    setUpAll(() {
      registerFallbackValue(FakeAuthCredential());
      registerFallbackValue(FakeAuthProvider());
    });

    setUp(() {
      cache = MockCacheClient();
      firebaseAuth = MockFirebaseAuth();
      googleSignIn = MockGoogleSignIn();
      authRepository = AuthenticationRepository(
        cache: cache,
        firebaseAuth: firebaseAuth,
        googleSignIn: googleSignIn,
      );
    });

    test('Creates AuthenticationRepository internally when not injected', () {
      expect(AuthenticationRepository.new, isNot(throwsException));
    });

    group('Sign up with email and password', () {
      setUp(() {
        when(
          () => firebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')),
        ).thenAnswer((_) => Future.value(MockUserCredential()));

        // Mock user
        when(() => firebaseAuth.currentUser).thenReturn(firebaseUser);

        when(() => firebaseUser.sendEmailVerification())
            .thenAnswer((_) => Future.value());
      });

      test('calls createUserWithEmailAndPassword and sendEmailVerification',
          () async {
        await authRepository.signUp(email: email, password: password);
        verify(() => firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password)).called(1);
        verify(() => firebaseUser.sendEmailVerification()).called(1);
      });

      test('completes when createUserWithEmailAndPassword succeeds', () {
        expect(
            authRepository.signUp(email: email, password: password), completes);
      });

      test('throws SignUpwithEmailAndPasswordFailure when signup fails', () {
        when(() => firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password)).thenThrow(Exception());

        expect(authRepository.signUp(email: email, password: password),
            throwsA(isA<SignUpWithEmailAndPasswordFailure>()));
      });
    });

    group('Sign in with email and password', () {
      setUp(() {
        when(() => firebaseAuth.signInWithEmailAndPassword(
                email: email, password: password))
            .thenAnswer((_) => Future.value(MockUserCredential()));
      });

      test('calls signInWithEmailAndPassword', () async {
        await authRepository.loginWithEmailAndPassword(
            email: email, password: password);
        verify(() => firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password)).called(1);
      });

      test('completes when signInWithEmailAndPassword succeeds', () {
        expect(
            authRepository.loginWithEmailAndPassword(
                email: email, password: password),
            completes);
      });

      test('throws LoginWithEmailAndPasswordFailure when login fails', () {
        when(() => firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password)).thenThrow(Exception());
        expect(
            authRepository.loginWithEmailAndPassword(
                email: email, password: password),
            throwsA(isA<LoginWithEmailAndPasswordFailure>()));
      });
    });

    group('signInWithGoogle', () {
      const accessToken = 'access-token';
      const idToken = 'id-token';

      setUp(() {
        final googleSignInAuthentication = MockGoogleSignInAuthentication();
        final googleSignInAccount = MockGoogleSignInAccount();

        when(() => googleSignIn.signIn())
            .thenAnswer((_) async => googleSignInAccount);

        when(() => googleSignInAccount.authentication)
            .thenAnswer((_) async => googleSignInAuthentication);
        when(() => googleSignInAuthentication.accessToken)
            .thenReturn(accessToken);
        when(() => googleSignInAuthentication.idToken).thenReturn(idToken);

        when(() => firebaseAuth.signInWithPopup(any()))
            .thenAnswer((_) => Future.value(MockUserCredential()));
        when(() => firebaseAuth.signInWithCredential(any()))
            .thenAnswer((_) => Future.value(MockUserCredential()));
      });

      test('Calls signIn and signInWithCredential', () async {
        await authRepository.signInWithGoogle();
        verify(() => googleSignIn.signIn()).called(1);
        verify(() => firebaseAuth.signInWithCredential(any())).called(1);
      });

      test(
          'throws LogInWithGoogleFailure and calls signIn authentication, and '
          'signInWithPopup when authCredential is null and kIsWeb is true',
          () async {
        authRepository.isWeb = true;
        await expectLater(() => authRepository.signInWithGoogle(),
            throwsA(isA<LoginWithGoogleFailure>()));
        verifyNever(() => googleSignIn.signIn());
        verify(() => firebaseAuth.signInWithPopup(any())).called(1);
      });

      test(
          'successfully calls signIn authentication, and'
          'signInWithPopup when authCredential is not null and kIsWeb is true',
          () async {
        authRepository.isWeb = true;
        final credential = MockUserCredential();
        when(() => firebaseAuth.signInWithPopup(any()))
            .thenAnswer((_) async => credential);
        when(() => credential.credential).thenReturn(FakeAuthCredential());
        await expectLater(authRepository.signInWithGoogle(), completes);
        verifyNever(() => googleSignIn.signIn());
        verify(() => firebaseAuth.signInWithPopup(any())).called(1);
      });

      test('Succeeds when signIn succeeds', () {
        expect(authRepository.signInWithGoogle(), completes);
      });

      test('throws LoginWithGoogleFailure when exception occurs', () async {
        when(() => firebaseAuth.signInWithCredential(any()))
            .thenThrow(Exception());
        expect(authRepository.signInWithGoogle(),
            throwsA(isA<LoginWithGoogleFailure>()));
      });
    });

    group('logout', () {
      test('calls signout', () async {
        when(() => firebaseAuth.signOut()).thenAnswer((_) async {});
        when(() => googleSignIn.signOut()).thenAnswer((_) async => null);
        await authRepository.signOut();
        verify(() => firebaseAuth.signOut()).called(1);
        verify(() => googleSignIn.signOut()).called(1);
      });

      test('throws LogoutFailure when signOut throws', () async {
        when(() => firebaseAuth.signOut()).thenThrow(Exception());
        expect(authRepository.signOut(), throwsA(isA<LogoutFailure>()));
      });
    });

    group('user', () {
      test('emits User.empty when firebase user is null', () async {
        when(() => firebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(null));
        await expectLater(
          authRepository.user,
          emitsInOrder(const <User>[User.empty]),
        );
      });

      test('emits User when firebase user in not null', () async {
        when(() => firebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(firebaseUser));
        await expectLater(
          authRepository.user,
          emitsInOrder(const <User>[user]),
        );
        verify(() => cache.write(
            key: AuthenticationRepository.userCacheKey, value: user)).called(1);
      });
    });

    group('currentUser', () {
      test('returns User.empty when cached user is null', () {
        when(() => cache.read<User>(key: AuthenticationRepository.userCacheKey))
            .thenReturn(User.empty);
        expect(authRepository.currentUser, equals(User.empty));
      });

      test('returns User when cached user is not null', () async {
        when(
          () => cache.read<User>(key: AuthenticationRepository.userCacheKey),
        ).thenReturn(user);
        expect(authRepository.currentUser, equals(user));
      });
    });
  });
}
