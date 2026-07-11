import 'package:flutter/material.dart';

/// Hayat kategorileri — onboarding'de seçilir, hedefler bunlara bağlanır.
enum Category {
  health('Sağlık', Icons.favorite),
  career('Kariyer', Icons.work),
  finance('Finans', Icons.savings),
  learning('Öğrenme', Icons.menu_book),
  relationships('İlişkiler', Icons.people),
  spirituality('Maneviyat', Icons.self_improvement),
  personalGrowth('Kişisel Gelişim', Icons.eco);

  const Category(this.label, this.icon);

  final String label;
  final IconData icon;
}
