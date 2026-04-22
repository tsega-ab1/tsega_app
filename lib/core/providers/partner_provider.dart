import 'package:flutter/material.dart';
import '../../models/partner_model.dart';

class PartnerProvider extends ChangeNotifier {
  AppMode _appMode = AppMode.unknown;
  PartnerLink? _link;
  PartnerHealthView? _healthView;
  PartnerInvite? _currentInvite;
  final List<PartnerMessage> _messages = [];
  bool _hasDangerAlert = false;
  String? _partnerName;

  AppMode get appMode => _appMode;
  PartnerLink? get link => _link;
  PartnerHealthView? get healthView => _healthView;
  PartnerInvite? get currentInvite => _currentInvite;
  List<PartnerMessage> get messages => List.unmodifiable(_messages);
  bool get hasDangerAlert => _hasDangerAlert;
  bool get isLinked => _link != null && (_link?.isActive ?? false);
  String? get partnerName => _partnerName;

  // Called on app start — detect mode from local storage
  void detectMode(String? savedMode, String? savedCode) {
    if (savedMode == 'partner' && savedCode != null) {
      _appMode = AppMode.partner;
    } else if (savedMode == 'woman') {
      _appMode = AppMode.woman;
    } else {
      _appMode = AppMode.unknown;
    }
    notifyListeners();
  }

  // Woman generates invite
  PartnerInvite generateInvite() {
    _currentInvite = PartnerInvite.generate();
    notifyListeners();
    return _currentInvite!;
  }

  // Partner enters code — mock validation (replace with Supabase call)
  Future<bool> validateAndLink(String code) async {
    await Future.delayed(const Duration(seconds: 2));
    // Mock: any TG- code works for now
    if (code.toUpperCase().startsWith('TG-') && code.length >= 6) {
      _appMode = AppMode.partner;
      _link = PartnerLink(
        linkId: 'link_001',
        womanUserId: 'woman_001',
        partnerUserId: 'partner_001',
        inviteCode: code,
        linkedAt: DateTime.now(),
        isActive: true,
        permissions: PartnerLink.defaultPermissions(),
      );
      // Mock health view
      _healthView = PartnerHealthView(
        womanName: 'Selam',
        lifeStage: 'pregnancy',
        pregnancyWeek: 24,
        nextAncDate: DateTime.now().add(const Duration(days: 5)),
        ancLocation: 'Black Lion Hospital',
        hasDangerSigns: false,
        dangerSignsActive: [],
        loggedToday: false,
        moodScore: 4,
        symptoms: null,
        lastLabRisk: null,
        weight: null,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  // Update permissions (woman side)
  void updatePermission(PartnerPermission permission, bool value) {
    if (_link == null) return;
    _link!.permissions[permission] = value;
    notifyListeners();
  }

  // Trigger danger alert
  void triggerDangerAlert(List<String> signs) {
    _hasDangerAlert = true;
    _messages.insert(0, PartnerMessage(
      id: DateTime.now().toIso8601String(),
      senderId: 'system',
      content: 'DANGER: ${signs.join(', ')}',
      timestamp: DateTime.now(),
      isRead: false,
      type: MessageType.dangerAlert,
    ));
    notifyListeners();
  }

  void dismissDangerAlert() {
    _hasDangerAlert = false;
    notifyListeners();
  }

  // Messaging
  void sendMessage(String senderId, String content) {
    _messages.insert(0, PartnerMessage(
      id: DateTime.now().toIso8601String(),
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      type: MessageType.text,
    ));
    notifyListeners();
  }

  void markAllRead() {
    notifyListeners();
  }

  int get unreadCount =>
      _messages.where((m) => !m.isRead).length;
}
