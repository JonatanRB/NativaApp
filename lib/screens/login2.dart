import 'package:flutter/material.dart';

// Paleta de colores consistente
const Color kDarkGreen = Color.fromARGB(255, 1, 95, 71);
const Color kLightGreen = Color(0xFFC4E4C6);
const Color kBackgroundGreen = Color.fromARGB(250, 206, 237, 178);
const Color kGreyText = Color(0xFFB0D0B2);

class LoginScreen2 extends StatefulWidget {
  const LoginScreen2({super.key});

  @override
  State<LoginScreen2> createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {
  final _formLoginKey = GlobalKey<FormState>();

  // Controladores para los campos de inicio de sesión
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
      body: SafeArea(
        child: Column(
          children: [
            // --- SECCIÓN SUPERIOR PERSONALIZADA (AJUSTADA) ---
            _buildTopBar(),

            // --- SECCIÓN DEL FORMULARIO (derechha) ---
            
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  // Limitamos el ancho máximo para pantallas muy grandes (opcional pero bueno)
                  constraints: const BoxConstraints(maxWidth: 350),
                  margin: const EdgeInsets.only(left: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: const BoxDecoration(
                    color: kDarkGreen,
                    borderRadius: BorderRadius.only (
                      topLeft: Radius.circular(40.0),
                      
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formLoginKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 40.0),
                          const Text(
                            'Inicia\nsesion',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          const Text(
                            'Inicia sesion para continuar',
                            style: TextStyle(color: kGreyText, fontSize: 16),
                          ),
                          const SizedBox(height: 40.0),

                          const Text('NOMBRE', style: TextStyle(color: kGreyText, letterSpacing: 1.2)),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu nombre';
                              }
                              return null;
                            },
                            decoration: _buildInputDecoration(hintText: 'Anahi Ramirez'),
                            
                          ),
                          const SizedBox(height: 25.0),
                          
                          const Text('CONTRASEÑA', style: TextStyle(color: kGreyText, letterSpacing: 1.2)),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _passwordController,
                            style: const TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold),
                            obscureText: _isPasswordObscured,
                            validator: (value) {
                               if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              return null;
                            },
                            decoration: _buildInputDecoration(
                              hintText: '******',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formLoginKey.currentState?.validate() ?? false) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Iniciando sesión...')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kBackgroundGreen,
                                foregroundColor: kDarkGreen,
                                padding: const EdgeInsets.symmetric(vertical: 18.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              child: const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30.0),

                          Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                               onTap: () {
                                  Navigator.pushNamed(context, '/register');
                               },
                              child: const Text.rich(
                                TextSpan(
                                  text: '¿No tienes una cuenta? ',
                                  style: TextStyle(color: kGreyText),
                                  children: [
                                    TextSpan(
                                      text: 'Registrate aqui',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kLightGreen,
                                      ),
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir la barra superior
  Widget _buildTopBar() {
  return Padding(
    // Se ajusta el padding para que el contenedor inicie desde el borde izquierdo
    padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // El saludo "Hola!" a la izquierda
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 1),
          decoration: const BoxDecoration(
            color: kDarkGreen, // kDarkGreen debe estar definido en tu clase
            // ¡CAMBIO! Solo se redondean las esquinas de la derecha
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hola!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              // ¡CAMBIO! Se reemplaza el ícono por tu logo anterior.
              // Asegúrate de que la ruta 'assets/logo_nativa.png' sea correcta.
              Image.asset(
                'assets/2.png',
                scale: 7,
              ),
            ],
          ),
        ),
        // El ícono de menú a la derecha
        
      ],
    ),
  );
}
}