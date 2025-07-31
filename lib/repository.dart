import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class DataRepository{
  static final _encryptedPrefs = EncryptedSharedPreferences();
  static String firstName='';
  static String lastName='';
  static String phoneNumber='';
  static String email='';
  static String loginName='';

  static saveData() async{
    await _encryptedPrefs.setString('firstName', firstName);
    await _encryptedPrefs.setString('lastName', lastName);
    await _encryptedPrefs.setString('phoneNumber', phoneNumber);
    await _encryptedPrefs.setString('email', email);
    await _encryptedPrefs.setString('loginName', loginName);

  }
  static loadData() async{
    firstName=await _encryptedPrefs.getString('firstName');
    lastName=await _encryptedPrefs.getString('lastName');
    phoneNumber=await _encryptedPrefs.getString('phoneNumber');
    email=await _encryptedPrefs.getString('email');
    loginName = await _encryptedPrefs.getString("loginName") ;

  }
}