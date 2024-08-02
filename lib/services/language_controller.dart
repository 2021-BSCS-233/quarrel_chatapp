import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'messages': 'Messages',
          'addFriend': 'Add Friend',
          'chatsEmpty': 'You Do Not Have Any Friends\nAdd Friends to Chat With',
          'chatEmpty': 'No Chats Found, Start Chatting',
          'messageTo': 'Message @name',
          'friends': 'Friends',
          'friendsEmpty':
              'You do not have any friends\nStart adding some friends to chat with',
          'profile': 'Profile',
          'requests': 'Requests',
          'incoming': 'Incoming',
          'incomingEmpty': 'You don\'t have any incoming requests',
          'outgoing': 'Outgoing',
          'outgoingEmpty': 'You haven\'t sent any requests',
          'editStatus': 'Edit Status',
          'aboutMe': 'About Me',
          'changeStatus': 'Change Online Status',
          'onlineStatus': 'Online Status',
          'online': 'Online',
          'dnd': 'Do Not Disturb',
          'idle': 'Idle',
          'hidden': 'Hidden',
          'editProfile': 'Edit Profile',
          'displayNameU': 'DISPLAY NAME',
          'pronounsU': 'PRONOUNS',
          'aboutMeU': 'ABOUT ME',
          'save': 'Save',
          'accountSetting': 'Account Settings',
          'usernameU': 'USERNAME',
          'emailU': 'EMAIL',
          'changePass': 'Change Password',
          'oldPassU': 'OLD PASSWORD',
          'newPassU': 'NEW PASSWORD',
          'language': 'Language',
          'logout': 'Log Out'
        },
        'es': {
          'messages': 'Mensajes',
          'addFriend': 'Agregar amiga',
          'chatsEmpty': 'No tienes amigos\nAgregar amigas para chatear con',
          'chatEmpty': 'No se encontraron chats, comience a chatear',
          'messageTo': 'Mensaje @name',
          'friends': 'Amigas',
          'friendsEmpty':
              'No tienes amigas\nComience a agregar algunos amigos con quienes chatear',
          'profile': 'Perfil',
          'requests': 'Peticiones',
          'incoming': 'Entrante',
          'incomingEmpty': 'No tienes ninguna solicitud entrante',
          'outgoing': 'Enviando',
          'outgoingEmpty': 'No has enviado ninguna solicitud',
          'editStatus': 'Editar estado',
          'aboutMe': 'Acerca de mí',
          'changeStatus': 'Cambiar estado en línea',
          'onlineStatus': 'Estado en línea',
          'online': 'En línea',
          'dnd': 'No molestar',
          'idle': 'Inactiva',
          'hidden': 'Oculto',
          'editProfile': 'Editar perfil',
          'displayNameU': 'NOMBRE PARA MOSTRAR',
          'pronounsU': 'PRONOMBRES',
          'aboutMeU': 'ACERCA DE MÍ',
          'save': 'Ahorrar',
          'accountSetting': 'Cuenta Ajustes',
          'usernameU': 'NOMBRE DE USUARIO',
          'emailU': 'CORREO ELECTRÓNICO',
          'changePass': 'Cambiar la\ncontraseña',
          'oldPassU': 'CONTRASEÑA ANTERIOR',
          'newPassU': 'NUEVA CONTRASEÑA',
          'language': 'Idioma',
          'logout': 'Cerrar sesión'
        }
      };
}

class LocalizationController extends GetxController {
  Locale locale = const Locale('en', '');
  SharedPreferences prefs;

  LocalizationController({required this.prefs}) {
    if (prefs.getString('locale') != null) {
      locale = Locale(prefs.getString('locale')!, '');
      Get.updateLocale(locale);
    } else {
      Get.updateLocale(locale);
      prefs.setString('locale', 'en');
    }
  }

  setLocal(value) async {
    prefs.setString('locale', value);
    locale = Locale(value, '');
    Get.updateLocale(locale);
  }
}
