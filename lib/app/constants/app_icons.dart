/// Centralized app icons using Cupertino Icons
///
/// This file provides a single source of truth for all icons used in the app.
/// Using a centralized approach allows for easy icon swapping and consistency.
library;

import 'package:flutter/cupertino.dart';

/// App icon constants using CupertinoIcons
///
/// Why Cupertino Icons:
/// - iOS-style design that matches premium aesthetic
/// - Already included in Flutter (cupertino_icons package)
/// - Clean, consistent stroke-based icons
/// - Familiar to iOS users
abstract class AppIcons {
  // Navigation
  static const arrowLeft = CupertinoIcons.arrow_left;
  static const arrowRight = CupertinoIcons.arrow_right;

  // Actions
  static const add = CupertinoIcons.add;
  static const delete = CupertinoIcons.trash;
  static const close = CupertinoIcons.xmark;
  static const check = CupertinoIcons.checkmark_square;
  static const checkCircle = CupertinoIcons.checkmark_circle;

  // Media controls
  static const play = CupertinoIcons.play_fill;
  static const pause = CupertinoIcons.pause_fill;
  static const stop = CupertinoIcons.stop_fill;

  // Audio
  static const volumeOn = CupertinoIcons.volume_up;
  static const volumeOff = CupertinoIcons.volume_off;

  // Visibility
  static const visible = CupertinoIcons.eye;
  static const hidden = CupertinoIcons.eye_slash;

  // User
  static const user = CupertinoIcons.person;

  // Home module
  static const fire = CupertinoIcons.flame;
  static const wallet = CupertinoIcons.creditcard;
  static const lotus = CupertinoIcons.heart;
  static const spa = CupertinoIcons.list_bullet;

  // Tasks
  static const calendar = CupertinoIcons.calendar;

  // Meditation
  static const timer = CupertinoIcons.timer;
  static const repeat = CupertinoIcons.repeat;
  static const vibration = CupertinoIcons.bell;
  static const phone = CupertinoIcons.device_phone_portrait;

  // Expenses - Categories
  static const food = CupertinoIcons.cart;
  static const transport = CupertinoIcons.car;
  static const shopping = CupertinoIcons.bag;
  static const entertainment = CupertinoIcons.film;
  static const health = CupertinoIcons.bandage;
  static const bills = CupertinoIcons.doc_text;
  static const money = CupertinoIcons.money_dollar_circle;

  // Habits
  static const habit = CupertinoIcons.checkmark_circle;
  static const streak = CupertinoIcons.flame_fill;
  static const heatmap = CupertinoIcons.square_grid_2x2;
  static const archive = CupertinoIcons.archivebox;

  // Journal / Mood
  static const journal = CupertinoIcons.book;
  static const mood = CupertinoIcons.smiley;
  static const tag = CupertinoIcons.tag;
  static const pencil = CupertinoIcons.pencil;

  // Goals
  static const goal = CupertinoIcons.flag;
  static const milestone = CupertinoIcons.checkmark_shield;
  static const target = CupertinoIcons.scope;
  static const trophy = CupertinoIcons.rosette;

  // Focus Timer
  static const focusTimer = CupertinoIcons.clock;
  static const timerFill = CupertinoIcons.timer_fill;
  static const clock = CupertinoIcons.clock;
  static const skip = CupertinoIcons.forward_end;
  static const forward = CupertinoIcons.forward_end_fill;
  static const reset = CupertinoIcons.arrow_counterclockwise;
  static const coffee = CupertinoIcons.pause_circle;

  // Review / Analytics
  static const chart = CupertinoIcons.chart_bar;
  static const trendUp = CupertinoIcons.graph_square;
  static const review = CupertinoIcons.chart_bar_alt_fill;

  // Settings & Notifications
  static const settings = CupertinoIcons.gear;
  static const notification = CupertinoIcons.bell_fill;
  static const notificationOff = CupertinoIcons.bell_slash;
}
