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

  static String m0(num) => "设置生成${num}幅图片";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "NAI_API_key": MessageLookupByLibrary.simpleMessage("NAI API key"),
        "add_new_config": MessageLookupByLibrary.simpleMessage("插入新Config"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "cascaded_config_type": MessageLookupByLibrary.simpleMessage("下属设置类型"),
        "cascaded_config_type_config":
            MessageLookupByLibrary.simpleMessage("嵌套Config"),
        "cascaded_config_type_str": MessageLookupByLibrary.simpleMessage("字符串"),
        "cascaded_configs": MessageLookupByLibrary.simpleMessage("嵌套Config内容"),
        "cascaded_strings": MessageLookupByLibrary.simpleMessage("字符串内容"),
        "cfg_rescale":
            MessageLookupByLibrary.simpleMessage("Prompt Guidance Rescale"),
        "comment": MessageLookupByLibrary.simpleMessage("Config注释"),
        "confirm": MessageLookupByLibrary.simpleMessage("确认"),
        "copy_to_clipboard": MessageLookupByLibrary.simpleMessage("导出到剪切板"),
        "custom_size": MessageLookupByLibrary.simpleMessage("手动调整尺寸"),
        "delete_config": MessageLookupByLibrary.simpleMessage("删除Config"),
        "disabled": MessageLookupByLibrary.simpleMessage("禁用"),
        "edit": MessageLookupByLibrary.simpleMessage("编辑"),
        "edit_image_number_to_generate":
            MessageLookupByLibrary.simpleMessage("设置生成图片数量（设为0即不断生成）"),
        "enabled": MessageLookupByLibrary.simpleMessage("启用"),
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
        "image_number_to_generate":
            MessageLookupByLibrary.simpleMessage("生成图片数量"),
        "image_size": MessageLookupByLibrary.simpleMessage("图像尺寸"),
        "import_config_from_clipboard":
            MessageLookupByLibrary.simpleMessage("从剪切板导入Config"),
        "import_settings_from_file":
            MessageLookupByLibrary.simpleMessage("从文件导入设置"),
        "info_export_file": MessageLookupByLibrary.simpleMessage("导出文件"),
        "info_export_to_clipboard":
            MessageLookupByLibrary.simpleMessage("向剪切板导出"),
        "info_import_file": MessageLookupByLibrary.simpleMessage("导入文件"),
        "info_import_from_clipboard":
            MessageLookupByLibrary.simpleMessage("从剪切板导入"),
        "info_set_genration_number": m0,
        "info_set_genration_number_failed":
            MessageLookupByLibrary.simpleMessage("设置中出现错误"),
        "info_set_looping_genration":
            MessageLookupByLibrary.simpleMessage("设置为不断生成"),
        "info_tile_height": MessageLookupByLibrary.simpleMessage("图片磁贴高度"),
        "prompt_config": MessageLookupByLibrary.simpleMessage("Prompt设置"),
        "random_brackets": MessageLookupByLibrary.simpleMessage("随机括号数量"),
        "random_seed": MessageLookupByLibrary.simpleMessage("随机种子"),
        "sampler": MessageLookupByLibrary.simpleMessage("采样器"),
        "scale": MessageLookupByLibrary.simpleMessage("Prompt Guidance"),
        "select": MessageLookupByLibrary.simpleMessage("选择"),
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
        "settings": MessageLookupByLibrary.simpleMessage("参数设置"),
        "shuffled": MessageLookupByLibrary.simpleMessage("打乱次序"),
        "sm": MessageLookupByLibrary.simpleMessage("SMEA"),
        "sm_dyn": MessageLookupByLibrary.simpleMessage("DYN"),
        "succeed": MessageLookupByLibrary.simpleMessage("成功"),
        "toggle_compact_view": MessageLookupByLibrary.simpleMessage("切换紧凑视图"),
        "toggle_config_enable":
            MessageLookupByLibrary.simpleMessage("启用/禁用Config"),
        "toggle_display_info_aside_img":
            MessageLookupByLibrary.simpleMessage("显示图片生成信息"),
        "toggle_generation": MessageLookupByLibrary.simpleMessage("开始/停止生成"),
        "uc": MessageLookupByLibrary.simpleMessage("反向提示词"),
        "use_random_seed": MessageLookupByLibrary.simpleMessage("使用随机种子"),
        "width": MessageLookupByLibrary.simpleMessage("宽度")
      };
}
