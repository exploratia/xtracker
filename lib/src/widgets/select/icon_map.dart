import 'package:flutter/material.dart';

class IconMap {
  static Map<String, IconData> icons = _initIcons();

  static Map<String, IconData> _initIcons() {
    Map<String, IconData> map = {};
    // converted from https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/material/icons.dart
    // // chart
    // map["onetwothree_outlined"] = _materialIconData(0xf05b0);
    // map["analytics_outlined"] = _materialIconData(0xee74);
    // map["area_chart_outlined"] = _materialIconData(0xf05bb);
    // map["bubble_chart_outlined"] = _materialIconData(0xef03);
    // map["stacked_bar_chart_outlined"] = _materialIconData(0xf3d9);
    // map["stacked_line_chart_outlined"] = _materialIconData(0xf3da);
    // map["timeline_outlined"] = _materialIconData(0xf444);
    // map["trending_up_outlined"] = _materialIconData(0xf462);
    // map["monitor_heart_outlined"] = _materialIconData(0xf0635);
    // map["monitor_weight_outlined"] = _materialIconData(0xf1e2);
    // map["power_input_outlined"] = _materialIconData(0xf2c3);
    // map["solar_power_outlined"] = _materialIconData(0xf0716);
    // // calendar
    // map["calendar_month_outlined"] = _materialIconData(0xf051f);
    // map["calendar_today_outlined"] = _materialIconData(0xef11);
    // map["today_outlined"] = _materialIconData(0xf44d);
    // // sport
    // map["directions_car_outlined"] = _materialIconData(0xefc6);
    // map["directions_bike_outlined"] = _materialIconData(0xefc0);
    // map["directions_run_outlined"] = _materialIconData(0xefcb);
    // map["fitness_center_outlined"] = _materialIconData(0xf07a);
    // // human
    // map["female_outlined"] = _materialIconData(0xf050);
    // map["male_outlined"] = _materialIconData(0xf1ab);
    // map["sentiment_dissatisfied_outlined"] = _materialIconData(0xf35b);
    // map["sentiment_neutral_outlined"] = _materialIconData(0xf35c);
    // map["sentiment_satisfied_outlined"] = _materialIconData(0xf35e);
    // map["thumb_down_outlined"] = _materialIconData(0xf43d);
    // map["thumb_up_outlined"] = _materialIconData(0xf440);
    // // nature
    // map["landscape_outlined"] = _materialIconData(0xf14e);
    // map["forest_outlined"] = _materialIconData(0xf0603);
    // map["wb_sunny_outlined"] = _materialIconData(0xf4bc);
    // map["bedtime_outlined"] = _materialIconData(0xeecb);
    // map["cloud_outlined"] = _materialIconData(0xef62);
    // // symbol
    // map["bed_outlined"] = _materialIconData(0xeec7);
    // map["book_outlined"] = _materialIconData(0xeedf);
    // map["build_outlined"] = _materialIconData(0xef06);
    //
    // map["computer_outlined"] = _materialIconData(0xef74);
    // map["smartphone_outlined"] = _materialIconData(0xf3a9);
    //
    // map["home_outlined"] = _materialIconData(0xf107);
    // map["coffee_outlined"] = _materialIconData(0xef68);
    // map["local_gas_station_outlined"] = _materialIconData(0xf17c);
    // map["local_grocery_store_outlined"] = _materialIconData(0xf17d);
    // map["local_restaurant_outlined"] = _materialIconData(0xf178);
    // map["music_note_outlined"] = _materialIconData(0xf1fb);
    // map["pets_outlined"] = _materialIconData(0xf285);
    // map["savings_outlined"] = _materialIconData(0xf336);
    //
    // map["check_box_outlined"] = _materialIconData(0xef46);
    // map["adjust_outlined"] = _materialIconData(0xee52);
    // map["chat_outlined"] = _materialIconData(0xef44);
    // map["access_time_outlined"] = _materialIconData(0xee2d);
    // map["block_outlined"] = _materialIconData(0xeed1);
    // map["star_border_outlined"] = _materialIconData(0xf3dc);
    // map["visibility_outlined"] = _materialIconData(0xf4a1);
    // map["warning_amber_outlined"] = _materialIconData(0xf4ae);
    // map["favorite_outlined"] = _materialIconData(0xf04b);
    // map["help_outlined"] = _materialIconData(0xf0f8);
    // map["hexagon_outlined"] = _materialIconData(0xf0610);

    // not so good but because of treeshaking we use directly the icons

    // chart
    map["onetwothree_outlined"] = Icons.onetwothree_outlined;
    map["analytics_outlined"] = Icons.analytics_outlined;
    map["area_chart_outlined"] = Icons.area_chart_outlined;
    map["bubble_chart_outlined"] = Icons.bubble_chart_outlined;
    map["stacked_bar_chart_outlined"] = Icons.stacked_bar_chart_outlined;
    map["stacked_line_chart_outlined"] = Icons.stacked_line_chart_outlined;
    map["timeline_outlined"] = Icons.timeline_outlined;
    map["trending_up_outlined"] = Icons.trending_up_outlined;
    map["monitor_heart_outlined"] = Icons.monitor_heart_outlined;
    map["monitor_weight_outlined"] = Icons.monitor_weight_outlined;
    map["power_input_outlined"] = Icons.power_input_outlined;
    map["solar_power_outlined"] = Icons.solar_power_outlined;
    // calendar
    map["calendar_month_outlined"] = Icons.calendar_month_outlined;
    map["calendar_today_outlined"] = Icons.calendar_today_outlined;
    map["today_outlined"] = Icons.today_outlined;
    // sport
    map["directions_car_outlined"] = Icons.directions_car_outlined;
    map["directions_bike_outlined"] = Icons.directions_bike_outlined;
    map["directions_run_outlined"] = Icons.directions_run_outlined;
    map["fitness_center_outlined"] = Icons.fitness_center_outlined;
    // human
    map["female_outlined"] = Icons.female_outlined;
    map["male_outlined"] = Icons.male_outlined;
    map["sentiment_dissatisfied_outlined"] =
        Icons.sentiment_dissatisfied_outlined;
    map["sentiment_neutral_outlined"] = Icons.sentiment_neutral_outlined;
    map["sentiment_satisfied_outlined"] = Icons.sentiment_satisfied_outlined;
    map["thumb_down_outlined"] = Icons.thumb_down_outlined;
    map["thumb_up_outlined"] = Icons.thumb_up_outlined;
    // nature
    map["landscape_outlined"] = Icons.landscape_outlined;
    map["forest_outlined"] = Icons.forest_outlined;
    map["wb_sunny_outlined"] = Icons.wb_sunny_outlined;
    map["bedtime_outlined"] = Icons.bedtime_outlined;
    map["cloud_outlined"] = Icons.cloud_outlined;
    // symbol
    map["bed_outlined"] = Icons.bed_outlined;
    map["book_outlined"] = Icons.book_outlined;
    map["build_outlined"] = Icons.build_outlined;

    map["computer_outlined"] = Icons.computer_outlined;
    map["smartphone_outlined"] = Icons.smartphone_outlined;

    map["home_outlined"] = Icons.home_outlined;
    map["coffee_outlined"] = Icons.coffee_outlined;
    map["local_gas_station_outlined"] = Icons.local_gas_station_outlined;
    map["local_grocery_store_outlined"] = Icons.local_grocery_store_outlined;
    map["local_restaurant_outlined"] = Icons.local_restaurant_outlined;
    map["music_note_outlined"] = Icons.music_note_outlined;
    map["pets_outlined"] = Icons.pets_outlined;
    map["savings_outlined"] = Icons.savings_outlined;

    map["check_box_outlined"] = Icons.check_box_outlined;
    map["adjust_outlined"] = Icons.adjust_outlined;
    map["chat_outlined"] = Icons.chat_outlined;
    map["access_time_outlined"] = Icons.access_time_outlined;
    map["block_outlined"] = Icons.block_outlined;
    map["star_border_outlined"] = Icons.star_border_outlined;
    map["visibility_outlined"] = Icons.visibility_outlined;
    map["warning_amber_outlined"] = Icons.warning_amber_outlined;
    map["favorite_outlined"] = Icons.favorite_outlined;
    map["help_outlined"] = Icons.help_outlined;
    map["hexagon_outlined"] = Icons.hexagon_outlined;

    return map;
  }

  static IconData _materialIconData(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }
}
