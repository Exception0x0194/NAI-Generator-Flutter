// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(num) => "Set ${num} generations";

  static String m1(num) => "Started generation for ${num} images";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "NAI_API_key": MessageLookupByLibrary.simpleMessage("NAI API Key"),
        "add_new_config":
            MessageLookupByLibrary.simpleMessage("Add New Config"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cascaded_config_type":
            MessageLookupByLibrary.simpleMessage("Nested Config Type"),
        "cascaded_config_type_config":
            MessageLookupByLibrary.simpleMessage("Nested Config"),
        "cascaded_config_type_str":
            MessageLookupByLibrary.simpleMessage("String"),
        "cascaded_configs":
            MessageLookupByLibrary.simpleMessage("Nested Configs"),
        "cascaded_strings":
            MessageLookupByLibrary.simpleMessage("String Values"),
        "cfg_rescale":
            MessageLookupByLibrary.simpleMessage("Prompt Guidance Rescale"),
        "comment": MessageLookupByLibrary.simpleMessage("Config Comment"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "copy_to_clipboard":
            MessageLookupByLibrary.simpleMessage("Copy to Clipboard"),
        "custom_size": MessageLookupByLibrary.simpleMessage("Custom Size"),
        "delete_config": MessageLookupByLibrary.simpleMessage("Delete Config"),
        "disabled": MessageLookupByLibrary.simpleMessage("Disabled"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit "),
        "edit_image_number_to_generate": MessageLookupByLibrary.simpleMessage(
            "Set Number of Images to Generate (Set to 0 for continuous generation)"),
        "enabled": MessageLookupByLibrary.simpleMessage("Enabled"),
        "enter_position":
            MessageLookupByLibrary.simpleMessage("Enter position"),
        "enter_position_placeholder":
            MessageLookupByLibrary.simpleMessage("Position"),
        "export_settings_to_file":
            MessageLookupByLibrary.simpleMessage("Export Settings to File"),
        "export_to_clipboard":
            MessageLookupByLibrary.simpleMessage("Export to Clipboard"),
        "failed": MessageLookupByLibrary.simpleMessage("failed"),
        "generate_one_prompt":
            MessageLookupByLibrary.simpleMessage("Generate One Prompt"),
        "generation": MessageLookupByLibrary.simpleMessage("Image Generation"),
        "generation_settings":
            MessageLookupByLibrary.simpleMessage("Genration Settings"),
        "github_repo":
            MessageLookupByLibrary.simpleMessage("GitHub Repository"),
        "height": MessageLookupByLibrary.simpleMessage("Height"),
        "i2i_config": MessageLookupByLibrary.simpleMessage("Img2Img Settings"),
        "image_number_to_generate": MessageLookupByLibrary.simpleMessage(
            "Number of Images to Generate"),
        "image_size": MessageLookupByLibrary.simpleMessage("Image Size"),
        "import_config_from_clipboard": MessageLookupByLibrary.simpleMessage(
            "Import Config from Clipboard"),
        "import_settings_from_file":
            MessageLookupByLibrary.simpleMessage("Import Settings from File"),
        "info_export_file":
            MessageLookupByLibrary.simpleMessage("File export "),
        "info_export_to_clipboard":
            MessageLookupByLibrary.simpleMessage("Clipboard export "),
        "info_import_file":
            MessageLookupByLibrary.simpleMessage("File import "),
        "info_import_from_clipboard":
            MessageLookupByLibrary.simpleMessage("Clipboard import "),
        "info_set_genration_number": m0,
        "info_set_genration_number_failed":
            MessageLookupByLibrary.simpleMessage("Set genration number failed"),
        "info_start_generation": m1,
        "info_tile_height":
            MessageLookupByLibrary.simpleMessage("Image Tile Height"),
        "is_ordered": MessageLookupByLibrary.simpleMessage("Ordered"),
        "is_shuffled": MessageLookupByLibrary.simpleMessage("Shuffled"),
        "notNecessarily0to1": MessageLookupByLibrary.simpleMessage(
            "... not necessarily between 0 and 1"),
        "notice_enter_positon":
            MessageLookupByLibrary.simpleMessage("0 → head; blank → tail"),
        "prompt_config":
            MessageLookupByLibrary.simpleMessage("Prompt Settings"),
        "random_brackets":
            MessageLookupByLibrary.simpleMessage("Random Number of Brackets"),
        "random_seed": MessageLookupByLibrary.simpleMessage("Random Seed"),
        "reorder_config": MessageLookupByLibrary.simpleMessage("Reorder..."),
        "reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "sampler": MessageLookupByLibrary.simpleMessage("Sampler"),
        "scale": MessageLookupByLibrary.simpleMessage("Prompt Guidance"),
        "select": MessageLookupByLibrary.simpleMessage("Select "),
        "select_bracket_hint": MessageLookupByLibrary.simpleMessage(
            "Negative → decreased weight; Positive → increased weight"),
        "selection_method":
            MessageLookupByLibrary.simpleMessage("Selection Method"),
        "selection_method_all": MessageLookupByLibrary.simpleMessage("All"),
        "selection_method_multiple_num": MessageLookupByLibrary.simpleMessage(
            "Multiple - with specified Count"),
        "selection_method_multiple_prob": MessageLookupByLibrary.simpleMessage(
            "Multiple - with pecified Probability"),
        "selection_method_single":
            MessageLookupByLibrary.simpleMessage("Single - random"),
        "selection_method_single_sequential":
            MessageLookupByLibrary.simpleMessage("Single - sequential"),
        "selection_num":
            MessageLookupByLibrary.simpleMessage("Selection Count"),
        "selection_prob":
            MessageLookupByLibrary.simpleMessage("Selection Probability"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "shuffled": MessageLookupByLibrary.simpleMessage("Shuffle"),
        "sm": MessageLookupByLibrary.simpleMessage("SMEA"),
        "sm_dyn": MessageLookupByLibrary.simpleMessage("DYN"),
        "succeed": MessageLookupByLibrary.simpleMessage("succeed"),
        "toggle_compact_view":
            MessageLookupByLibrary.simpleMessage("Toggle Compact View"),
        "toggle_config_enable":
            MessageLookupByLibrary.simpleMessage("Enable/Disable Config"),
        "toggle_display_info_aside_img": MessageLookupByLibrary.simpleMessage(
            "Display Image Generation Info"),
        "toggle_generation":
            MessageLookupByLibrary.simpleMessage("Start/Stop Generation"),
        "uc": MessageLookupByLibrary.simpleMessage("Inverse Prompt Token"),
        "use_random_seed":
            MessageLookupByLibrary.simpleMessage("Use Random Seed"),
        "vibe_export":
            MessageLookupByLibrary.simpleMessage("Vibe image export "),
        "width": MessageLookupByLibrary.simpleMessage("Width")
      };
}
