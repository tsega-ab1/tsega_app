// ─── PARTNER MODEL ────────────────────────────────────────────────
// Shared between woman's app and partner mode

enum AppMode { woman, partner, unknown }

enum PartnerPermission {
  mood,
  symptoms,
  labResults,
  weight,
  cycleDetails,
}

class PartnerLink {
  final String linkId;
  final String womanUserId;
  final String partnerUserId;
  final String inviteCode;        // e.g. TG-4829
  final DateTime linkedAt;
  final bool isActive;
  final Map<PartnerPermission, bool> permissions;

  const PartnerLink({
    required this.linkId,
    required this.womanUserId,
    required this.partnerUserId,
    required this.inviteCode,
    required this.linkedAt,
    required this.isActive,
    required this.permissions,
  });

  // Default permissions — woman can change each one
  static Map<PartnerPermission, bool> defaultPermissions() => {
    PartnerPermission.mood: true,
    PartnerPermission.symptoms: false,
    PartnerPermission.labResults: false,
    PartnerPermission.weight: false,
    PartnerPermission.cycleDetails: false,
  };

  bool can(PartnerPermission p) => permissions[p] ?? false;
}

// What the partner sees of the woman's health
class PartnerHealthView {
  final String womanName;
  final String lifeStage;         // "pregnancy" "period" etc
  final int? pregnancyWeek;
  final DateTime? nextAncDate;
  final String? ancLocation;
  final bool hasDangerSigns;
  final List<String> dangerSignsActive;
  final bool loggedToday;

  // Conditionally shared fields
  final int? moodScore;           // null if permission off
  final List<String>? symptoms;   // null if permission off
  final String? lastLabRisk;      // null if permission off
  final double? weight;           // null if permission off

  const PartnerHealthView({
    required this.womanName,
    required this.lifeStage,
    this.pregnancyWeek,
    this.nextAncDate,
    this.ancLocation,
    required this.hasDangerSigns,
    required this.dangerSignsActive,
    required this.loggedToday,
    this.moodScore,
    this.symptoms,
    this.lastLabRisk,
    this.weight,
  });

  String get weekLabel => pregnancyWeek != null ? 'Week $pregnancyWeek' : '';

  String get stageDisplay {
    switch (lifeStage) {
      case 'pregnancy': return 'Pregnant';
      case 'period':    return 'Tracking cycle';
      case 'postpartum':return 'Postpartum';
      default:          return lifeStage;
    }
  }

  String moodLabel(bool isAmharic) {
    if (moodScore == null) return '--';
    final labels = isAmharic
        ? ['😞 ደካማ', '😔 ዝቅተኛ', '😐 ተለምዶ', '🙂 ጥሩ', '😊 ደስተኛ', '😄 ጥሩ ስሜት', '🌟 እጅግ ጥሩ']
        : ['😞 Very low', '😔 Low', '😐 Neutral', '🙂 Okay', '😊 Good', '😄 Great', '🌟 Wonderful'];
    return labels[(moodScore! - 1).clamp(0, 6)];
  }
}

// Partner education module — male framed
class PartnerModule {
  final String id;
  final String titleEn, titleAm;
  final String descEn, descAm;
  final int forWeek;             // 0 = all weeks
  final String stage;            // pregnancy, postpartum, all
  final List<String> tipsEn;
  final List<String> tipsAm;
  final bool completed;

  const PartnerModule({
    required this.id,
    required this.titleEn, required this.titleAm,
    required this.descEn, required this.descAm,
    required this.forWeek,
    required this.stage,
    required this.tipsEn, required this.tipsAm,
    this.completed = false,
  });

  static List<PartnerModule> all = [
    PartnerModule(
      id: 'danger_signs',
      titleEn: 'Danger Signs Every Husband Must Know',
      titleAm: 'እያንዳንዱ ባል ማወቅ ያለበት የአደጋ ምልክቶች',
      descEn: 'The 7 warning signs that require immediate emergency action. These could save her life.',
      descAm: 'ወዲያውኑ የአደጋ እርምጃ የሚጠይቁ 7 የማስጠንቀቂያ ምልክቶች። እነዚህ ህይወቷን ሊያድኑ ይችላሉ።',
      forWeek: 0, stage: 'pregnancy',
      tipsEn: [
        'Severe headache that does not go away — call 907 immediately',
        'Blurred or double vision — this is preeclampsia, go now',
        'Sudden swelling of face, hands, or feet',
        'Heavy vaginal bleeding at any time',
        'No baby movement for more than 2 hours after Week 28',
        'High fever above 38°C',
        'Difficulty breathing or chest pain',
      ],
      tipsAm: [
        'የማይጠፋ ከባድ ራስ ምታት — ወዲያውኑ 907 ደውሉ',
        'የደበዘዘ ወይም ድርብ እይታ — ቅድመ-ክላምፕሲያ ነው፣ አሁን ሂዱ',
        'ፊት፣ እጆች ወይም እግሮች ድንገተኛ ማበጥ',
        'በማንኛውም ጊዜ ከባድ የሴት ብልት ደም መፍሰስ',
        'ከሳምንት 28 በኋላ ለ2 ሰዓት በላይ የህፃን እንቅስቃሴ አለመኖር',
        'ከ38°C በላይ ከፍተኛ ትኩሳት',
        'ለመተንፈስ ችግር ወይም የደረት ህመም',
      ],
    ),
    PartnerModule(
      id: 'anc_support',
      titleEn: 'How to Support ANC Visits',
      titleAm: 'ANC ጉብኝቶችን እንዴት መደገፍ',
      descEn: 'Your presence at ANC visits matters more than you think. Here is how to help.',
      descAm: 'ANC ጉብኝቶች ላይ መኖርዎ ከምታስቡት በላይ አስፈላጊ ነው። እንዴት መርዳት እንደሚቻል።',
      forWeek: 0, stage: 'pregnancy',
      tipsEn: [
        'Offer to accompany her — your presence reduces anxiety',
        'Arrange transport in advance, especially after Week 36',
        'Write down questions to ask the doctor together',
        'Remind her 24 hours and 2 hours before the appointment',
        'Handle household tasks on appointment days so she can rest',
      ],
      tipsAm: [
        'አብሮ ለመሄድ ሀሳብ ያቅርቡ — መኖርዎ ጭንቀትን ይቀንሳል',
        'አስቀድሞ ትራንስፖርት ያዘጋጁ፣ ከሳምንት 36 በኋላ ይበልጥ',
        'ለሐኪሙ አብሮ ጥያቄዎችን ይፃፉ',
        'ቀጠሮ ከ24 ሰዓት እና ከ2 ሰዓት በፊት ያስታውሱ',
        'ቀጠሮ ያለባቸው ቀናት የቤት ስራዎችን ይስሩ እሷ እንድታርፍ',
      ],
    ),
    PartnerModule(
      id: 'nutrition_week24',
      titleEn: 'What to Cook for Her — Week 24',
      titleAm: 'ሳምንት 24 — ምን ማዘጋጀት',
      descEn: 'Ethiopian foods that give her exactly what she needs in the second trimester.',
      descAm: 'በሁለተኛው ሶስት ወር ውስጥ የሚያስፈልጋትን የሚሰጡ የኢትዮጵያ ምግቦች።',
      forWeek: 24, stage: 'pregnancy',
      tipsEn: [
        'Misir wot — high iron, prevents anemia at altitude',
        'Gomen — folate that supports baby\'s brain development',
        'Teff injera — iron + calcium in every meal',
        'Avocado — healthy fats for baby\'s eye development',
        'Reduce spicy food — she may have heartburn now',
        'Small meals every 3 hours — her stomach has less room',
      ],
      tipsAm: [
        'ምስር ወጥ — ከፍ ያለ ብረት፣ በከፍታ ቦታ የደም ማነስን ይከላከላል',
        'ጎመን — የህፃኑ የአዕምሮ እድገትን የሚደግፍ ፎሌት',
        'ጤፍ ኢንጀራ — በእያንዳንዱ ምግብ ብረት + ካልሲየም',
        'አቮካዶ — ለህፃኑ የዓይን እድገት ጤናማ ስብ',
        'የቅመም ምግብ ይቀንሱ — አሁን ደረት ማቃጠል ሊኖራት ይችላል',
        'በ3 ሰዓት ትንሽ ምግቦች — ሆዷ አሁን ቦታ ያነሰ ነው',
      ],
    ),
    PartnerModule(
      id: 'emotional_support',
      titleEn: 'Understanding Her Emotions',
      titleAm: 'ስሜቷን መረዳት',
      descEn: 'Pregnancy brings intense emotions. This is not weakness — it is hormones and real fear. Here is how to respond.',
      descAm: 'እርግዝና ጠንካራ ስሜቶችን ያመጣል። ይህ ድክመት አይደለም — ሆርሞኖች እና እውነተኛ ፍርሃት ነው። እንዴት ምላሽ መስጠት።',
      forWeek: 0, stage: 'all',
      tipsEn: [
        'Listen first — do not immediately try to fix the problem',
        'Say "I hear you" and mean it before offering solutions',
        'Never compare her emotions to others or say "calm down"',
        'If she cries without a reason, sit with her — do not leave',
        'Low mood for 3 days in a row needs a doctor — not just rest',
        'Ask every day: "How are you feeling today?" and wait for the real answer',
      ],
      tipsAm: [
        'አስቀድሞ ያዳምጡ — ወዲያውኑ ችግሩን ለመፍታት አይሞክሩ',
        'ከፍትሃ ቅናሽ ቅናሽ ቅናሽ ቅናሽ ቅናሽ ቅናሽ',
        'ስሜቷን ከሌሎች ጋር አይወዳደሩ ወይም "ረጋ በሉ" አይበሉ',
        'ያለምክንያት ብታለቅስ፣ ከጎኗ ቁጡ — አትሂዱ',
        'ለ3 ቀናት ዝቅ ያለ ስሜት ሐኪም ይፈልጋል — ዕረፍት ብቻ አይደለም',
        'ሁልቀን ጠይቁ: "ዛሬ እንዴት ተሰምቶሃል?" እና የእውነተኛ መልሱን ጠብቁ',
      ],
    ),
    PartnerModule(
      id: 'postpartum_support',
      titleEn: 'The First 40 Days — Your Role',
      titleAm: 'የመጀመሪያዎቹ 40 ቀናት — ሚናዎ',
      descEn: 'In Ethiopian tradition, the first 40 days after birth are sacred. Here is how to protect both of them.',
      descAm: 'በኢትዮጵያ ወግ፣ ከወሊድ በኋላ የመጀመሪያዎቹ 40 ቀናት ቅዱስ ናቸው። ሁለቱንም እንዴት መጠበቅ።',
      forWeek: 0, stage: 'postpartum',
      tipsEn: [
        'She needs 6-8 weeks before full physical recovery — do not rush',
        'Postpartum depression affects 1 in 5 women — learn the signs',
        'Take night shifts so she can sleep in longer blocks',
        'Limit visitors if she is overwhelmed — you are the gatekeeper',
        'She may not want physical intimacy for months — this is normal',
        'Watch for: withdrawal, not eating, not bonding with baby — these need help',
      ],
      tipsAm: [
        'ሙሉ አካላዊ ማገገሚያ 6-8 ሳምንት ያስፈልጋታል — አይቸኩሉ',
        'የወሊድ ድህረ ጭንቀት ከ5 ሴቶች 1ቱን ይጎዳል — ምልክቶቹን ይወቁ',
        'ረዘም ባሉ ቦታዎች እንድትተኛ የምሽት ዙሮችን ይውሰዱ',
        'ከተጨነቀ ጎብኚዎችን ይገድቡ — እርስዎ ጠባቂው ነዎት',
        'ለወራት ሰውነት ምናልባት ፍፁምነት ላትፈልግ ትችላለች — ይህ ተለምዶ ነው',
        'ይጠብቁ: ራስን ማግለል፣ አለመብላት፣ ህፃኑን አለማቀፍ — እነዚህ እርዳታ ይፈልጋሉ',
      ],
    ),
  ];
}

// Chat message model
class PartnerMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;

  const PartnerMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });
}

enum MessageType { text, dangerAlert, milestone, ancReminder }

// Invite generation
class PartnerInvite {
  final String code;            // TG-4829
  final String qrData;          // tsega.app/partner?code=TG-4829
  final DateTime expiresAt;
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  PartnerInvite({
    required this.code,
    required this.qrData,
    required this.expiresAt,
  });

  static PartnerInvite generate() {
    final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = DateTime.now().millisecondsSinceEpoch;
    final code = 'TG-${chars[rand % chars.length]}${chars[(rand ~/ 10) % chars.length]}${rand % 10}${(rand ~/ 100) % 10}';
    return PartnerInvite(
      code: code,
      qrData: 'https://tsega.app/partner?code=$code',
      expiresAt: DateTime.now().add(const Duration(hours: 48)),
    );
  }
}
