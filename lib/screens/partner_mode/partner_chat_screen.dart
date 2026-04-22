import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/gradients.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/partner_provider.dart';
import '../../models/partner_model.dart';

class PartnerChatScreen extends StatefulWidget {
  final LanguageProvider lang;
  final PartnerProvider partner;
  const PartnerChatScreen({super.key, required this.lang, required this.partner});
  @override
  State<PartnerChatScreen> createState() => _PartnerChatScreenState();
}

class _PartnerChatScreenState extends State<PartnerChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  static const _myId = 'partner_001';

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.partner.sendMessage(_myId, text);
    _ctrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.partner.messages;
    final name = widget.partner.healthView?.womanName ?? 'her';
    final lang = widget.lang;

    return Column(children: [
      // Header
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: TGradients.gradPink,
              borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(name[0],
                style: const TextStyle(fontSize: 18,
                    color: TColors.white, fontWeight: FontWeight.w800)))),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 16,
                color: TColors.white, fontWeight: FontWeight.w700)),
            Row(children: [
              Container(width: 6, height: 6,
                  decoration: const BoxDecoration(
                      color: TColors.green500, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(lang.s('Active now', 'አሁን ንቁ'),
                  style: TextStyle(fontSize: 11,
                      color: TColors.green500.withOpacity(0.8))),
            ]),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TColors.white.withOpacity(0.08))),
            child: Text(lang.s('Private · Tsega only', 'የግል · ጸጋ ብቻ'),
                style: TextStyle(fontSize: 10,
                    color: TColors.white.withOpacity(0.3),
                    fontFamily: 'monospace'))),
        ]),
      ),
      const SizedBox(height: 12),

      // Messages
      Expanded(child: messages.isEmpty
          ? _EmptyChat(lang: lang, name: name)
          : ListView.builder(
              controller: _scroll,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final m = messages[i];
                final isMe = m.senderId == _myId;
                if (m.type == MessageType.dangerAlert) {
                  return _SystemMessage(m: m, lang: lang);
                }
                return _Bubble(message: m, isMe: isMe, name: name);
              },
            )),

      // Input
      ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16,
                MediaQuery.of(context).padding.bottom + 80),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1628).withOpacity(0.85),
              border: Border(top: BorderSide(
                  color: TColors.white.withOpacity(0.07)))),
            child: Row(children: [
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: TColors.white, fontSize: 14),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: lang.s(
                          'Message $name...', '$nameን ይጻፉ...'),
                      hintStyle: TextStyle(
                          color: TColors.white.withOpacity(0.25),
                          fontSize: 14),
                      filled: true,
                      fillColor: TColors.white.withOpacity(0.07),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12)),
                  ),
                ),
              )),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: TGradients.gradTeal,
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.send_rounded,
                      color: TColors.white, size: 20)),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

class _Bubble extends StatelessWidget {
  final PartnerMessage message;
  final bool isMe;
  final String name;
  const _Bubble({required this.message, required this.isMe, required this.name});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisAlignment: isMe
          ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              gradient: TGradients.gradPink,
              borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(name[0],
                style: const TextStyle(fontSize: 12,
                    color: TColors.white, fontWeight: FontWeight.w800)))),
          const SizedBox(width: 8),
        ],
        Flexible(child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe
                ? TColors.teal500.withOpacity(0.20)
                : TColors.white.withOpacity(0.08),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16)),
            border: Border.all(
              color: isMe
                  ? TColors.teal500.withOpacity(0.3)
                  : TColors.white.withOpacity(0.08))),
          child: Text(message.content,
              style: TextStyle(fontSize: 14, height: 1.4,
                  color: TColors.white.withOpacity(0.9))),
        )),
        if (isMe) const SizedBox(width: 4),
      ],
    ),
  );
}

class _SystemMessage extends StatelessWidget {
  final PartnerMessage m;
  final LanguageProvider lang;
  const _SystemMessage({required this.m, required this.lang});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: TColors.red400.withOpacity(0.10),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: TColors.red400.withOpacity(0.3))),
    child: Row(children: [
      const Icon(Icons.warning_amber_rounded,
          color: TColors.red400, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(m.content,
          style: const TextStyle(fontSize: 13,
              color: TColors.red400, fontWeight: FontWeight.w600))),
    ]),
  );
}

class _EmptyChat extends StatelessWidget {
  final LanguageProvider lang;
  final String name;
  const _EmptyChat({required this.lang, required this.name});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.chat_bubble_outline_rounded,
          color: TColors.teal400, size: 48),
      const SizedBox(height: 16),
      Text(lang.s('Start a conversation with $name',
          '$nameን ያናግሩ'),
          style: TextStyle(fontSize: 15,
              color: TColors.white.withOpacity(0.5)),
          textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(lang.s(
          'Everything here stays private between the two of you.',
          'ሁሉም ነገር በሁለቱዎ መካከል ሚስጥር ሆኖ ይቀጥላል።'),
          style: TextStyle(fontSize: 12,
              color: TColors.white.withOpacity(0.3)),
          textAlign: TextAlign.center),
    ]),
  );
}
