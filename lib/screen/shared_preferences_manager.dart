import 'dart:async' show Future;
import 'dart:convert';
//import 'package:report_issue/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

const accountKey = 'accountKey';

class SharedPreferencesManager {
	static final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager._internal();

	factory SharedPreferencesManager() {
		return _sharedPreferencesManager;
	}

	SharedPreferencesManager._internal();

	SharedPreferences _prefs;

	Future<void> init() async {
		await SharedPreferences.getInstance().then((data) {
			_prefs = data;
		});
	}

	void save(String key, dynamic data) {
		_prefs?.setString(key, data == null ? null : jsonEncode(data));
	}

	void remove(String key) {
		_prefs?.remove(key);
	}

	void saveString(String key, String value) {
		_prefs?.setString(key, value);
	}

	String getString(String key) {
		final value = _prefs?.getString(key);
		return value ?? '';
	}
	
	/// Account
	// Account getAccount() {
	// 	final value = _prefs?.getString(accountKey);
	// 	return value == null ? null : Account.fromJson(jsonDecode(value));
	// }
}

final SharedPreferencesManager sharedPreferencesManager = SharedPreferencesManager();
