import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:the_pantry/signup/signup.dart';
import 'package:url_launcher/url_launcher.dart';

const String _TermsUrl = 'https://www.tomsitter.com/thepantrytou';
const String _PrivacyUrl =
    'https://www.freeprivacypolicy.com/live/a87e6201-0c54-4e8c-9822-709798dacaeb';

class SignUpForm extends StatelessWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignupState>(
      listener: (context, state) {
        if (state.status.isSubmissionSuccess) {
          Navigator.of(context).pop();
        } else if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Sign Up Failure')),
            );
        }
      },
      child: Align(
          alignment: const Alignment(0, -1 / 3),
          child: Column(mainAxisSize: MainAxisSize.min, children: const [
            _EmailInput(),
            SizedBox(height: 8),
            _PasswordInput(),
            SizedBox(height: 8),
            _ConfirmPasswordInput(),
            SizedBox(height: 8),
            _TermsOfUseCheckbox(),
            SizedBox(height: 8),
            _SignUpButton(),
          ])),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignupState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('signupFormForm_emailInput_textField'),
          onChanged: (email) => context.read<SignUpCubit>().emailChanged(email),
          decoration: InputDecoration(
            labelText: 'email',
            errorText: state.email.invalid ? 'invalid email' : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignupState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('signupForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<SignUpCubit>().passwordChanged(password),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'password',
            errorText: state.password.invalid ? 'invalid password' : null,
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  const _ConfirmPasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignupState>(
      buildWhen: (previous, current) =>
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return TextField(
          key: const Key('signupForm_confirmedPasswordInput_textField'),
          onChanged: (confirmedPassword) => context
              .read<SignUpCubit>()
              .confirmedPasswordChanged(confirmedPassword),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'confirm password',
            errorText: state.password.invalid ? 'passwords do not match' : null,
          ),
        );
      },
    );
  }
}

class _TermsOfUseCheckbox extends StatelessWidget {
  const _TermsOfUseCheckbox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignupState>(
      buildWhen: (previous, current) =>
          previous.agreeToTOU != current.agreeToTOU,
      builder: (context, state) {
        return Row(
          children: [
            Checkbox(
              key: const Key('signupForm_termsOfUse_checkBox'),
              value: context.read<SignUpCubit>().touChecked,
              onChanged: (value) =>
                  context.read<SignUpCubit>().agreeToTOUChanged(value ?? false),
            ),
            Flexible(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: "I have read and accept the "),
                    TextSpan(
                        text: "terms and conditions",
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchURL(_TermsUrl)),
                    TextSpan(text: " and "),
                    TextSpan(
                        text: "privacy policy",
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchURL(_PrivacyUrl)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignupState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('signupForm_submit_raisedButton'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  primary: Colors.orangeAccent,
                ),
                child: const Text('Sign Up'),
                onPressed: state.status.isValidated
                    ? () {
                        context.read<SignUpCubit>().signUpFormSubmitted();
                      }
                    : null);
      },
    );
  }
}
