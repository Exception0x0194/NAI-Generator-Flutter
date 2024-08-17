// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_CN';

  static String m0(batch_size, interval, number_of_requests) =>
      "每批次请求数目：${batch_size}，批次间隔时间：${interval} s，生成图片总数：${number_of_requests}";

  static String m1(current_size, i2i_size) =>
      "生成尺寸：${current_size}\n输入尺寸：${i2i_size}";

  static String m2(num) => "设置生成 ${num} 幅图片";

  static String m3(num) => "开始生成 ${num} 幅图片";

  static String m4(num) => "导入了 ${num} 个参数。";

  static String m5(parameter_name) => "导入了${parameter_name}。";

  static String m6(num) => "，每个重复 ${num} 次";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "NAI_API_key": MessageLookupByLibrary.simpleMessage("NAI API Token"),
        "NAI_API_key_hint": MessageLookupByLibrary.simpleMessage(
            "可以从主页 → 设置 → Account → Get Persistent API Token 获取"),
        "add_new_config": MessageLookupByLibrary.simpleMessage("插入新 Config"),
        "app_info": MessageLookupByLibrary.simpleMessage("应用信息"),
        "appbar_cooldown":
            MessageLookupByLibrary.simpleMessage("暂停生成以避免 429 错误……"),
        "appbar_idle": MessageLookupByLibrary.simpleMessage("NAI CasRand - 就绪"),
        "appbar_regular": MessageLookupByLibrary.simpleMessage("正在生成图片……"),
        "appbar_warning": MessageLookupByLibrary.simpleMessage("正在生成图片——消耗代币！"),
        "available_in_settings":
            MessageLookupByLibrary.simpleMessage("也可在设置页面调整"),
        "batch_count": MessageLookupByLibrary.simpleMessage("每批次请求数目"),
        "batch_interval": MessageLookupByLibrary.simpleMessage("批次间隔时间（秒）"),
        "batch_settings": MessageLookupByLibrary.simpleMessage("批次设置"),
        "batch_settings_info": m0,
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "cascaded_config_type": MessageLookupByLibrary.simpleMessage("下属设置类型"),
        "cascaded_config_type_config":
            MessageLookupByLibrary.simpleMessage("嵌套 Config"),
        "cascaded_config_type_str": MessageLookupByLibrary.simpleMessage("字符串"),
        "cascaded_configs":
            MessageLookupByLibrary.simpleMessage("嵌套 Config 内容"),
        "cascaded_strings": MessageLookupByLibrary.simpleMessage("字符串内容"),
        "cfg_rescale":
            MessageLookupByLibrary.simpleMessage("Prompt Guidance Rescale"),
        "comment": MessageLookupByLibrary.simpleMessage("Config 注释"),
        "confirm": MessageLookupByLibrary.simpleMessage("确认"),
        "copy_to_clipboard": MessageLookupByLibrary.simpleMessage("导出到剪切板"),
        "custom_metadata_content":
            MessageLookupByLibrary.simpleMessage("伪造水印内容"),
        "custom_metadata_enabled":
            MessageLookupByLibrary.simpleMessage("添加伪造水印信息"),
        "custom_size": MessageLookupByLibrary.simpleMessage("手动调整尺寸"),
        "delete_config": MessageLookupByLibrary.simpleMessage("删除 Config"),
        "director_tool_type": MessageLookupByLibrary.simpleMessage("工具类型"),
        "disabled": MessageLookupByLibrary.simpleMessage("禁用"),
        "donation_link": MessageLookupByLibrary.simpleMessage("赞助链接"),
        "donation_link_subtitle":
            MessageLookupByLibrary.simpleMessage("赛博功德，随喜赞叹🙏"),
        "drag_and_drop_image_notice":
            MessageLookupByLibrary.simpleMessage("拖动图片到此，或点击上传图片…"),
        "edit": MessageLookupByLibrary.simpleMessage("编辑"),
        "edit_cascaded_config_str_notice":
            MessageLookupByLibrary.simpleMessage("输入抽取的字符串内容，每行一个"),
        "edit_custom_metadata_content_hint":
            MessageLookupByLibrary.simpleMessage("应当是一个 JSON 字符串"),
        "edit_image_number_to_generate":
            MessageLookupByLibrary.simpleMessage("设置生成图片数量（设为 0 将持续生成）"),
        "enabled": MessageLookupByLibrary.simpleMessage("启用"),
        "enhance_only_once":
            MessageLookupByLibrary.simpleMessage("只 enhance 一次"),
        "enhance_override_prompts":
            MessageLookupByLibrary.simpleMessage("以图片 prompt 覆盖随机 prompt"),
        "enhance_override_smea":
            MessageLookupByLibrary.simpleMessage("强行使用设置中的 SMEA 参数"),
        "enhance_presets": MessageLookupByLibrary.simpleMessage("Enhance 预设参数"),
        "enhance_scale": MessageLookupByLibrary.simpleMessage("缩放系数"),
        "enter_position": MessageLookupByLibrary.simpleMessage("选择位置"),
        "export_settings_to_file":
            MessageLookupByLibrary.simpleMessage("导出设置到文件"),
        "export_to_clipboard": MessageLookupByLibrary.simpleMessage("导出到剪切板"),
        "failed": MessageLookupByLibrary.simpleMessage("失败"),
        "generate_one_prompt":
            MessageLookupByLibrary.simpleMessage("生成一个Prompt"),
        "generation": MessageLookupByLibrary.simpleMessage("图片生成"),
        "generation_settings": MessageLookupByLibrary.simpleMessage("设置"),
        "github_repo": MessageLookupByLibrary.simpleMessage("项目地址"),
        "height": MessageLookupByLibrary.simpleMessage("高度"),
        "i2i_config": MessageLookupByLibrary.simpleMessage("图生图设置"),
        "i2i_conifgs_set": MessageLookupByLibrary.simpleMessage("已设置图生图参数"),
        "i2i_image_size": m1,
        "image_number_to_generate":
            MessageLookupByLibrary.simpleMessage("生成图片数量"),
        "image_size": MessageLookupByLibrary.simpleMessage("图像尺寸"),
        "import_config_from_clipboard":
            MessageLookupByLibrary.simpleMessage("从剪切板导入 Config"),
        "import_settings_from_file":
            MessageLookupByLibrary.simpleMessage("从文件导入设置"),
        "info_export_file": MessageLookupByLibrary.simpleMessage("导出文件"),
        "info_export_to_clipboard":
            MessageLookupByLibrary.simpleMessage("向剪切板导出"),
        "info_import_file": MessageLookupByLibrary.simpleMessage("导入文件"),
        "info_import_from_clipboard":
            MessageLookupByLibrary.simpleMessage("从剪切板导入"),
        "info_set_genration_number": m2,
        "info_set_genration_number_failed":
            MessageLookupByLibrary.simpleMessage("设置中出现错误"),
        "info_start_generation": m3,
        "info_tile_height": MessageLookupByLibrary.simpleMessage("图片磁贴高度"),
        "is_ordered": MessageLookupByLibrary.simpleMessage("顺序"),
        "is_shuffled": MessageLookupByLibrary.simpleMessage("乱序"),
        "items": MessageLookupByLibrary.simpleMessage(" 个项目"),
        "loaded_parameters_count": m4,
        "metadata_erase_enabled":
            MessageLookupByLibrary.simpleMessage("清除生成图片中的水印信息"),
        "metadata_found": MessageLookupByLibrary.simpleMessage("发现了图片中的元数据"),
        "notNecessarily0to1":
            MessageLookupByLibrary.simpleMessage("……不一定在 0 到 1 之间"),
        "notice_enter_positon":
            MessageLookupByLibrary.simpleMessage("0 → 开头；留空 → 末尾"),
        "output_folder": MessageLookupByLibrary.simpleMessage("输出文件夹"),
        "override_prompt": MessageLookupByLibrary.simpleMessage("覆盖 prompt"),
        "override_random_prompts":
            MessageLookupByLibrary.simpleMessage("覆盖随机 prompts"),
        "parameters": MessageLookupByLibrary.simpleMessage("生成参数"),
        "paste_all": MessageLookupByLibrary.simpleMessage("复制所有参数"),
        "pasted_parameter": m5,
        "prompt": MessageLookupByLibrary.simpleMessage("提示词"),
        "prompt_compact_view_hint":
            MessageLookupByLibrary.simpleMessage("左右滑动查看参数，点击参数以修改"),
        "prompt_config": MessageLookupByLibrary.simpleMessage("Prompt 设置"),
        "proxy_settings": MessageLookupByLibrary.simpleMessage("HTTP 代理"),
        "proxy_settings_direct": MessageLookupByLibrary.simpleMessage("直连"),
        "proxy_settings_notice":
            MessageLookupByLibrary.simpleMessage("示例：127.0.0.1:12345；留空 → 直连"),
        "random_brackets": MessageLookupByLibrary.simpleMessage("随机括号数量"),
        "random_seed": MessageLookupByLibrary.simpleMessage("随机种子"),
        "reorder_config": MessageLookupByLibrary.simpleMessage("重新排序..."),
        "reset": MessageLookupByLibrary.simpleMessage("重置"),
        "sampler": MessageLookupByLibrary.simpleMessage("采样器"),
        "scale": MessageLookupByLibrary.simpleMessage("Prompt Guidance"),
        "select": MessageLookupByLibrary.simpleMessage("选择"),
        "select_bracket_hint":
            MessageLookupByLibrary.simpleMessage("负数 → 降权；正数 → 加权"),
        "selection_method": MessageLookupByLibrary.simpleMessage("选取方法"),
        "selection_method_all": MessageLookupByLibrary.simpleMessage("全部"),
        "selection_method_multiple_num":
            MessageLookupByLibrary.simpleMessage("多个 - 指定数量"),
        "selection_method_multiple_prob":
            MessageLookupByLibrary.simpleMessage("多个 - 指定选中概率"),
        "selection_method_single":
            MessageLookupByLibrary.simpleMessage("单个 - 随机选择"),
        "selection_method_single_sequential":
            MessageLookupByLibrary.simpleMessage("单个 - 顺序遍历"),
        "selection_num": MessageLookupByLibrary.simpleMessage("选中数量"),
        "selection_prob": MessageLookupByLibrary.simpleMessage("选中概率"),
        "set_enhancement_parameters":
            MessageLookupByLibrary.simpleMessage("设置 enhance 参数"),
        "settings": MessageLookupByLibrary.simpleMessage("参数设置"),
        "shuffled": MessageLookupByLibrary.simpleMessage("打乱次序"),
        "single_sequential_repeats": m6,
        "single_sequential_repeats_num":
            MessageLookupByLibrary.simpleMessage("重复次数"),
        "sm": MessageLookupByLibrary.simpleMessage("SMEA"),
        "sm_dyn": MessageLookupByLibrary.simpleMessage("DYN"),
        "succeed": MessageLookupByLibrary.simpleMessage("成功"),
        "system_document_folder":
            MessageLookupByLibrary.simpleMessage("系统文档文件夹"),
        "tap_to_paste_parameters":
            MessageLookupByLibrary.simpleMessage("点击以复制参数"),
        "toggle_compact_view": MessageLookupByLibrary.simpleMessage("切换紧凑视图"),
        "toggle_config_enable":
            MessageLookupByLibrary.simpleMessage("启用/禁用 Config"),
        "toggle_display_info_aside_img":
            MessageLookupByLibrary.simpleMessage("显示图片生成信息"),
        "toggle_generation": MessageLookupByLibrary.simpleMessage("开始/停止生成"),
        "uc": MessageLookupByLibrary.simpleMessage("反向提示词"),
        "use_random_seed": MessageLookupByLibrary.simpleMessage("使用随机种子"),
        "vibe_export": MessageLookupByLibrary.simpleMessage("导出 Vibe 图片"),
        "width": MessageLookupByLibrary.simpleMessage("宽度")
      };
}
