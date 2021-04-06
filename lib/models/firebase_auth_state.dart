import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:instagram_two_record/repo/user_network_repository.dart';
import 'package:instagram_two_record/utills/simple_snackbar.dart';
import 'package:path/path.dart';

class FirebaseAuthState extends ChangeNotifier {
  //상태변화가 될때마다 이 클래스를 구독하고 있는 위젯들한테 변경을 알려줌 (유저데이터가 변경되니까 디스플레이를 바꿔줘라)
  FirebaseAuthStatus _firebaseAuthStatus = FirebaseAuthStatus.progress;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User _user;
  FacebookLogin _facebookLogin;
  GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  void watchAuthChange() {
    _firebaseAuth.authStateChanges().listen((user) { //firebase User가 변경될때마다 던져줌
      if (user == null && _user == null) { //가지고 있는 유저와 받아온 유저가 모두 널이면
        changeFirebaseAuthStatus();
        return;
      } else if (user != _user) {
        _user = user;
        changeFirebaseAuthStatus();
      }
    });
  }

  void registerUser(BuildContext context,
      {@required String email, @required String password}) async{
    changeFirebaseAuthStatus(FirebaseAuthStatus.progress);
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(
            email: email.trim(), password: password.trim())
        .catchError((error) {
      print('Error $error');
      String _message = "";
      switch (error.code) {
        case 'weak-password':
          _message = "비밀번호를 잘 넣어주세요.";
          break;
        case 'operation-not-allowed':
          _message = "email/password accounts are not enabled";
          break;
        case 'invalid-email':
          _message = "이메일 주소를 확인해주세요.";
          break;
        case 'email-already-in-use':
          _message = "해당 이메일은 이미 사용중인 이메일입니다";
          break;
      }
      SnackBar snackBar = SnackBar(
        content: Text(_message),
      );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _scaffoldKey.currentState.showSnackBar(snackBar);
    });

    //auth 에서 유저의 토큰(키)값을 받아와서 firestore에 저장
    _user = userCredential.user;
    if (_user == null) {
      SnackBar snackBar = SnackBar(
        content: Text('Please try again later'),
      );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _scaffoldKey.currentState.showSnackBar(snackBar);
    } else {
      //firestore로 데이터 보내기
      await userNetworkRepository.attemptCreateUser(
          userKey: _user.uid, email: _user.email);
    }
  }

  void logIn(BuildContext context,
      {@required String email, @required String password}) async{
    changeFirebaseAuthStatus(FirebaseAuthStatus.progress);
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(), password: password.trim())
        .catchError((error) {
      print('Error $error');
      String _message = '';
      switch (error.code) {
        case 'invalid-email':
          _message = '사용할 수 없는 이메일입니다.';
          break;
        case 'user-disabled':
          _message = '해당 사용자는 비활성화 상태입니다.';
          break;
        case 'user-not-found':
          _message = '없는 이메일 입니다.';
          break;
        case 'wrong-password':
          _message = '비밀번호가 틀렸습니다.';
          break;
      }

      SnackBar snackBar = SnackBar(
        content: Text(_message),
      );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _scaffoldKey.currentState.showSnackBar(snackBar);
    });

    _user = userCredential.user;
    if (_user == null) {
      SnackBar snackBar = SnackBar(
        content: Text('실패'),
      );
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _scaffoldKey.currentState.showSnackBar(snackBar);
    } else {

    }
  }

  void signOut() async{
    changeFirebaseAuthStatus(FirebaseAuthStatus.progress);
    _firebaseAuthStatus = FirebaseAuthStatus.signout;
    if (_user != null) {
      _user = null;
      if(await _facebookLogin.isLoggedIn) {
        await _facebookLogin.logOut();
      }
      await _firebaseAuth.signOut();
    }
    notifyListeners();
  }

  void changeFirebaseAuthStatus([FirebaseAuthStatus firebaseAuthStatus]) {
    if (firebaseAuthStatus != null) {
      _firebaseAuthStatus = firebaseAuthStatus; //값을 받아왔으면 그 값을 넣어줌
    } else {
      if (_user != null) {
        _firebaseAuthStatus = FirebaseAuthStatus.signin;
      } else {
        _firebaseAuthStatus = FirebaseAuthStatus.signout;
      }
    }

    notifyListeners(); // 구독중인 위젯들한테 상태변화 디스플레이 변경이 필요함을 알려줌
  }

  void loginWithFacebook(BuildContext context) async{ //BuildContext는 스낵바를 보여주기 위해 받아옴
    changeFirebaseAuthStatus(FirebaseAuthStatus.progress);
    if(_facebookLogin == null)
    _facebookLogin = FacebookLogin();
    final result = await _facebookLogin.logIn(['email']);

    switch(result.status) {
      case FacebookLoginStatus.loggedIn:
        _handleFacebookTokenWithFirebase(context, result.accessToken.token);
        break;
      case FacebookLoginStatus.cancelledByUser:
        simpleSnackbar(context, 'User cancel facebook sign in');
        break;
      case FacebookLoginStatus.error:
        simpleSnackbar(context, 'Error while facebook sign in');
        _facebookLogin.logOut();
        break;
    }
  }

  void _handleFacebookTokenWithFirebase(BuildContext context, String token) async {
    final OAuthCredential credential = FacebookAuthProvider.credential(token);

    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

    _user = userCredential.user;

    if(_user == null) {
      simpleSnackbar(context, '페북 로그인이 잘 안됐습니다. 나중에 다시 시도해주세요');
    } else {
      await userNetworkRepository.attemptCreateUser(
          userKey: _user.uid, email: _user.email);
    }

    notifyListeners();
  }

  FirebaseAuthStatus get firebaseAuthStatus => _firebaseAuthStatus;
  User get user => _user;
}

enum FirebaseAuthStatus { signout, progress, signin }
