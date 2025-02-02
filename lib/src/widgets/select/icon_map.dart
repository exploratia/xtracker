import 'package:flutter/material.dart';

class IconMap {
  static Map<String, IconData> icons = _initIcons();

  static Map<String, IconData> _initIcons() {
    Map<String, IconData> map = {};
    // converted from https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/material/icons.dart
    // chart
    map["onetwothree_outlined"] = _materialIconData(0xf05b0);
    map["analytics_outlined"] = _materialIconData(0xee74);
    map["area_chart_outlined"] = _materialIconData(0xf05bb);
    map["bubble_chart_outlined"] = _materialIconData(0xef03);
    map["stacked_bar_chart_outlined"] = _materialIconData(0xf3d9);
    map["stacked_line_chart_outlined"] = _materialIconData(0xf3da);
    map["timeline_outlined"] = _materialIconData(0xf444);
    map["trending_up_outlined"] = _materialIconData(0xf462);
    map["monitor_heart_outlined"] = _materialIconData(0xf0635);
    map["monitor_weight_outlined"] = _materialIconData(0xf1e2);
    map["power_input_outlined"] = _materialIconData(0xf2c3);
    map["solar_power_outlined"] = _materialIconData(0xf0716);
    // calendar
    map["calendar_month_outlined"] = _materialIconData(0xf051f);
    map["calendar_today_outlined"] = _materialIconData(0xef11);
    map["today_outlined"] = _materialIconData(0xf44d);
    // sport
    map["directions_car_outlined"] = _materialIconData(0xefc6);
    map["directions_bike_outlined"] = _materialIconData(0xefc0);
    map["directions_run_outlined"] = _materialIconData(0xefcb);
    map["fitness_center_outlined"] = _materialIconData(0xf07a);
    // human
    map["female_outlined"] = _materialIconData(0xf050);
    map["male_outlined"] = _materialIconData(0xf1ab);
    map["sentiment_dissatisfied_outlined"] = _materialIconData(0xf35b);
    map["sentiment_neutral_outlined"] = _materialIconData(0xf35c);
    map["sentiment_satisfied_outlined"] = _materialIconData(0xf35e);
    map["thumb_down_outlined"] = _materialIconData(0xf43d);
    map["thumb_up_outlined"] = _materialIconData(0xf440);
    // nature
    map["landscape_outlined"] = _materialIconData(0xf14e);
    map["forest_outlined"] = _materialIconData(0xf0603);
    map["wb_sunny_outlined"] = _materialIconData(0xf4bc);
    map["bedtime_outlined"] = _materialIconData(0xeecb);
    map["cloud_outlined"] = _materialIconData(0xef62);
    // symbol
    map["bed_outlined"] = _materialIconData(0xeec7);
    map["book_outlined"] = _materialIconData(0xeedf);
    map["build_outlined"] = _materialIconData(0xef06);

    map["computer_outlined"] = _materialIconData(0xef74);
    map["smartphone_outlined"] = _materialIconData(0xf3a9);

    map["home_outlined"] = _materialIconData(0xf107);
    map["coffee_outlined"] = _materialIconData(0xef68);
    map["local_gas_station_outlined"] = _materialIconData(0xf17c);
    map["local_grocery_store_outlined"] = _materialIconData(0xf17d);
    map["local_restaurant_outlined"] = _materialIconData(0xf178);
    map["music_note_outlined"] = _materialIconData(0xf1fb);
    map["pets_outlined"] = _materialIconData(0xf285);
    map["savings_outlined"] = _materialIconData(0xf336);

    map["check_box_outlined"] = _materialIconData(0xef46);
    map["adjust_outlined"] = _materialIconData(0xee52);
    map["chat_outlined"] = _materialIconData(0xef44);
    map["access_time_outlined"] = _materialIconData(0xee2d);
    map["block_outlined"] = _materialIconData(0xeed1);
    map["star_border_outlined"] = _materialIconData(0xf3dc);
    map["visibility_outlined"] = _materialIconData(0xf4a1);
    map["warning_amber_outlined"] = _materialIconData(0xf4ae);
    map["favorite_outlined"] = _materialIconData(0xf04b);
    map["help_outlined"] = _materialIconData(0xf0f8);
    map["hexagon_outlined"] = _materialIconData(0xf0610);

    return map;
  }

  static IconData _materialIconData(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }
}
