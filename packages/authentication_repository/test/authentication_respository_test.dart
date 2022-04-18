import 'package:authentication_repository/authentication_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:cache/cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

const _mockFirebaseUserUid = 'mock-uid';
const _mockFirebaseUserEmail = 'mock-email';

class MockFirebaseAuth  extends Mock implements firebase_auth.FirebaseAuth {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockCacheClient extends Mock implements CacheClient {}
class MockFirebaseUser extends Mock implements firebase_auth.User {}
class MockUserCredential extends Mock implements firebase_auth.UserCredential {}
class FakeAuthCredential extends Fake implements firebase_auth.AuthCredential {}
class FakeAuthProvider extends Fake implements AuthProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == "Firebase#initializeCore") {
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

    if (call.method == "Firebase#initializeApp") {
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
  final mockUser = MockFirebaseUser();

  group('Authentication Repository', () {
    late CacheClient cache;
    late firebase_auth.FirebaseAuth firebaseAuth;
    late GoogleSignIn googleSignIn;
    late AuthenticationRepository authRepository;

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
                email: any(named: 'email'),
                password: any(named: 'password')
            ),
        ).thenAnswer((_) => Future.value(MockUserCredential()));

        // Mock user
        when(
            () => firebaseAuth.currentUser
        ).thenReturn(mockUser);

        when(
            () => mockUser.sendEmailVerification()
        ).thenAnswer((_) => Future.value());

      });

      test('calls createUserWithEmailAndPassword and sendEmailVerification', () async {
        await authRepository.signUp(email: email, password: password);
        verify(() => firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).called(1);
        verify(() => mockUser.sendEmailVerification()).called(1);
      });

      test('completes where createUserWithEmailAndPassword succeeds', () {
        expect(
          authRepository.signUp(email: email, password: password),
          completes
        );
      });

      test('throws SignUpwithEmailAndPasswordFailure when signup fails', () {
        when(() => firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password))
            .thenThrow(Exception());

        expect(
          authRepository.signUp(email: email, password: password),
          throwsA(isA<SignUpWithEmailAndPasswordFailure>())
        );
      });
    });


    group('Sign in with email and password', () {

    });
  });
}