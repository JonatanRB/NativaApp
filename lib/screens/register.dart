import 'package:flutter/material.dart';

// Definimos los colores del diseño para reutilizarlos fácilmente
const Color kDarkGreen = Color(0xFF0A5C48);
const Color kLightGreen = Color(0xFFC4E4C6);
const Color kBackgroundGreen = Color(0xFFF0F7F1);
const Color kGreyText = Color(0xFFB0D0B2);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formSignupKey = GlobalKey<FormState>();

  // Solo dejamos los controladores que vamos a usar
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;

  @override
  void dispose() {
    // Liberamos los controladores
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Funciones de Validación (Ajustadas) ---

  String? validateEmail(String? email) {
    RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
    final isEmailValid = emailRegex.hasMatch(email ?? '');
    if (!isEmailValid) {
      return 'Por favor ingresa un email válido';
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }
  
  // Función para construir la decoración de los campos de texto
  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: kDarkGreen.withOpacity(0.6)),
      filled: true,
      fillColor: kLightGreen,
      contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundGreen,
      // SafeArea para evitar que los elementos se superpongan con la barra de estado
      body: SafeArea(
        child: Column(
          children: [
            // --- SECCIÓN SUPERIOR PERSONALIZADA ---
            _buildTopBar(),

            // --- SECCIÓN DEL FORMULARIO ---
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                decoration: const BoxDecoration(
                  color: kDarkGreen,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40.0),
                    
                  ),
                ),
                // SingleChildScrollView para evitar desbordamiento cuando aparece el teclado
                child: SingleChildScrollView(
                  child: Form(
                    key: _formSignupKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40.0),
                        const Text(
                          'Crea una nueva\ncuenta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        
                        // Texto para navegar a la pantalla de inicio de sesión
                        GestureDetector(
                           onTap: () {
                              // Navegar a la pantalla de login (asegúrate de tener una ruta llamada '/login')
                              Navigator.pushNamed(context, '/login');
                           },
                          child: const Text.rich(
                            TextSpan(
                              text: 'Si ya estas registrado ',
                              style: TextStyle(color: kGreyText),
                              children: [
                                TextSpan(
                                  text: 'inicia sesion aqui',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kLightGreen, // Un color que resalte
                                    decoration: TextDecoration.underline,
                                    decorationColor: kLightGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40.0),

                        // Campo Nombre
                        const Text('NOMBRE', style: TextStyle(color: kGreyText, letterSpacing: 1.2)),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: _fullNameController,
                          style: const TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu nombre completo';
                            }
                            return null;
                          },
                          decoration: _buildInputDecoration(hintText: 'Anahi Ramirez'),
                        ),
                        const SizedBox(height: 25.0),

                        // Campo Email
                        const Text('EMAIL', style: TextStyle(color: kGreyText, letterSpacing: 1.2)),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                           style: const TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold),
                          validator: validateEmail,
                          decoration: _buildInputDecoration(hintText: 'anahi@gmail.com'),
                        ),
                        const SizedBox(height: 25.0),
                        
                        // Campo Contraseña
                        const Text('CONTRASEÑA', style: TextStyle(color: kGreyText, letterSpacing: 1.2)),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: _passwordController,
                           style: const TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold),
                          obscureText: _isPasswordObscured,
                          validator: validatePassword,
                          decoration: _buildInputDecoration(
                            hintText: '******',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordObscured ? Icons.visibility : Icons.visibility_off,
                                color: kDarkGreen.withOpacity(0.6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordObscured = !_isPasswordObscured;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 40.0),

                        // Botón de Registrarse
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formSignupKey.currentState?.validate() ?? false) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Procesando datos...')),
                                );
                                // Aquí puedes leer los datos con:
                                // _fullNameController.text
                                // _emailController.text
                                // _passwordController.text
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kLightGreen,
                              foregroundColor: kDarkGreen,
                              padding: const EdgeInsets.symmetric(vertical: 18.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            child: const Text(
                              'Registrarme',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir la barra superior
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
            decoration: const BoxDecoration(
              color: kDarkGreen,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30)
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Simula el logo con un ícono, reemplázalo con tu Image.asset
                Image.asset('assets/2.png', scale: 7,), // Asegúrate de tener tu logo en assets
                const SizedBox(width: 8),
                const Text(
                  'Hola!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}