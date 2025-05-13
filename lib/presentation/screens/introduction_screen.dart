import 'package:flutter/material.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Фоновое изображение
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Контейнер для текста и кнопки
          Column(
            mainAxisAlignment: MainAxisAlignment.start, // Вертикальное выравнивание
            crossAxisAlignment: CrossAxisAlignment.center, // Горизонтальное выравнивание
            children: [
              const Spacer(flex: 3), // Сдвигаем содержимое вниз
              SizedBox(
                width: double.infinity, // Занимаем всю ширину
                child: Center(
                  child: const Text(
                    'ИНТЕЛЛЕКТУАЛЬНЫЙ УЧЕТ\nЗАПАСОВ МЕБЕЛИ И ПРОДАЖ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, // Занимаем всю ширину
                child: Center(
                  child: OutlinedButton(
                    onPressed: () {
                      // Навигация на страницу входа
                      Navigator.pushNamed(context, '/signin');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                    child: const Text(
                      'Начать',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1), // Меньший отступ снизу
            ],
          ),
        ],
      ),
    );
  }
}