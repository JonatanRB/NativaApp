import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFFDFF6D8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Arcos decorativos
          Positioned(
            top: 0,
            child: ClipPath(
              clipper: _TopArcClipper(),
              child: Container(
                width: size.width,
                height: size.height * 0.5,
                color: const Color(0xFF10B981).withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: ClipPath(
              clipper: _BottomArcClipper(),
              child: Container(
                width: size.width,
                height: size.height * 0.5,
                color: const Color(0xFF065F46).withOpacity(0.3),
              ),
            ),
          ),

          // Hojas decorativas (todas hoja1.png)
          Positioned(top: 60, left: 20, child: _hojaDecorativa(50, -0.2)),
          Positioned(top: 180, right: 30, child: _hojaDecorativa(45, 0.3)),
          Positioned(bottom: 140, left: 50, child: _hojaDecorativa(55, 0.1)),
          Positioned(bottom: 50, right: 20, child: _hojaDecorativa(60, -0.1)),

          // Hoja grande decorativa
          Positioned(
            top: 120,
            left: size.width * 0.25,
            child: Image.asset(
              "assets/hoja1.png",
              width: 200,
            ),
          ),

          // Contenido principal
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // LOGO con texto encima (texto centrado y un poco más abajo)
                  SizedBox(
                    width: 180,
                    height:
                        180, // fija una altura para que el Align funcione de forma consistente
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          "assets/hoja2.png",
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                        // Mueve el texto hacia abajo dentro del logo sin que choque
                        const Align(
                          alignment: Alignment(0,
                              0.38), // 0 = centrado, 1 = abajo. Ajusta si hace falta.
                          child: Text(
                            "Nativa",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF005f46),
                              fontFamily:
                                  'serif', // asegúrate de haber agregado la fuente en pubspec.yaml
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Texto de bienvenida
                  const Text(
                    "¡Bienvenido a Nativa App!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005f46),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Botones
                  _botonPrincipal(
                    context,
                    "Iniciar sesión",
                    const Color(0xFF065F46),
                    () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                  const SizedBox(height: 15),
                  _botonPrincipal(
                    context,
                    "Registrarse",
                    const Color(0xFF10B981),
                    () {
                      Navigator.pushNamed(context, '/register');
                    },
                  ),
                  const SizedBox(height: 15),
                  _botonPrincipal(
                    context,
                    "Ir al menú",
                    const Color(
                        0xFF4CAF50), // Verde diferente para distinguirlo
                    () {
                      Navigator.pushNamed(context, '/menu');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reutiliza hoja1.png con rotación
  Widget _hojaDecorativa(double size, double angle) {
    return Transform.rotate(
      angle: angle,
      child: Image.asset(
        "assets/hoja1.png",
        width: size,
      ),
    );
  }

  // Botón estilizado
  Widget _botonPrincipal(
      BuildContext context, String texto, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}

// ClipPath para crear arco superior
class _TopArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ClipPath para crear arco inferior
class _BottomArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
