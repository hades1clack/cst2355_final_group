import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class DataRepository{
  static final _encryptedPrefs = EncryptedSharedPreferences();
  static String firstName='';
  static String lastName='';
  static String phoneNumber='';
  static String address='';
  static String birthDate='';

  static saveData() async{
    await _encryptedPrefs.setString('firstName', firstName);
    await _encryptedPrefs.setString('lastName', lastName);
    await _encryptedPrefs.setString('address', address);
    await _encryptedPrefs.setString('birthDate', birthDate);

  }
  static loadData() async{
    firstName=await _encryptedPrefs.getString('firstName');
    lastName=await _encryptedPrefs.getString('lastName');
    address=await _encryptedPrefs.getString('address');
    birthDate = await _encryptedPrefs.getString("birthDate") ;

  }
}