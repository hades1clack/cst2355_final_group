import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
/// A repository class to manage securely storing and loading user data
/// using encrypted shared preferences.
class DataRepository{
  /// Instance of [EncryptedSharedPreferences] for secure key-value storage.
  static final _encryptedPrefs = EncryptedSharedPreferences();
  /// User's first name.
  static String firstName='';
  /// User's last name.
  static String lastName='';
  /// User's phone number.
  static String phoneNumber='';
  /// User's address.
  static String address='';
  /// User's birth date.
  static String birthDate='';
  /// Saves current user data fields securely into encrypted shared preferences.
  static saveData() async{
    await _encryptedPrefs.setString('firstName', firstName);
    await _encryptedPrefs.setString('lastName', lastName);
    await _encryptedPrefs.setString('address', address);
    await _encryptedPrefs.setString('birthDate', birthDate);
  }
  /// Loads user data fields from encrypted shared preferences into static variables.
  static loadData() async{
    firstName=await _encryptedPrefs.getString('firstName');
    lastName=await _encryptedPrefs.getString('lastName');
    address=await _encryptedPrefs.getString('address');
    birthDate = await _encryptedPrefs.getString("birthDate") ;

  }
}