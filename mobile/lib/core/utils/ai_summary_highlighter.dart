import 'package:flutter/material.dart';

/// AI özet metninde tercih uyarılarını renklendirir.
/// Kırmızı: hastalık/hassasiyet · Turuncu: alerjen · Yeşil: günlük mod uyumu
class AiSummaryHighlighter {
  AiSummaryHighlighter._();

  static const _conditionKeywords = {
    'çölyak': [
      'gluten',
      'glutensiz',
      'buğday',
      'hassasiyetin',
      'hassasiyet',
      'içerik analizine göre',
    ],
    'gluten hassasiyeti': [
      'gluten',
      'buğday',
      'hassasiyetin',
      'hassasiyet',
      'içerik analizine göre',
    ],
    'laktoz intoleransı': ['laktoz', 'süt', 'hassasiyetin', 'hassasiyet'],
    'diyabet': ['şeker', 'diyabet', 'hassasiyetin'],
    'gut': ['sakatat', 'purin', 'hassasiyetin'],
    'hipertansiyon': ['tuz', 'sodyum', 'hassasiyetin'],
    'fruktoz intoleransı': ['fruktoz', 'hassasiyetin'],
    'fenilketonüri': ['fenilalanin', 'hassasiyetin'],
    'favizm': ['bakla', 'hassasiyetin'],
  };

  static const _modeGreenPhrases = [
    'günlük modunuza uygun',
    'modunuza uygun görünüyor',
    'modunuza uygun',
    'moduna uygun görünüyor',
    'moduna uygun',
    'tam sana göre',
    'tam size göre',
    'modunuzu karşılıyor',
    'modunuzu destekliyor',
    'keyifli bir ziyaret olabilir',
  ];

  static TextSpan buildHighlightedSpan({
    required String text,
    required TextStyle baseStyle,
    Map<String, dynamic> checks = const {},
    List<String> userAllergens = const [],
    List<String> userConditions = const [],
    String userDailyMode = '',
  }) {
    if (text.isEmpty) return TextSpan(text: '', style: baseStyle);

    final modeMatch = (checks['mode_match'] as String?)?.toLowerCase();
    final detectedAllergen = checks['allergen'] as String?;
    final detectedCondition = checks['condition'] as String?;

    final rules = <_HighlightRule>[];

    if (modeMatch == 'uyumlu') {
      for (final phrase in _modeGreenPhrases) {
        rules.add(_HighlightRule(phrase, _HighlightKind.mode, priority: 1));
      }
      for (final phrase in _modePhrasesFor(userDailyMode)) {
        rules.add(_HighlightRule(phrase, _HighlightKind.mode, priority: 1));
      }
    }

    for (final allergen in userAllergens) {
      final term = allergen.trim().toLowerCase();
      if (term.isNotEmpty) {
        rules.add(_HighlightRule(term, _HighlightKind.allergen, priority: 2));
      }
    }
    if (detectedAllergen != null && detectedAllergen.isNotEmpty) {
      rules.add(
        _HighlightRule(
          detectedAllergen.toLowerCase(),
          _HighlightKind.allergen,
          priority: 2,
        ),
      );
    }
    rules.add(
      const _HighlightRule('alerjen', _HighlightKind.allergen, priority: 2),
    );

    if (detectedCondition != null && detectedCondition.isNotEmpty) {
      rules.add(
        _HighlightRule(
          detectedCondition.toLowerCase(),
          _HighlightKind.condition,
          priority: 3,
        ),
      );
    }
    for (final condition in userConditions) {
      final key = condition.trim().toLowerCase();
      if (key.isEmpty) continue;
      rules.add(_HighlightRule(key, _HighlightKind.condition, priority: 3));
      for (final kw in _conditionKeywords[key] ?? const []) {
        rules.add(_HighlightRule(kw, _HighlightKind.condition, priority: 3));
      }
    }
    rules.add(
      const _HighlightRule(
        'içerik analizine göre',
        _HighlightKind.condition,
        priority: 3,
      ),
    );
    rules.add(
      const _HighlightRule(
        'hassasiyetin varsa',
        _HighlightKind.condition,
        priority: 3,
      ),
    );

    final matches = <_TextMatch>[];
    final lower = text.toLowerCase();

    for (final rule in rules) {
      final term = rule.term.toLowerCase();
      var start = 0;
      while (true) {
        final index = lower.indexOf(term, start);
        if (index < 0) break;
        matches.add(
          _TextMatch(
            start: index,
            end: index + term.length,
            kind: rule.kind,
            priority: rule.priority,
          ),
        );
        start = index + term.length;
      }
    }

    if (matches.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    matches.sort((a, b) {
      if (a.start != b.start) return a.start.compareTo(b.start);
      return b.priority.compareTo(a.priority);
    });

    final merged = <_TextMatch>[];
    for (final match in matches) {
      if (merged.isEmpty) {
        merged.add(match);
        continue;
      }
      final last = merged.last;
      if (match.start >= last.end) {
        merged.add(match);
      } else if (match.priority > last.priority) {
        merged[merged.length - 1] = match;
      }
    }

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in merged) {
      if (match.start > cursor) {
        spans.add(
          TextSpan(text: text.substring(cursor, match.start), style: baseStyle),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: baseStyle.copyWith(
            color: _colorFor(match.kind),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
    }

    return TextSpan(children: spans);
  }

  static List<String> _modePhrasesFor(String mode) {
    final trimmed = mode.trim();
    if (trimmed.isEmpty) return const [];

    final slug = trimmed.toLowerCase();
    final slugAscii = _asciiFold(slug);
    final capitalized =
        trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();

    return [
      '$slug moduna uygun görünüyor',
      '$slug moduna uygun',
      '$slugAscii moduna uygun görünüyor',
      '$slugAscii moduna uygun',
      '$capitalized moduna uygun görünüyor',
      '$capitalized moduna uygun',
    ];
  }

  static String _asciiFold(String value) {
    return value
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u');
  }

  static Color _colorFor(_HighlightKind kind) {
    return switch (kind) {
      _HighlightKind.condition => const Color(0xFFD32F2F),
      _HighlightKind.allergen => const Color(0xFFF57C00),
      _HighlightKind.mode => const Color(0xFF2E7D32),
    };
  }
}

enum _HighlightKind { condition, allergen, mode }

class _HighlightRule {
  const _HighlightRule(this.term, this.kind, {required this.priority});
  final String term;
  final _HighlightKind kind;
  final int priority;
}

class _TextMatch {
  const _TextMatch({
    required this.start,
    required this.end,
    required this.kind,
    required this.priority,
  });
  final int start;
  final int end;
  final _HighlightKind kind;
  final int priority;
}
