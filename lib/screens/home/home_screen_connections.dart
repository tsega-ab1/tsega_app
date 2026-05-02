// ════════════════════════════════════════════════════════════════
// HOME SCREEN CONNECTIONS
// This file shows exactly where to add each Navigator.push
// in your existing home_screen.dart
// Copy each snippet into the correct location
// ════════════════════════════════════════════════════════════════

// ── ADD THESE IMPORTS AT TOP OF home_screen.dart ─────────────────
import '../cycle/cycle_screen.dart';
import '../pregnancy/pregnancy_screen.dart';
import '../wellness/wellness_screen.dart';
import '../education/module_screen.dart';
import '../education/quiz_screen.dart';
import '../education/week_by_week_screen.dart';
import '../rewards/rewards_screen.dart';
import '../wearables/wearables_screen.dart';
import '../partner_invite/partner_invite_screen.dart';

// ── PERIOD MODE HOME ──────────────────────────────────────────────
// Find your "Calendar" quick action button in period dashboard
// Replace its onTap with:
onTap: () => Navigator.push(context,
  MaterialPageRoute(builder: (_) => const CycleScreen())),

// Find your "Wellness" quick action or drawer item:
onTap: () => Navigator.push(context,
  MaterialPageRoute(builder: (_) => const WellnessScreen())),

// ── PREGNANCY MODE HOME ───────────────────────────────────────────
// Find your "Week by Week" button:
onTap: () => Navigator.push(context,
  MaterialPageRoute(builder: (_) =>
      WeekByWeekScreen(currentWeek: userProvider.pregnancyWeek))),

// Find your pregnancy detail card or "View All" button:
onTap: () => Navigator.push(context,
  MaterialPageRoute(builder: (_) => const PregnancyScreen())),

// ── EDUCATION SCREEN ──────────────────────────────────────────────
// In education_screen.dart find your module card onTap:
onTap: () => Navigator.push(context,
  MaterialPageRoute(builder: (_) => ModuleScreen(module: module))),

// ── PROFILE SCREEN ────────────────────────────────────────────────
// Find your rewards row or XP section:
onTap: () => Navigator.push(context,
  MaterialPageRoute(builder: (_) => const RewardsScreen())),

// Find your partner row:
onTap: () => Navigator.push(context,
  MaterialPageRoute(builder: (_) => const PartnerInviteScreen())),

// ── HEALTH SCREEN ─────────────────────────────────────────────────
// Find your wearables card or connect device button:
onTap: () => Navigator.push(context,
  MaterialPageRoute(builder: (_) => const WearablesScreen())),

// ── HAMBURGER DRAWER ─────────────────────────────────────────────
// Add these nav items to hamburger_drawer.dart:
_DrawerItem(
  icon: Icons.spa_rounded,
  label: lang.s('Wellness', 'ጤናማነት'),
  onTap: () {
    Navigator.pop(context); // close drawer
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const WellnessScreen()));
  },
),
_DrawerItem(
  icon: Icons.watch_rounded,
  label: lang.s('Connect Device', 'መሳሪያ ያገናኙ'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const WearablesScreen()));
  },
),
_DrawerItem(
  icon: Icons.emoji_events_rounded,
  label: lang.s('My Rewards', 'ሽልማቶቼ'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const RewardsScreen()));
  },
),
