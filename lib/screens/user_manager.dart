class UserManager {
  // Instancia única (Singleton)
  static final UserManager _instance = UserManager._internal();

  // Constructor privado
  UserManager._internal();

  // Método factory para devolver la misma instancia
  factory UserManager() {
    return _instance;
  }

  // Parámetro global
  String user_Name = "Usuario predeterminado";

  // Métodos para actualizar y obtener valores (opcional)
  void updateUserName(String newName) {
    user_Name = newName;
    
  //   print("El valor de la variable es: ${user_Name}");
  }
}
