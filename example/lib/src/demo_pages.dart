import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A small piece of content shown in the home masonry list.
class DemoCard {
  const DemoCard({
    required this.title,
    required this.color,
    required this.height,
  });

  final String title;
  final Color color;
  final double height;
}

/// The cards used when the sample is launched without custom data.
const defaultHomeCards = <DemoCard>[
  DemoCard(title: '静かな朝', color: Color(0xff9b7c68), height: 248),
  DemoCard(title: '旅のメモ', color: Color(0xffc9b78b), height: 178),
  DemoCard(title: '小さな道具', color: Color(0xff6d7f84), height: 198),
  DemoCard(title: '窓辺の時間', color: Color(0xffb9a8a0), height: 274),
  DemoCard(title: '週末の色', color: Color(0xff7f8a5e), height: 220),
  DemoCard(title: 'つくるもの', color: Color(0xff8c6f59), height: 178),
  DemoCard(title: '部屋の景色', color: Color(0xff8d8b95), height: 236),
  DemoCard(title: '午後の散歩', color: Color(0xffb6a37d), height: 190),
];

const _pageHorizontalPadding = 16.0;
const _cardGap = 10.0;
const _navigationSize = 52.0;
const _navigationBottomMargin = 32.0;
const _navigationContentGap = 18.0;

double _pageBottomPadding(BuildContext context) {
  final safeBottom = MediaQuery.paddingOf(context).bottom;
  return _navigationSize +
      math.max(_navigationBottomMargin, safeBottom) +
      _navigationContentGap;
}

/// The home page with a simple two-column card layout.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.cards});

  final List<DemoCard> cards;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        _pageHorizontalPadding,
        topInset + 18,
        _pageHorizontalPadding,
        _pageBottomPadding(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HomeHeader(),
          const SizedBox(height: 22),
          if (cards.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 96),
              child: Center(
                child: Text(
                  'アイデアはまだありません',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            )
          else
            _MasonryPreview(cards: cards),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'Floating Tile Nav',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(
          width: 32,
          height: 32,
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 8),
        const SizedBox(
          width: 32,
          height: 32,
          child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
        ),
      ],
    );
  }
}

class _MasonryPreview extends StatelessWidget {
  const _MasonryPreview({required this.cards});

  final List<DemoCard> cards;

  @override
  Widget build(BuildContext context) {
    final left = <DemoCard>[];
    final right = <DemoCard>[];
    for (var index = 0; index < cards.length; index += 1) {
      (index.isEven ? left : right).add(cards[index]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _CardColumn(cards: left)),
        const SizedBox(width: _cardGap),
        Expanded(child: _CardColumn(cards: right)),
      ],
    );
  }
}

class _CardColumn extends StatelessWidget {
  const _CardColumn({required this.cards});

  final List<DemoCard> cards;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < cards.length; index += 1) ...[
          _DemoCardView(card: cards[index]),
          if (index < cards.length - 1) const SizedBox(height: _cardGap),
        ],
      ],
    );
  }
}

class _DemoCardView extends StatelessWidget {
  const _DemoCardView({required this.card});

  final DemoCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: card.height,
      decoration: BoxDecoration(
        color: card.color,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(14),
      child: Text(
        card.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
        ),
      ),
    );
  }
}

/// The category page keeps its sample content deliberately static.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  static const _categories = <String>[
    'すべて',
    'インテリア',
    'レシピ',
    '旅行',
    'ファッション',
    'デザイン',
  ];

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        _pageHorizontalPadding,
        topInset + 22,
        _pageHorizontalPadding,
        _pageBottomPadding(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '検索',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xff24251f),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.white70),
                SizedBox(width: 10),
                Text('アイデアを検索', style: TextStyle(color: Colors.white60)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'カテゴリ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: index == 0 ? Colors.white : const Color(0xff32332d),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: Center(
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: index == 0 ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 38),
          const _SearchPrompt(),
        ],
      ),
    );
  }
}

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 62, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xff1f201b),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(Icons.auto_awesome, color: Colors.white70, size: 32),
          SizedBox(height: 16),
          Text(
            '気になるテーマを見つけよう',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'インテリア、レシピ、旅行などのカテゴリ。',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// A compact profile placeholder for switching-screen demonstrations.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        _pageHorizontalPadding,
        topInset + 22,
        _pageHorizontalPadding,
        _pageBottomPadding(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'プロフィール',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 30),
          const CircleAvatar(
            radius: 42,
            backgroundColor: Color(0xffc99b78),
            child: Icon(Icons.person, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 16),
          const Text(
            'あなたのボード',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '保存したアイデアとボード',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 38),
          const _ProfileRow(
            icon: Icons.bookmark_border,
            label: '保存したアイデア',
            value: '12',
          ),
          const SizedBox(height: 10),
          const _ProfileRow(
            icon: Icons.dashboard_outlined,
            label: 'ボード',
            value: '3',
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xff24251f),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
