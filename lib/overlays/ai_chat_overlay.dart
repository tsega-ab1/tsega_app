import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';

class AiChatOverlay extends StatefulWidget {
  const AiChatOverlay({super.key});
  @override
  State<AiChatOverlay> createState() => _AiChatOverlayState();
}

class _AiChatOverlayState extends State<AiChatOverlay> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [
    _Msg(false, 'Hello! I am Tsega AI. Ask me anything about your health, pregnancy, or cycle.', 'ሰላም! እኔ ጸጋ AI ነኝ። ስለ ጤናዎ፣ እርግዝናዎ፣ ወይም ዑደትዎ ማንኛውንም ነገር ይጠይቁ።'),
  ];
  bool _thinking = false;

  final _quick = [
    ('What are danger signs?', 'አደጋ ምልክቶች?'),
    ('Iron-rich Ethiopian foods', 'ብረት ያለው ምግብ'),
    ('When is my fertile window?', 'ፈጠራ መስኮቴ?'),
    ('ANC visit schedule', 'ANC ጊዜ ሰሌዳ'),
  ];

  final _responses = {
    'danger': ('Danger signs in pregnancy include: severe headache, blurred vision, sudden swelling of face/hands, heavy vaginal bleeding, baby not moving, and fever. Go to hospital immediately if you experience any of these.',
               'በእርግዝና የአደጋ ምልክቶች: ከፍተኛ ራስ ምታት፣ ደብዛዛ ዕይታ፣ ፊት/እጅ ማበጥ፣ ከፍተኛ ደም መፍሰስ፣ ልጅ አለ ያለ እንቅስቃሴ፣ ትኩሳት። ወዲያውኑ ሆስፒታል ይሂዱ።'),
    'iron': ('Iron-rich Ethiopian foods: Misir (red lentils), Gomen (collard greens), Teff injera, Shiro, Chickpeas, Sesame (selit). Eat with tomatoes or lemon to boost absorption.',
             'ብረት ያለው ኢትዮጵያዊ ምግብ: ምስር፣ ጎመን፣ የጤፍ እንጀራ፣ ሽሮ፣ ሽምብራ፣ ሰሊጥ። ብረት ለመምጠጥ ከቲማቲም ወይም ሎሚ ጋር ይ召し食べ።'),
    'fertile': ('Your fertile window is typically 5 days before ovulation and 1 day after. Track your cycle length — ovulation usually occurs 14 days before your next period.',
                'የፈጠራ መስኮቶ ፅንሰ-ሀሳብ ከ5 ቀናት በፊት እና 1 ቀን በኋላ ነው። ዑደቱን ይከታተሉ — ፅንሰ-ሀሳብ ብዙ ጊዜ ቀጣዩ ወር አበባ 14 ቀናት ቀደም ይከሰታል።'),
    'anc': ('WHO recommends 8 ANC visits: Weeks 12, 20, 26, 30, 34, 36, 38, 40. In Ethiopia, visit your nearest health center or hospital. Bring your ANC card every time.',
            'WHO 8 ANC ጉብኝቶችን ይመክራል: ሳምንታት 12፣ 20፣ 26፣ 30፣ 34፣ 36፣ 38፣ 40። ቅርብ ጤና ጣቢያ ወይም ሆስፒታልዎን ይጎብኙ። ANC ካርድዎን ሁልጊዜ ይዘው ይሂዱ።'),
    'default': ('I understand your question. Based on Ethiopian health guidelines and your profile, I recommend consulting with your healthcare provider for personalized advice. Is there a specific concern I can help with?',
                'ጥያቄዎን ተረዳሁ። በኢትዮጵያ የጤና መመሪያዎች ላይ በመመርኮዝ፣ ለግላዊ ምክር ከጤና ሰጭዎ ጋር ይወያዩ። ሊረዳዎ የምችለው ልዩ ስጋት አለ?'),
  };

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _send(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _msgs.add(_Msg(true, text, text));
      _thinking = true;
    });
    _ctrl.clear();
    await Future.delayed(const Duration(milliseconds: 1500));

    final lower = text.toLowerCase();
    String key = 'default';
    if (lower.contains('danger') || lower.contains('አደጋ')) key = 'danger';
    else if (lower.contains('iron') || lower.contains('ብረት')) key = 'iron';
    else if (lower.contains('fertile') || lower.contains('ፈጠራ')) key = 'fertile';
    else if (lower.contains('anc') || lower.contains('visit')) key = 'anc';

    if (!mounted) return;
    setState(() {
      _thinking = false;
      _msgs.add(_Msg(false, _responses[key]!.$1, _responses[key]!.$2));
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: TColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: const BoxDecoration(
            gradient: TGradients.gradTeal,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: TColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.psychology_rounded,
                  color: TColors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tsega AI',
                  style: TextStyle(fontSize: 16,
                      color: TColors.white, fontWeight: FontWeight.w700)),
              Text(lang.s('Always here for you', 'ሁልጊዜ አለሁ'),
                  style: TextStyle(fontSize: 12,
                      color: TColors.white.withOpacity(0.8))),
            ]),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close_rounded, color: TColors.white)),
          ]),
        ),
        // Quick replies
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: _quick.map((q) =>
            GestureDetector(
              onTap: () => _send(lang.isAmharic ? q.$2 : q.$1),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: TColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TColors.teal300)),
                child: Text(lang.isAmharic ? q.$2 : q.$1,
                    style: const TextStyle(fontSize: 12,
                        color: TColors.teal700,
                        fontWeight: FontWeight.w500)),
              ),
            )).toList()),
        ),
        // Messages
        Expanded(child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(16),
          itemCount: _msgs.length + (_thinking ? 1 : 0),
          itemBuilder: (_, i) {
            if (_thinking && i == _msgs.length) {
              return const _ThinkingBubble();
            }
            final m = _msgs[i];
            return _MsgBubble(
                isUser: m.isUser,
                text: lang.isAmharic ? m.textAm : m.textEn);
          },
        )),
        // Input
        Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16,
              MediaQuery.of(context).viewInsets.bottom + 16),
          decoration: BoxDecoration(
            color: TColors.white,
            boxShadow: [BoxShadow(
              color: TColors.teal700.withOpacity(0.06),
              blurRadius: 12, offset: const Offset(0, -3))]),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: lang.s('Ask about your health...',
                    'ስለ ጤናዎ ይጠይቁ...'),
                filled: true, fillColor: TColors.cream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
              onSubmitted: _send,
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _send(_ctrl.text),
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                  gradient: TGradients.gradTeal,
                  shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded,
                    color: TColors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Msg {
  final bool isUser;
  final String textEn, textAm;
  _Msg(this.isUser, this.textEn, this.textAm);
}

class _MsgBubble extends StatelessWidget {
  final bool isUser;
  final String text;
  const _MsgBubble({required this.isUser, required this.text});

  @override
  Widget build(BuildContext context) => Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(
        gradient: isUser ? TGradients.gradTeal : null,
        color: isUser ? null : TColors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        boxShadow: [BoxShadow(
          color: TColors.teal700.withOpacity(0.06),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 14, height: 1.5,
              color: isUser ? TColors.white : TColors.dark)),
    ),
  );
}

class _ThinkingBubble extends StatefulWidget {
  const _ThinkingBubble();
  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) =>
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: TColors.teal500.withOpacity(
                  i == 0 ? _ctrl.value :
                  i == 1 ? (_ctrl.value + 0.3).clamp(0, 1) :
                  (_ctrl.value + 0.6).clamp(0, 1)),
              shape: BoxShape.circle),
          ),
        ))),
    ),
  );
}
